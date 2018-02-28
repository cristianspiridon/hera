//
//  MessagesBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class MessagesBank: NSObject {
    
    var messages:[MessagesBankObject] = [MessagesBankObject]()
    
    override init() {
        
    }
    
    
    // get all the messages by stocktake id
    
    func getMessagesFor(stocktakeId:String) -> MessagesBankObject {
       
        let i = messages.index { (msgObj) -> Bool in
            
            return msgObj.key == stocktakeId
            
        }
        
        if i != nil {
            
            print("Found it")
            return messages[i!]
            
        } else {
            
            print("Create new messages bank")
            let newMessageBankObject = MessagesBankObject(key: stocktakeId)
            messages.append(newMessageBankObject)
            
            return newMessageBankObject
            
        }
        
    }
    

}
