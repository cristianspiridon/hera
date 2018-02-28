//
//  Participant.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

protocol ParticipantDelegate {
    
    func onUpdate()
    
}

class Participant: NSObject {

    
    var uid:String?
    var duration:Int?
    var quantity:Int?
    
    var delegate:ParticipantDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    init(uid:String, value:[String:Any]) {
        
        super.init()
        
        self.uid = uid
        
        updateWith(value: value, dispatch: false)
        
    }
    
    func updateWith(value:[String:Any], dispatch:Bool = true) {
        
        self.duration = value["duration"] as? Int
        self.quantity = value["quantity"] as? Int
        
        
        if delegate != nil && dispatch == true {
            
            delegate?.onUpdate()
            
        }
        
    }
    
}
