//
//  ProductProxyModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 22/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class ProductProxyModel: NSObject {
    
    var key:String?
    var sku:String?
    var model:ProductBankModel?
    
    var times:Int = 1
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    init(key:String, sku:String, times:Int) {
        
        super.init()
        
        self.key = key
        self.sku = sku
        self.times = times
        
        model = productsBank?.getProductBy(sku: sku)
        
    }


}
