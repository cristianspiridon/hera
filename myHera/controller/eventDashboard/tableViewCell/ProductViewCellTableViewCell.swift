//
//  ProductViewCellTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 17/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension ProductViewCellTableViewCell:ProductBankDelegate {
 
    
    func onNewProductDiscovered(sender: ProductBankDelegate) {
        
    }
    
    func getClassKey() -> String {
        
        return classKey!
        
    }
    
    func onPriceChange(eventId: String, price: Double, sender: ProductBankDelegate) {
        
        labelPrice.text = convertToCurrency(value: price * Double((proxyModel?.times)!))
        
        if proxyModel?.times != 1 {
            
            quantity.text = "x \((proxyModel?.times)!) @ \(convertToCurrency(value: (barcode?.price)!))"
        }
        
       

    }
    
    func onProductTitleChange(title: String) {
        
        barcodeDescription.text = title
    }

    
    
}

class ProductViewCellTableViewCell: UITableViewCell {

    var proxyModel:ProductProxyModel?
    var barcode:ProductBankModel?
    
    @IBOutlet var labelPrice: UILabel!
    @IBOutlet var barcodeDescription: UILabel!
    @IBOutlet var labelSKU: UILabel!
    @IBOutlet var labelIndex: UILabel!
    @IBOutlet var quantity: UILabel!
    @IBOutlet var priceCenterY: NSLayoutConstraint!
    
    var classKey:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(model:ProductProxyModel, index:Int) {
        
        
        classKey = "\(Date().timeIntervalSince1970)"
        proxyModel = model
        
        
        
        if index < 10 {
            labelIndex.text = "00\(index)"
        } else if index < 100 {
            labelIndex.text = "0\(index)"
        } else {
            labelIndex.text = "\(index)"
        }
        
        labelSKU.text = model.sku
        
        barcode = productsBank?.getProductBy(sku: (proxyModel?.sku)!)
        labelPrice.text = convertToCurrency(value: ((barcode?.price)! * Double(model.times!)))
        onProductTitleChange(title: (barcode?.title)!)
        
        
        if model.times != 1 {
        
            let price = convertToCurrency(value: (barcode?.price)!)
            
            quantity.text = "x \(model.times) @ \(price)"
            priceCenterY.constant = -9
            
        } else {
            
            quantity.text = ""
            priceCenterY.constant = 0
            
        }
        
    }
    
    func convertToCurrency(value:Double) -> String {
 
        
        
        let cForm = NumberFormatter()
        cForm.usesGroupingSeparator = true
        cForm.numberStyle = .currency
        
        let priceString = cForm.string(from: NSNumber(value: value))
        
        
        return priceString!
        
    }
    

}
