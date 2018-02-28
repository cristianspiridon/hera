//
//  UserBankObject.swift
//  myHera
//
//  Created by Cristian Spiridon on 02/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


protocol UserBankObjectDelegate {
    
    func onDisplayNameChange()
    func onProfileImageChange()
    
}

extension UserBankObject:ImageObjectDelegate {
  
    func onImageLoaded() {
        
        profileImage = imageLoader?.image
        
        for delegate in self.delegates {
            
            delegate.onProfileImageChange()
            
        }
    }
    
}

class UserBankObject: NSObject {

    
    
    var displayName:String = ""
    var imageFilePath:String = ""
    
    var profileImage:UIImage?
    var key:String!
    var delegates:[UserBankObjectDelegate] = [UserBankObjectDelegate]()
    
    
    var ref:DatabaseReference!
    var userRef:DatabaseReference!
    
    var exists = false
    
    var imageLoader:ImageObject?
    
    init(key:String) {
        
        super.init()
        
        self.key = key
        
        if key != "" {
            
            
            setupListener()
            
            
        }
        
    }
    
    func setupListener(){
        
        ref = Database.database().reference()
        
        userRef = ref.child("user-info").child(self.key!)
        
        exists = false
        
        userRef.observe(.value) { (snapshot) in
            
            print("user info \(snapshot)")
            
            if let dict:[String:String] = snapshot.value as? [String:String] {
            
                self.exists = true
                
                if self.displayName != dict["displayName"]! {
                    
                    self.displayName = dict["displayName"]!
                    
                    for delegate in self.delegates {
                        
                        delegate.onDisplayNameChange()
                    }
                }
                
                if self.imageFilePath != dict["imageFilePath"]! {
                    
                    self.imageFilePath = dict["imageFilePath"]!
                    self.getImage(at:self.imageFilePath)
                }
                
            }
            
        }
        
    }
    
    func setProfile(filePath:String) {
        
        userRef.child("imageFilePath").setValue(filePath)
        
    }
    
    
    func getImage(at:String) {
        
        imageLoader = imgBank?.getImageObjectByFilePath(filePath: at)
        imageLoader?.delegates.append(self)
        
    }
    
    
}
