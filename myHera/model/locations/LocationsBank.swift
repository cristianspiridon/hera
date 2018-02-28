//
//  LocationsBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol LocationsBankDelegate {
    
   func onLocationCreatedWithSuccess()
    
}

protocol BusinessLocationsDelegate {
    
    func onChildAdded()
    func onChildDeleted(index:Int)
}

class LocationsBank: NSObject {
    
    var locations:[LocationBankModel] = [LocationBankModel]()
    var businessLocations:[LocationBankModel] = [LocationBankModel]()
    
    var delegates:[LocationsBankDelegate] = [LocationsBankDelegate]()
    var businessDelegates:[BusinessLocationsDelegate] = [BusinessLocationsDelegate]()
    
    var ref:DatabaseReference!
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override init() {
        
        super.init()
        ref = Database.database().reference()
        
    }
    
    
    
    
    func getLocationsBy(businessID:String) {
        
        businessLocations = [LocationBankModel]()
        
        ref.child("business").child(businessID).child("locations").observe(.childAdded) { (snapshot) in
            
            if snapshot.exists() {
                
                let newBusinessLocation = self.getLocationBy(locationID: snapshot.key)
                self.businessLocations.append(newBusinessLocation)
            }
            
            for delegate in self.businessDelegates {
                
                delegate.onChildAdded()
                
            }
            
        }
        
    }
    
    
    func getLocationBy(locationID:String) -> LocationBankModel {
        
        let i = locations.index { (location) -> Bool in
            
           return location.key == locationID
            
        }
        
        if i != nil {
            
            return locations[i!]
            
        } else {
            
            let newLocation = LocationBankModel(key: locationID)
            locations.append(newLocation)
            return newLocation
        }
        
    }
    
    func getRandomFilePath() -> String {
        
        let buid = userModel?.currentBUID
        let imgFileName    = "\(Date().timeIntervalSince1970)"
        
        return "/business_locations/\(buid!)/\(imgFileName)"
        
        
    }
    
    func createNewLocationWithImage(locationName:String, locationPostcode:String, image:UIImage) {
        
        
        SVProgressHUD.show()
        
        let imgPath:String = getRandomFilePath()
        
        upload(image: image, at: imgPath) { (success) in
        
            self.createNewLocation(locationName: locationName, locationPostcode: locationPostcode, imgPath: imgPath)
            
        }
        
        
    }
    
    func updateImage(filePath:String, forLocationId:String) {
        
        ref.child("locations").child(forLocationId).child("image").setValue(filePath)
        
    }
    
    func upload(image:UIImage, at:String, completionHandler: @escaping CompletionHandler){
        
        var imageUploadManager: ImageUploadManager?
        
        
        imageUploadManager = ImageUploadManager()
        imageUploadManager?.uploadImage(image, path: at, progressBlock: { (percentage) in
            print(percentage)
            
        }, completionBlock: {(fileURL, errorMessage) in
            
            if errorMessage != nil {
                
                SVProgressHUD.showError(withStatus: errorMessage)
                
            } else {
                
              //  SVProgressHUD.showSuccess(withStatus: "Image uploaded")
            }
            
            completionHandler(true)
            
        })
        
    }
    
    
    func createNewLocation(locationName:String, locationPostcode:String, imgPath:String) {
        
        SVProgressHUD.show()
        
        let buid     = userModel?.currentBUID
        let key      = ref?.child("business").child(buid!).child("locations").childByAutoId().key
        
        let postLocation_business  = ["uid": userModel?.uid]
        
        let postLocation   = ["name": locationName,
                              "postcode": locationPostcode,
                              "image": imgPath,
                              "buid" : buid]
        
        
        let childUpdates = ["/business/\(buid!)/locations/\(key!)": postLocation_business,
                            "/locations/\(key!)": postLocation]
        
        
        
        ref.updateChildValues(childUpdates) { (error, ref) in
            
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            } else {
                
                SVProgressHUD.dismiss()
                
                for delegate in self.delegates {
                    
                    SVProgressHUD.showSuccess(withStatus: "Location created")
                    delegate.onLocationCreatedWithSuccess()
                }
            }
            
        }
        
    }
    
    func deleteLocationAt(index:Int) {
        
        let key = businessLocations[index].key
        let imgPath = businessLocations[index].imageFilePath
        let buid = userModel?.currentBUID
        
        ref.child("business").child(buid!).child("locations").child(key).removeValue()
        ref.child("locations").child(key).removeValue()
        
        imgBank?.deleteImageAt(path: imgPath)
        
        feedBank?.getFeedBy(businessID: buid!).deleteAllFeedsBy(locationId: key)
        
        businessLocations.remove(at: index)
        
        for delegate in self.businessDelegates {
            
            delegate.onChildDeleted(index: index)
            
        }
        
    }

}
