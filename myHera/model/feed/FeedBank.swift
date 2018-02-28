//
//  FeedBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class FeedBank: NSObject {

    var stocktakes:[FeedBankObject] = [FeedBankObject]()
    
    func getFeedBy(businessID:String) -> FeedBankObject {
        
        print("FeedBankObject: get Feed by buid: \(businessID)")
        
        let i = stocktakes.index { (feedObj) -> Bool in
            
            return feedObj.key == businessID
            
        }
        
        if i != nil {
            
            return stocktakes[i!]
            
        } else {
            
            let newStocktakeEvent = FeedBankObject(key: businessID)
            stocktakes.append(newStocktakeEvent)
            
            return newStocktakeEvent
            
        }
        
    }
    
    
}
