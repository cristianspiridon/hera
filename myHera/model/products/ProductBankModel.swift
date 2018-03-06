//
//  ProductBankModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 13/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol ProductBankDelegate {
    
    func onPriceChange(eventId:String, price:Double, sender:ProductBankDelegate)
    func onProductTitleChange(title:String)
    func onNewProductDiscovered(sender:ProductBankDelegate)
    
    func getClassKey() -> String
    
}


class ProductBankModel: NSObject {
    
    
    var exists:Bool = false
    var ref:DatabaseReference?
    
    var sku:String?
    var title:String?
    var price:Double?
    
    var delegates:[ProductBankDelegate] = [ProductBankDelegate]()
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    
    init(key:String,dict:[String:Any]?) {
        
        super.init()
        
        self.sku = key
        
        if dict != nil {
            
            exists = true
            
            title  = dict?["title"] as? String
            price  = dict?["price"] as? Double
            
        }
        
    }
    
    func removeDelegate(sender:ProductBankDelegate) {
        
        let i = delegates.index { (delegate) -> Bool in
            
            delegate.getClassKey() == sender.getClassKey()
            
        }
        
        if i != nil {
            print("remove delegate at index \(String(describing: i))")
            delegates.remove(at: i!)
            
            print("Delegates for barcode \(sku!) \(delegates)")
        }
        
    }
    
    func updateQuantityWith(quantity:Int, stoktake_id:String, regionId:String, areaId:String) {
        
        print("upadate foot print for \(areaId) \(regionId) \(stoktake_id) \(quantity)")
        
        ref = Database.database().reference()
        
        let printRef = self.ref?.child((currentSelectedFeed?.locationId)!).child(stoktake_id).child("areas_footPrint").child(regionId).child(areaId).child("footPrint").child(sku!)
        
        printRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("area foot print ref \(snapshot)")
            
            var newValue = quantity
            
            if snapshot.exists() {
                
                let qty = snapshot.value as! Int
                
                newValue = qty + quantity
                
            }
            
            newValue = max(0, newValue)
            
            if newValue == 0 {
                
                printRef?.removeValue()
                
            } else {
                
                printRef?.setValue(newValue)
            }
            
            
            
        })
        
        updateRegionQuantity(quantity: quantity, stoktake_id: stoktake_id, regionId: regionId)
        
    }
    
    func updateRegionQuantity(quantity:Int, stoktake_id:String, regionId:String) {
        
        let printRef = self.ref?.child("regions_footPrint").child(stoktake_id).child(regionId).child("footPrint").child(sku!)
        
        
        printRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newValue = quantity
            
            if snapshot.exists() {
                
                let qty = snapshot.value as! Int
                
                newValue = (qty + quantity)
                
            }
            
            newValue = max(0, newValue)
            
            if newValue != 0 {
                
                printRef?.setValue(newValue)
                
            } else {
                
                printRef?.removeValue()
            }
            
            
        })
        
        updateStockQuantity(quantity: quantity, stoktake_id: stoktake_id)
        
    }
    
    func updateStockQuantity(quantity:Int, stoktake_id:String) {
        
        let printRef =  self.ref?.child("stocktake_footPrint").child((currentSelectedFeed?.locationId)!).child(stoktake_id).child("footPrint").child(sku!)
        
        printRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newValue = quantity
            
            if snapshot.exists() {
                
                let qty = snapshot.value as! Int
                
                newValue = qty + quantity
                
            }
            
            newValue = max(0, newValue)
            
            if newValue != 0 {
                
                printRef?.setValue(newValue)
                
            } else {
                
                printRef?.removeValue()
                
            }
            
        })
        
    }
    
    
}

