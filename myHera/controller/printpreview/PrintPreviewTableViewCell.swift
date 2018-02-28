//
//  PrintPreviewTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 30/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension PrintPreviewTableViewCell:FootPrintItemDelegate {
    func onUpdate() {
        
        stockQuantityLabel.text = "\(convertToNumber(value: (footPrintModel?.value)!))"
        
        
    }
}

extension PrintPreviewTableViewCell:ProductBankDelegate {
    func onPriceChange(eventId: String, price: Double, sender: ProductBankDelegate) {
        
        priceLabel.text = convertToCurrency(value: price)
        
    }
    
    func onProductTitleChange(title: String) {
        
        productLabel.text = title
        
    }
    
    func onNewProductDiscovered(sender: ProductBankDelegate) {
        
    }
    
    func getClassKey() -> String {
        
        return classKey!
    }
    
    
}

class PrintPreviewTableViewCell: UITableViewCell {

    @IBOutlet var stockQuantityLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var skuLabel: UILabel!
    @IBOutlet var productLabel: UILabel!
    
    var productModel:ProductBankModel?
    var classKey:String?
    
    var footPrintModel:FootPrintItem?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(model:FootPrintItem) {
        
        footPrintModel = model
        
        classKey = "\(Date().timeIntervalSince1970)"
        
        skuLabel.text = "SKU: \(model.key)"
        stockQuantityLabel.text = "\(convertToNumber(value: (model.value)))"
        
        productModel = productsBank?.getProductBy(sku: model.key)
        productModel?.delegates.append(self)
        
        model.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func convertToNumber(value:Int) -> String {
        
        let cForm = NumberFormatter()
        cForm.usesGroupingSeparator = true
        cForm.numberStyle = .decimal
        
        let priceString = cForm.string(from: NSNumber(value: value))
        
        
        return priceString!
        
    }
    
    
    func convertToCurrency(value:Double) -> String {
        
        
        
        let cForm = NumberFormatter()
        cForm.usesGroupingSeparator = true
        cForm.numberStyle = .currency
        
        let priceString = cForm.string(from: NSNumber(value: value))
        
        
        return priceString!
        
    }

}
