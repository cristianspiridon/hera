//
//  LocationBankModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol LocationBankModelDelegate {
    
    func onEventCreatedWithSucces()
    func onLocationDataReady()
    func onImageReady()
}

extension LocationBankModel:ImageObjectDelegate {
    
    func onImageLoaded() {
        
        self.image = imageLoader?.image
        
        for delegate in self.delegates {
            
            delegate.onImageReady()
            
        }
    }
    
}


class LocationBankModel: NSObject {

    var key:String = ""
    
    var buid:String = ""
    var imageFilePath:String = ""
    var name:String = ""
    var postcode:String = ""
    var image:UIImage?
    
    var ref:DatabaseReference?
    var exists:Bool = false
    var imageLoader:ImageObject?
    var delegates:[LocationBankModelDelegate] = [LocationBankModelDelegate]()
    
    var handle:UInt?
    
    init(key:String){
        
        super.init()
        
        self.key = key
        ref = Database.database().reference()
        
        handle = ref?.child("locations").child(key).observe(.value, with: { (snapshot) in
            
            self.exists = true
            
            if snapshot.exists() {
                let value = snapshot.value as! [String:Any]
                
                self.buid = (value["buid"] as? String)!
                self.name = (value["name"] as? String)!
                self.postcode = (value["postcode"] as? String)!
                
                
                if self.imageFilePath != value["image"]! as? String{
                    
                    self.imageFilePath = (value["image"]! as? String)!
                    self.getImage(at:self.imageFilePath)
                }
                
            }
        
            for delegate in self.delegates {
                
                delegate.onLocationDataReady()
                
            }
            
        })
        
       
    }
    
    func updateLocation(name:String){
        
        self.name = name
        
        ref?.child("locations").child(key).child("name").setValue(name)
        SVProgressHUD.showSuccess(withStatus: "Location name updated")
    }
    
    func updateLocation(postcode:String){

        self.postcode = postcode
    
    ref?.child("locations").child(key).child("postcode").setValue(postcode)
         SVProgressHUD.showSuccess(withStatus: "Location address updated")

    }
    
    func getImage(at:String) {
        
        imageLoader = imgBank?.getImageObjectByFilePath(filePath: at)
        imageLoader?.delegates.append(self)
        
    }
    
    func addNewStocktakeEvent(eventName:String, eventDate:String) {
        
        let eventKey = ref?.child("locations").child(key).child("stocktakes").childByAutoId().key
        
        let postNewEvent    = ["name": eventName,
                               "eventDate": eventDate,
                               "uid" : userModel?.uid as! String,
                               "duration":0,
                               "progress":0,
                               "stock-value":0,
                               "quantity":0,
                               "total-areas":0,
                               "completed-areas":0] as [String : Any]
        
        
        let businessFeedPost = ["location" : self.key]
        
        
        let childUpdates = ["/stocktakes/\(self.key)/\(eventKey!)": postNewEvent,
                            "/business/\((userModel?.currentBUID)!)/feed/\(eventKey!)":businessFeedPost]
        
        
        
        ref?.updateChildValues(childUpdates) { (error, ref) in
            
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            } else {
                
                SVProgressHUD.showSuccess(withStatus: "Event created with success")
                
                for delegate in self.delegates {
                    
                    delegate.onEventCreatedWithSucces()
                }
            }
            
        }
        
        
    }
    
    
}
