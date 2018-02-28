//
//  RegionBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegionBank: NSObject {
    
    var regions:[RegionsList] = [RegionsList]()
    
    
    override init() {
        super.init()
        
    }
    
    func getRegionsBy(stocktakeId:String) -> RegionsList {
        
        let i = regions.index { (regionList) -> Bool in
            
            return regionList.key! == stocktakeId
        }
        
        if i != nil {
            
            return regions[i!]
            
        } else {
            
            let newRegionList = RegionsList(key:stocktakeId)
            regions.append(newRegionList)
            return newRegionList
        }
    
    }

}
