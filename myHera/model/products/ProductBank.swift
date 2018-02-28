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
        
        loadInitialBarcodeList()
        loadAddedBarcodes()
        
    }
    
    func loadAddedBarcodes() {
        
        let locID = "-L2bqdQjbz4uw91PRKYc"
        
        ref = Database.database().reference()
      
        ref?.child(locID).child("addedBarcodes").observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
             
                if let temp = snapshot.value as? [String: Any] {
                 
                    self.addedDict = temp
                    
                }
                
            }
            
        })
    }
    
    func loadInitialBarcodeList() {
        
        let locID = "-L2bqdQjbz4uw91PRKYc"
        
        ref = Database.database().reference()
        ref?.child(locID).child("barcodes").observeSingleEvent(of: .value, with: { (snapshot) in
       
            if snapshot.exists() {
                
            
            print("We have Barcodes Database \(snapshot.childrenCount)")
            
            if let dict = snapshot.value as? [String:Any] {
                
                self.barcodesDict = dict
                
            }
                
            }
            
        })
        
    }
    
    func getProductBy(sku:String) -> ProductBankModel? {
        
        print("Search for product \(sku)")
        
        let i = products.index { (product) -> Bool in
            
            return product.sku! == sku
        }
        
        if i != nil {
            
            return products[i!]
            
        } else {
            
            print("database from memory")
            
            var concatenated = barcodesDict
            concatenated.update(other: addedDict)
            
            print("barcodesDict:\(barcodesDict.count) addedDict:\(addedDict.count) concatenated:\(concatenated.count)")
            
            if let skuData = concatenated[sku] as? [String:Any] {
                
                let newProduct = ProductBankModel(key:sku, dict:skuData)
                products.append(newProduct)
                return newProduct
                
                
            }  else {
                
                print("database create new one")
            
                let newProduct = ProductBankModel(key:sku, dict:nil)
                products.append(newProduct)
                return newProduct 
                
                return nil
                
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
