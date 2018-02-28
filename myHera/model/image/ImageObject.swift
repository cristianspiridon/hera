//
//  ImageObject.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


protocol ImageObjectDelegate {
    
    func onImageLoaded()
    
}

class ImageObject: NSObject {
    
    var ref:DatabaseReference?
    var filePath:String?
    var image:UIImage?
   
    var delegates = [ImageObjectDelegate]()
    
    override init() {
        
        super.init()
        
    }
    
    
    func getImageByFilePath(filePath:String) {
        
        if self.filePath != filePath {
            
            self.filePath = filePath
            
            print("Load image by file path \(filePath)" )
            
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child(filePath)
            
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                } else {
                    
                    self.image = UIImage(data: data!)
                    
                    for delegate in self.delegates {
                        
                        delegate.onImageLoaded()
                        
                    }
                    
                    self.delegates = [ImageObjectDelegate]()
                    
                }
            }
            
        }
    }
    
    
    func exists() -> Bool {
        return image != nil
    }
    
    func getImageByReference(ref:DatabaseReference) {
        
        self.ref = ref
        self.ref?.observe(.value, with: { (snapshot) in
            
            print("we have snapshot \(snapshot)")
            
            if snapshot.key == "filePath" {
                
                self.filePath = snapshot.value as? String
                
            }
            
        })
        
    }

}
