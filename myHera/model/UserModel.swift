//
//  UserModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 21/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

protocol UserModelDelegate {
    
    func onBusinessModel()
    
}

class UserModel: NSObject {

    var ref:DatabaseReference!
    var uid:String?
    var delegate:UserModelDelegate?
    
    var delegates:[UserModelDelegate]  = [UserModelDelegate]()
    var selfObject:UserBankObject?
    
    var currentBUID:String?
    var currentRole:String?
    
    init(uid:String) {
        
        super.init()
        print("Initialize with user id \(uid)")
        
        self.uid = uid
        
        if let temp = userBank?.getUserObject(with: uid) {
            
            selfObject = temp
            
        }
        
        ref = Database.database().reference()
        
        setDefaultBusiness()
    }
    
    func updateDisplayName(with:String) {
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = with
        
        changeRequest?.commitChanges(completion: { (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            }
            
        })
        
        ref.child("user-info").child((userModel?.uid!)!).child("displayName").setValue(with)
        SVProgressHUD.showSuccess(withStatus: "Display name changed")
        
    }
    
    
    
    func updateEmail(with:String) {
    
        Auth.auth().currentUser?.updateEmail(to: with, completion: { (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            
            } else {
                SVProgressHUD.showSuccess(withStatus: "Email address changed")
            }
            
        })
        
    }
    
    func updatePassword(with:String) {
        
        Auth.auth().currentUser?.updatePassword(to: with, completion: { (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            } else {
                SVProgressHUD.showSuccess(withStatus: "Password changed")
            }
            
        })
        
    }
    

    
    func setDefaultBusiness() {
        
        
        
        ref.child("user-roles").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            
            print("User snapshot \(snapshot)")
            
            
            if snapshot.exists() {
                
                let returnObj = snapshot.value as! [String:Any]
                
                let buid = returnObj["default_buid"] as! String
                
                if let role:[String:String] = returnObj[buid] as? [String:String] {
                    
                    self.currentRole = role["role"]
                    
                }
                
                self.setupWithBUID(buid: buid)
                
                
            }
            
        }
    }
    
    func setupWithBUID(buid:String) {
        
       self.currentBUID = buid
        
        print("setup with buid \(buid)")
        
       for delegate in self.delegates {
                    
            delegate.onBusinessModel()
                    
        }
        
    }
    

    
    func emailAddress() -> String {
    
        if let email = Auth.auth().currentUser?.email {
    
            return email
    
        } else {
    
            return "no name"
        }
    }
    
    func savePictureProfile (image:UIImage){
        
        SVProgressHUD.show()
        
        let imgPath:String = "/profile_pictures/\(uid!)/\(Date().timeIntervalSince1970)"
        
        var imageUploadManager: ImageUploadManager?
        
        imageUploadManager = ImageUploadManager()
        imageUploadManager?.uploadImage(image, path: imgPath, progressBlock: { (percentage) in
            print(percentage)
        }, completionBlock: {(fileURL, errorMessage) in
            
            if self.selfObject?.imageFilePath != "" {
                
                imgBank?.deleteImageAt(path: (self.selfObject?.imageFilePath)!)
                
            }
            
            self.selfObject?.setProfile(filePath: imgPath)
            
            SVProgressHUD.showSuccess(withStatus: "Image uploaded")
        })
        
    }
    
}
