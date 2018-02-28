//
//  ImageBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 31/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase


class ImageBank: NSObject {

    var images:[ImageObject] = [ImageObject]()
    
    override init() {
        
        super.init()
        
    }
    
    
    func getImageObjectByFilePath(filePath:String) -> ImageObject {
        
        let i = images.index { (imgObj) -> Bool in
            
            return imgObj.filePath == filePath
            
        }
        
        if i != nil {
            
            return images[i!]
            
        } else {
            let newImageObject = ImageObject()
            newImageObject.getImageByFilePath(filePath: filePath)
            
            images.append(newImageObject)
            
            return newImageObject
        }
        
    }
    
    func deleteImageAt(path:String) {
        
        print("Delete image at \(path)")
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(path)
        
        // Delete the file
        imageRef.delete { error in
            if error != nil {
                print("Error deleting picture")
            } else {
                print("")
            }
        }
        
    }
    
    
}


