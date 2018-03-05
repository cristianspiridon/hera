//
//  ProductBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 13/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

class ProductBank: NSObject {
    
    var products:[ProductBankModel] = [ProductBankModel]()
    var ref:DatabaseReference?
    
    var barcodesDict:[String:Any] = [String:Any]()
    var addedDict:[String:Any] = [String:Any]()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    func loadEntireBarcodeDataOffline() {
        
        print("Load Barcodes Data")
        
        barcodesDict = [String:Any]()
        addedDict    = [String:Any]()
        
        loadInitialBarcodeList()
        loadAddedBarcodes()
        
    }
    
    func loadAddedBarcodes() {
        
        let locID  = currentSelectedFeed?.locationId
        let feedID = currentSelectedFeed?.key
        
        ref = Database.database().reference()
        
        ref?.child(locID!).child(feedID!).child("addedBarcodes").observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                if let temp = snapshot.value as? [String: Any] {
                    
                    self.addedDict = temp
                    
                }
                
            }
            
        })
    }
    
    func loadInitialBarcodeList() {
        
        let locID  = currentSelectedFeed?.locationId
        let feedID = currentSelectedFeed?.key
        
        
        ref = Database.database().reference()
        ref?.child(locID!).child(feedID!).child("barcodes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                if let dict = snapshot.value as? [String:Any] {
                    
                    self.barcodesDict = dict
                    
                }
                
            }
            
        })
        
    }
    
    func getProductBy(sku:String) -> ProductBankModel? {
        
        let i = products.index { (product) -> Bool in
            
            return product.sku! == sku
        }
        
        if i != nil {
            
            return products[i!]
            
        } else {
            
            var concatenated = barcodesDict
            concatenated.update(other: addedDict)
            
            if let skuData = concatenated[sku] as? [String:Any] {
                
                let newProduct = ProductBankModel(key:sku, dict:skuData)
                products.append(newProduct)
                return newProduct
                
                
            }  else {
                
                let newProduct = ProductBankModel(key:sku, dict:nil)
                products.append(newProduct)
                return newProduct
                
            }
            
        }
    }
    
    func removeProduct(key:String) {
        
        let i = products.index { (product) -> Bool in
            
            return product.sku! == key
        }
        
        if i != nil {
            
            products.remove(at: i!)
            
        }
    }
    
    
    
}
