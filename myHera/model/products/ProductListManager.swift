//
//  ProductListManager.swift
//  myHera
//
//  Created by Cristian Spiridon on 17/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol ProductListManagerDelegate {
    
    func onProductChildAdded()
    func onProductChildDeleted(index:Int)
    
}


class ProductListManager: NSObject {
    
    var key:String?
    var ref:DatabaseReference?
    var listRef:DatabaseReference?
    
    var handleAdded:UInt = 0
    var handleChange:UInt = 0
    var handleDeleted:UInt = 0
    
    var barcodes:[ProductProxyModel] = [ProductProxyModel]()
    
    var delegate:ProductListManagerDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    init(key:String) {
        
        super.init()
        self.key = key
        ref = Database.database().reference()
        
        listRef = ref?.child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("area_contents").child((currentSelectedRegion?.key)!).child(key)
        
        setupListener()
        
    }
    
    func setupListener() {
        
        handleAdded = (listRef!.observe(.childAdded, with: { (snapshot) in
            
            if snapshot.exists() {
                
                if snapshot.key != "footPrint" {
                    
                    if let dict:[String:Any] = snapshot.value as? [String:Any] {
                        
                        let newProduct:ProductProxyModel = ProductProxyModel(key: snapshot.key , sku: dict["sku"] as! String, times: dict["qty"] as! Int)
                        
                        self.barcodes.insert(newProduct, at: 0)
                        
                        if self.delegate != nil {
                            
                            self.delegate?.onProductChildAdded()
                            
                        }
                        
                    }
                }
            }
            
        }))
        
        
        handleDeleted = (listRef!.observe(.childRemoved, with: { (snapshot) in
            
            if snapshot.key != "footPrint" {
                
                let index = self.barcodes.index(where: { (barcode) -> Bool in
                    
                    return barcode.key == snapshot.key
                    
                })
                
                if index != nil {
                    
                    self.barcodes.remove(at: index!)
                    
                    if self.delegate != nil {
                        
                        self.delegate?.onProductChildDeleted(index:index!)
                        
                    }
                    
                }
                
            }}))
        
        
    }
    
    
    func addProductToList(model:ProductBankModel, times:Int) {
        
        updateQuantity(with: times)
        updateTotals(with: model.price * Double(times))
        
        let newProdId = listRef?.childByAutoId().key
        
        let postItem:[String:Any] = ["sku":model.sku!,"qty": times]
        
        listRef?.child(newProdId!).updateChildValues(postItem)
        
        model.updateQuantityWith(quantity: times, stoktake_id: (currentSelectedFeed?.key)!, regionId: (currentSelectedRegion?.key)!, areaId: (currentSelectedArea?.key)!)
        
    }
    
    func updateTotals(with:Double) {
        
        var totalValue:Double = with
        
        for barcode in barcodes {
            
            totalValue = totalValue + (barcode.model?.price)! * Double(barcode.times)
            
        }
        
        currentSelectedArea?.update(totalValue: totalValue)
        
        
    }
    
    func updateQuantity(with:Int) {
        
        var totalQty:Int = with
        
        for barcode in barcodes {
            
            totalQty = totalQty + barcode.times
            
        }
        
        currentSelectedArea?.update(quantity: totalQty)
        
    }
    
    
    func deleteProduct(at:Int){
        
        deleteProduct(product: barcodes[at])
        
    }
    
    func deleteProduct(product:ProductProxyModel) {
        
        updateQuantity(with: -(product.times))
        
        let prdModel = productsBank?.getProductBy(sku: product.sku!)
        let price = prdModel?.price
        
        updateTotals(with: -(price! * Double(product.times)))
        
        listRef?.child(product.key!).removeValue()
        
        prdModel?.updateQuantityWith(quantity:  -(product.times), stoktake_id: (currentSelectedFeed?.key)!, regionId: (currentSelectedRegion?.key)!, areaId: (currentSelectedArea?.key)!)
        
    }
}

