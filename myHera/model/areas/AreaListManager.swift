//
//  AreaListManager.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class AreaListManager: NSObject {

    var key:String?
    var areas:[AreaBankModel]?
    var ref:DatabaseReference?
    
    var handleAdded:   UInt = 0
    var handleDeleted: UInt = 0
    var handleChange:  UInt = 0
    
    init(regionKey:String) {
    
        super.init()
        key = regionKey
        
        setupHandlers()
    }
    
    func setupHandlers() {
        
    }
    
    
    
    
}
