//
//  FeedBankModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol FeedBankModelDelegate {
    
    func onUpdate()
    func onLocationImageReady(image:UIImage)
    
}

extension FeedBankModel:LocationBankModelDelegate {
    func onEventCreatedWithSucces() {
        
    }
    
    
    func onImageReady() {
        
        if let image = locationModel?.image {
            
            for delegate in self.delegates {
                
                delegate.onLocationImageReady(image: image)
                
            }
        }
        
    }
    
    
    func onLocationDataReady() {
        
        locationName = (locationModel?.name)!
        
        for delegate in self.delegates {
            
            delegate.onUpdate()
            
        }
        
    }
    
}

class FeedBankModel: NSObject {
    
    var key:String?
    
    var eventDate:String? = ""
    var locationId:String? = ""
    var locationName:String = ""
    var name:String? = ""
    var uid:String? = ""
    var ref:DatabaseReference?
    var eventReference:DatabaseReference?
    
    var quantity:Int?
    var totalValue:Double?
    var duration:Int?
    var progress:Double?
    var totalAreas:Int?
    var completedAreas:Int?

    var delegates:[FeedBankModelDelegate] = [FeedBankModelDelegate]()
    var exists:Bool = false
    
    var handle:UInt?
    var locationModel:LocationBankModel?
    
    init(key:String, value:[String:String]) {
        
        super.init()
        
        self.key = key
        self.locationId = value["location"]
        
        ref = Database.database().reference()
        eventReference = ref?.child("stocktakes").child(locationId!).child(key)
        
        handle = ref?.child("stocktakes").child(locationId!).child(key).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                let value = snapshot.value as! [String:Any]
                
                self.eventDate   = (value["eventDate"] as! String)
                self.name        = (value["name"] as! String)
                self.uid         = (value["uid"] as! String)
                self.totalAreas  = (value["total-areas"] as! Int)
                self.quantity = (value["quantity"] as! Int)
                self.totalValue = (value["stock-value"] as! Double)
                self.duration = (value["duration"] as! Int)
                self.progress = (value["progress"] as! Double)
                self.completedAreas = (value["completed-areas"] as! Int)
                
                print(snapshot)
                
                var checkProgress =  Double(self.completedAreas!) / Double(self.totalAreas!)
                
                if checkProgress.isNaN {
                    checkProgress = 0
                }
                
                let diff = self.progress! - checkProgress
                
                print("diff is \(diff.magnitude)")
                
                if diff.magnitude > 0.001 {
                    
                    self.update(progressValue: -diff)
                    
                }
                
                
                self.exists = true
            }

            self.locationModel = locationsBank?.getLocationBy(locationID: self.locationId!)
            self.locationModel?.delegates.append(self)
            
            if self.locationModel?.exists == true {
                
               self.onLocationDataReady()
               self.onImageReady()
                
            }
            
        })
    }
    
    
    func updateWith(name:String) {
        
        if name != self.name {
    
            ref?.child("stocktakes").child(locationId!).child(key!).child("name").setValue(name)
            
        }
        
    }
    
    func updateWith(date:String) {
        
        if date != eventDate {
            
            ref?.child("stocktakes").child(locationId!).child(key!).child("eventDate").setValue(date)
            
        }
    }
    
    func update(stockValue:Double) {
        
        eventReference?.child("stock-value").setValue(max(0, (totalValue! + stockValue)))
        
    }
    
    func update(quantityValue:Int) {
        
        eventReference?.child("quantity").setValue(max(0, (quantity! + quantityValue)))
        
    }
    
    func update(durationValue:Int) {
        
        eventReference?.child("duration").setValue(max(0,(duration! + durationValue)))
        
    }
    
    
    func update(progressValue:Double) {
        
        print("Update progress to \(progressValue)")
        
        var prgValue = progressValue
        
        if progressValue.isInfinite {
            
            prgValue = 0
            
        }
        
        if progress != nil {
            
            eventReference?.child("progress").setValue(progress! + prgValue)
            
        }
        

        
    }
    
    func update(completed:Int) {
        
        eventReference?.child("completed-areas").setValue(completedAreas! + completed)
        
    }
    
    
    

    func update(totalAreasValue:Int) {
        
          eventReference?.child("total-areas").setValue(totalAreas! + totalAreasValue)
    }
    
    func addAreaDetails(areaModel:AreaBankModel) {
        
        update(stockValue:    (areaModel.totalValue)!)
        update(quantityValue: (areaModel.quantity)!)
        update(durationValue: (areaModel.duration)!)
        update(progressValue: 1/Double(totalAreas!))
        update(completed: 1)
        
        updateParticipantInfo(areaModel: areaModel)
    }
    
    func substractAreaDetails(areaModel:AreaBankModel) {
        
        update(stockValue:    -(areaModel.totalValue)!)
        update(quantityValue: -(areaModel.quantity)!)
        update(durationValue: -(areaModel.duration)!)
        update(progressValue: -1/Double(totalAreas!))
        update(completed: -1)
        
        updateParticipantInfo(areaModel: areaModel, add: false)
    }
    
    func updateParticipantInfo(areaModel:AreaBankModel, add:Bool = true) {
        
        print("update participant info")
        
        let userRef  = ref?.child("participants").child(key!).child(areaModel.uid!)
        
        userRef?.observeSingleEvent(of: .value) { (snapshot) in
            
            var newQty:Int = add == true ? areaModel.quantity! : -(areaModel.quantity!)
            var newDuration:Int = add == true ? areaModel.duration! : -(areaModel.duration!)
            
            if snapshot.exists() {
                
                
                if let dict:[String:Int] = snapshot.value as? [String:Int]{
                    
                    newQty      += dict["quantity"]!
                    newDuration += dict["duration"]!
                    
                }
                
            }
            
            newQty = max(0, newQty)
            newDuration = max(0, newDuration)
            
            let postNewData = ["quantity": newQty,
                               "duration": newDuration]
            
            userRef?.setValue(postNewData)
            
        }
        
    }
    
    func hasAdminRoles() -> Bool{
        
        return userModel?.currentRole == "owner" || userModel?.currentRole == "manager"
        
    }
  

}
