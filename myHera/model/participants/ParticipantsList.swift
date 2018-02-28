//
//  ParticipantsList.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol ParticipantsListDelegate {
    
    func onParticipantChildAdded()
    func onParticipantFootPrintDeleted(index:Int)
}


class ParticipantsList: NSObject {
    
    var dataRef:DatabaseReference?
    var key:String?
    var participants:[Participant] = [Participant]()
    var delegates:[ParticipantsListDelegate] = [ParticipantsListDelegate]()
    
    var handleAdded:   UInt = 0
    var handleDeleted: UInt = 0
    var handleChange:  UInt = 0
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    
    func removeAllObservers() {
        
        dataRef?.removeAllObservers()
        
    }
    
    
    init(feedKey:String) {
        
        super.init()
        
        self.key = feedKey
        
        dataRef = Database.database().reference()
        dataRef = dataRef?.child("participants").child((feedKey))
        
        participants = [Participant]()
        
        
        
        handleAdded = (dataRef?.observe(.childAdded, with: { (snapshot) in
            
            let newParticipant:Participant = Participant(uid: snapshot.key, value: snapshot.value as! [String:Any])
            
            self.participants.append(newParticipant)
            
            for delegate in self.delegates {
                
                delegate.onParticipantChildAdded()
                
            }
            
        }))!
        
        handleChange = (dataRef?.observe(.childChanged, with: { (snapshot) in
            
            let i = self.participants.index(where: { (participant) -> Bool in
                
                return participant.uid == snapshot.key
                
            })
            
            if i != nil {
                
                self.participants[i!].updateWith(value: snapshot.value as! [String:Any])
                
            }
            
        }))!
        
        handleDeleted = (dataRef?.observe(.childRemoved, with: { (snapshot) in
            
            let index = self.participants.index(where: { (participant) -> Bool in
                
                return participant.uid == snapshot.key
                
            })
            
            if index != nil {
                
                self.participants.remove(at: index!)
                
                for delegate in self.delegates {
                    
                    delegate.onParticipantFootPrintDeleted(index:index!)
                    
                }
                
            }
            
        }))!
        
        
    }

}
