//
//  FeedBankObject.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


protocol FeedBankObjectDelegate {
    
    func onChildAdded()
    func onChildDeleted(index:Int)
    
}


class FeedBankObject: NSObject {
    
    var key:String?
    var exists = false
    var handleAdded:UInt?
    var handleDeleted:UInt?
    
    var ref:DatabaseReference?
    var feedRef:DatabaseReference?
    
    var feeds:[FeedBankModel] = [FeedBankModel]()
    
    var delegate:FeedBankObjectDelegate?
    
    init(key:String) {
        
        super.init()
        self.key = key
        
        setupListeners()
        
    }
    
    func setupListeners() {
        
        if exists == false {
            
            ref = Database.database().reference()
            feedRef = ref?.child("business").child(key!).child("feed")
            
            handleAdded = feedRef?.observe(.childAdded, with: { (snapshot) in
                
                
                if snapshot.exists() {
                    
                    let model:FeedBankModel = FeedBankModel(key: snapshot.key, value: snapshot.value as! [String:String])
                    self.feeds.append(model)
                    
                    self.delegate?.onChildAdded()
                }
                
                print("we have feed \(snapshot)")
                
            })
            
            handleDeleted = feedRef?.observe(.childRemoved, with: { (snapshot) in
                
                
                let index = self.feeds.index(where: { (feed) -> Bool in
                    
                    return feed.key == snapshot.key
                    
                })
                
                if index != nil {
                    
                    self.feeds.remove(at: index!)
                    self.delegate?.onChildDeleted(index:index!)
                    
                }
                
            })
            
        }
        
    }
    
    
    func deleteAllFeedsBy(locationId:String) {
        
        
        for feed in feeds {
            
            if feed.locationId == locationId {
                
                deleteFeed(feed: feed)
                
            }
            
        }
        
    }
    
    
    
    func deleteFeedAt(index:Int) {
        
        deleteFeed(feed: feeds[index])
        
    }
    
    func deleteFeed(feed:FeedBankModel) {
        
        let feedKey = feed.key!
        let locationKey = feed.locationId!
        let buid = feed.locationModel?.buid
        
        
        ref?.child("business").child(buid!).child("feed").child(feedKey).removeValue()
        ref?.child("stocktakes").child(locationKey).child(feedKey).removeValue()
        ref?.child("event-messages").child(feedKey).removeValue()
        
        ref?.child(locationKey).child(feedKey).removeValue()
        
    }
    
}

