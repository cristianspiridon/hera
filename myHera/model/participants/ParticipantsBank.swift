//
//  ParticipantsBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class ParticipantsBank: NSObject {

    
    
    var list:[ParticipantsList] = [ParticipantsList]()
 
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    func getParticipantsBy(feedId:String) -> ParticipantsList {
        
        let i = list.index { (participant) -> Bool in
            
            return participant.key! == feedId
        }
        
        if i != nil {
            
            return list[i!]
            
        } else {
            
            let newList = ParticipantsList(feedKey:feedId)
            
            list.append(newList)
            
            return newList
        }
        
        
    }
    
}
