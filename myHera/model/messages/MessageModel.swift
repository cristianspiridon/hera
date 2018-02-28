//
//  MessageModel.swift
//  myHera
//
//  Created by Cristian Spiridon on 29/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

class MessageModel: NSObject {

    var value:[String:String]!
    var key:String?
    var dateStr:String?
    var message:String?
    var uid:String?
    
    init(key:String, value:[String:String]) {
        
        super.init()
        
        self.key = key
        self.value = value
      
        dateStr = value["date"]!
        message = value["message"]!
        uid     = value["uid"]!
        
        
    }
    
}
