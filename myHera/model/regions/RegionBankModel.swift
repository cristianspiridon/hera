//
//  RegionBankModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol RegionBankModelDelegate {
    
    func onRegionUpdate()
    
}

class RegionBankModel: NSObject {

    var key:String?
    
    var title:String?
    var quantity:Int?
    var totalValue:Double?
    var rangeIn:Int?
    var rangeOut:Int?
    var duration:Int?
    var progress:Double?
    var completedAreas:Int?
    
    var regionRef:DatabaseReference?
    
    var delegates:[RegionBankModelDelegate] = [RegionBankModelDelegate]()
    
    init (key:String, value:[String:Any]) {
        
        super.init()
        self.key = key
        updateWith(value:value)
        
        regionRef = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!).child(key)
    }
    
    
    
    func updateWith(value:[String:Any]) {
        
        print("region model \(value)")
        
        title = (value["title"] as! String)
        quantity = (value["quantity"] as! Int)
        rangeIn = (value["range-in"] as! Int)
        rangeOut = (value["range-out"] as! Int)
        totalValue = (value["stock-value"] as! Double)
        duration = (value["duration"] as! Int)
        progress = (value["progress"] as! Double)
        completedAreas = (value["completed-areas"] as! Int)
        
        
        let checkProgress =  Double(self.completedAreas!) / Double(self.numberOfAreas())
        let diff = self.progress! - checkProgress
        
        print("Region progress diff \(diff)")
        
        if diff.magnitude > 0.001 {
            
            self.update(progressValue: checkProgress)
            
        } else {
            
            for delegate in self.delegates {
                
                delegate.onRegionUpdate()
                
            }
            
        }
        
    }
    
    func removeFootPrint() {
        
        print("remove foot print region the new way")
        
        let stoktake_key = currentSelectedFeed?.key
        
        var footPrintRef:DatabaseReference = Database.database().reference()
        
        footPrintRef = footPrintRef.child("regions_footPrint").child(stoktake_key!).child(key!).child("footPrint")

        
        
        footPrintRef.observeSingleEvent(of: .value) { (snapshot) in
            
            print(snapshot)
            
            if snapshot.exists() {
                
                if let items:[String:Int] = snapshot.value as? [String:Int] {
                    
                    for (sku,value) in items {
                        
                
                        let tempB = productsBank?.getProductBy(sku: sku)
                
                        tempB?.updateRegionQuantity(quantity: -(value), stoktake_id: (currentSelectedFeed?.key)!, regionId: self.key!)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func update(progressValue: Double) {
        
         regionRef?.child("progress").setValue(progressValue)
    }
    
    func update(stockValue:Double) {
        
        regionRef?.child("stock-value").setValue(max(0,(totalValue! + stockValue)))
        
    }
    
    func update(quantityValue:Int) {
        
        regionRef?.child("quantity").setValue(max(0,(quantity! + quantityValue)))
        
    }
    
    func update(durationValue:Int) {
        
        regionRef?.child("duration").setValue(max(0, (duration! + durationValue)))
        
    }
    
    func update(completedAreaValue:Int) {
        
        regionRef?.child("completed-areas").setValue(completedAreas! + completedAreaValue)
        
    }
    
    func update(prg:Int) {
        
        print("update progress with \(prg)")
        
        let progressValue:Double = Double(1 / (Double(rangeOut!) - Double(rangeIn!) + 1) * Double(prg))
        print("\(progressValue)")
        
        regionRef?.child("progress").setValue(progress! + progressValue)
        
    }
    
    func addAreaDetails(areaModel:AreaBankModel) {
        
        update(stockValue:    (areaModel.totalValue)!)
        update(quantityValue: (areaModel.quantity)!)
        update(durationValue: (areaModel.duration)!)
        update(completedAreaValue: 1)
    }
    
    func substractAreaDetails(areaModel:AreaBankModel) {
        
        update(stockValue:    -(areaModel.totalValue)!)
        update(quantityValue: -(areaModel.quantity)!)
        update(durationValue: -(areaModel.duration)!)
        update(completedAreaValue: -1)
     
    }
    
    func numberOfAreas() -> Int {
        
        return rangeOut! - rangeIn! + 1
        
    }

    
}
