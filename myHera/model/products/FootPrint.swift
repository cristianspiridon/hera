//
//  FootPrint.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol FootPrintDelegate {
    
    func onFootPrintChildAdded()
    func onFootPrintDeleted(index:Int)
}

class FootPrint: NSObject {
    
    var footPrintRef:DatabaseReference?
    
    var items:[FootPrintItem] = [FootPrintItem]()
    var delegates:[FootPrintDelegate] = [FootPrintDelegate]()
    
    var handleAdded:   UInt = 0
    var handleDeleted: UInt = 0
    var handleChange:  UInt = 0
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    
    func removeAllObservers() {
        
        footPrintRef?.removeAllObservers()
        
    }

    
    init(feed:FeedBankModel) {
        
        super.init()
        
        
        footPrintRef = Database.database().reference()
        footPrintRef = footPrintRef?.child("stocktake_footPrint").child((feed.locationId)!).child((feed.key!)).child("footPrint")
        
        items = [FootPrintItem]()
        
        
        
        handleAdded = (footPrintRef?.observe(.childAdded, with: { (snapshot) in
            
            let newItem:FootPrintItem = FootPrintItem(key: snapshot.key, value: snapshot.value as! Int)
            
            self.items.append(newItem)
            
            for delegate in self.delegates {
                
                delegate.onFootPrintChildAdded()
                
            }
            
        }))!
        
        handleChange = (footPrintRef?.observe(.childChanged, with: { (snapshot) in
            
            let i = self.items.index(where: { (item) -> Bool in
                
                return item.key == snapshot.key
                
            })
            
            if i != nil {
                
                self.items[i!].updaetWith(newValue: snapshot.value as! Int)
                
            }
            
        }))!
        
        handleDeleted = (footPrintRef?.observe(.childRemoved, with: { (snapshot) in
            
            let index = self.items.index(where: { (item) -> Bool in
                
                return item.key == snapshot.key
                
            })
            
            if index != nil {
                
                self.items.remove(at: index!)
                
                for delegate in self.delegates {
                    
                    delegate.onFootPrintDeleted(index:index!)
                    
                }
                
            }
            
        }))!
        
        
    }
    
}
