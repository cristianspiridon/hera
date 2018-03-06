//
//  AreaBankModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol AreaBankModelDelegate {
    
    func onAreaUpdate()
    func getClassKey() -> String
    
}



class AreaBankModel: NSObject {
    
    var key:String?
    
    var uid:String?
    var quantity:Int?
    var totalValue:Double?
    var duration:Int?
    var progress:String?
    var ref:DatabaseReference?
    var areaRef:DatabaseReference?
    
    var delegates:[AreaBankModelDelegate] = [AreaBankModelDelegate]()
    
    
    init (key:String, value:[String:Any]) {
        
        super.init()
        
        self.key = key
        
        updateWith(value:value)
        
        ref = Database.database().reference()
        areaRef = ref?.child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("areas").child((currentSelectedRegion?.key)!).child(key)
    }
    
    func updateWith(value:[String:Any]) {
        
        
        self.uid = value["uid"] as? String
        quantity = (value["quantity"] as! Int)
        totalValue = (value["stock-value"] as! Double)
        duration = (value["duration"] as! Int)
        progress = (value["progress"] as! String)
        
        for delegate in self.delegates {
            
            delegate.onAreaUpdate()
            
        }
        
    }
    
    func removeFootPrint() {
        
        print("Remove foot print new way ")
        
        let stoktake_key = currentSelectedFeed?.key
        let region_key   = currentSelectedRegion?.key
        
        let footPrintRef:DatabaseReference = (self.ref?.child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("areas_footPrint").child(region_key!).child(key!).child("footPrint"))!
        
        footPrintRef.observeSingleEvent(of: .value) { (snapshot) in
            
            print(snapshot)
            
            if snapshot.exists() {
                
                if let items:[String:Int] = snapshot.value as? [String:Int] {
                    
                    for (sku,value) in items {
                        
                        
                        let tempB = productsBank?.getProductBy(sku: sku)
                        let qty:Int = value
                        
                        tempB?.updateQuantityWith(quantity: -(qty), stoktake_id: (currentSelectedFeed?.key)!, regionId: (currentSelectedRegion?.key)!, areaId: self.key!)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    func update(status:String) {
        
        areaRef?.child("progress").setValue(status)
    }
    
    func update(quantity:Int) {
        
        areaRef?.child("quantity").setValue(quantity)
    }
    
    func update(totalValue:Double) {
        
        areaRef?.child("stock-value").setValue(totalValue)
    }
    
    func update(duration:Int) {
        
        areaRef?.child("duration").setValue(duration)
    }
    
    
    func removeDelegate(sender:AreaBankModelDelegate) {
        
        let i = delegates.index { (delegate) -> Bool in
            
            delegate.getClassKey() == sender.getClassKey()
            
        }
        
        if i != nil {
            print("remove delegate at index \(String(describing: i))")
            delegates.remove(at: i!)
            
            print("Delegates for area \(key!) \(delegates)")
        }
        
    }
    
    
}

