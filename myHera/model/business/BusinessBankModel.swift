//
//  BusinessBankModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 07/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol BusinessBankModelDelegate {
    
    func onName(name:String)
    func onImage(image:UIImage)
    
}

extension BusinessBankModel:ImageObjectDelegate {
    
    func onImageLoaded() {
        
        logoImage = imageLoader?.image
        
        print("Business Model  on image loaded")
        
        for delegate in self.delegates {
            
            delegate.onImage(image:logoImage!)
            
        }
    }
    
}


class BusinessBankModel: NSObject {
    
    var key:String?
    var delegates:[BusinessBankModelDelegate] = [BusinessBankModelDelegate]()
    
    var logoFilePath:String?
    var name:String?
    var uid:String?
    var logoImage:UIImage?
    
    var imageLoader:ImageObject?
    var ref:DatabaseReference?
    var exists:Bool = false
    
    init(key:String) {
        super.init()
        
        self.key = key
        self.ref = Database.database().reference()
        
        setupListeners()
    }
    
    func setupListeners() {
        
        ref?.child("business").child(key!).child("info").observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                print("snapshot: \(snapshot)")
                
                self.exists = true
                
                let value:[String:String] = snapshot.value as! [String:String]
                
                self.setName(with: value["title"]!)
                self.setLogo(filePath: value["logo"]!)
                
                self.uid  = value["uid"]
                
                
            }
            
        }
    
    }
    
    func setLogo(filePath:String) {
        
        if logoFilePath != filePath {
            
            logoFilePath = filePath
            getImage(at:logoFilePath!)
            
        }
        
    }
    
    func setName(with:String) {
        
        if name != with {
            
            name = with
            
            for delegate in delegates {
                
                delegate.onName(name: with)
                
            }
        }
    }
    
    func getImage(at:String) {
        
        imageLoader = imgBank?.getImageObjectByFilePath(filePath: at)
        imageLoader?.delegates.append(self)
        
    }
    
    func saveLogo(image:UIImage) {
        
        let imgPath:String = "/business_logo/\((userModel?.currentBUID)!)/\(Date().timeIntervalSince1970))"
        
        let imageUploadManager = ImageUploadManager()
        imageUploadManager.uploadImage(image, path: imgPath, progressBlock: { (percentage) in
            print(percentage)
        }, completionBlock: {(fileURL, errorMessage) in
            
            if errorMessage != nil {
                
                SVProgressHUD.dismiss()
                
            } else {
                
                SVProgressHUD.showSuccess(withStatus: "Image Saved")
                self.updateLogo(filePath: imgPath)
               
            }
            
        })
        
    }
    
    func updateName(with:String) {
        
        if name != with {
           
            ref?.child("business").child(key!).child("info").child("title").setValue(with)
            SVProgressHUD.showSuccess(withStatus: "Business name updated")
        }
        
    }
    
    func updateLogo(filePath:String) {
        
        if logoFilePath != filePath {
            
            imgBank?.deleteImageAt(path: logoFilePath!)
            ref?.child("business").child(key!).child("info").child("logo").setValue(filePath)
            
        }
        
    }
    
}
