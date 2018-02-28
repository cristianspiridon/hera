//
//  FootPrintItem.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

protocol FootPrintItemDelegate {
    
    func onUpdate()
    
}

class FootPrintItem: NSObject {

    var key:String = ""
    var value:Int = 0
    
    var delegate:FootPrintItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
     init(key:String, value:Int) {
        
        super.init()
        
        self.key = key
        self.value = value
    }
    
    func updaetWith(newValue:Int) {
        
        value = newValue
        
        if delegate != nil {
            
            delegate?.onUpdate()
            
        }
        
    }
    
}
