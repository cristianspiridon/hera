//
//  AreasBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AreasBank: NSObject {

    var areas:[AreaListManager] = [AreaListManager]()
    
    
    override init() {
        super.init()
        
    }
    
    func getAreaListBy(key:String) -> AreaListManager {
        
        let i = areas.index { (area) -> Bool in
            
            return area.key! == key
        }
        
        if i != nil {
            
            return areas[i!]
            
        } else {
            
            let newAreaList = AreaListManager(key:key)
            areas.append(newAreaList)
            
            return newAreaList
        }
        
    }
    
}
