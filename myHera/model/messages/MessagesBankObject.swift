//
//  MessagesBankObject.swift
//  myHera
//
//  Created by Cristian Spiridon on 03/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol MessagesBankDelegate {
    
    func onChildAdded()
    func onChildDeleted(index:Int)
    
}

class MessagesBankObject: NSObject {

    var key:String?
    var messages:[MessageModel] = [MessageModel]()
    var exists = false
    
    var handleValue:   UInt = 0
    var handleAdded:   UInt = 0
    var handleDeleted: UInt = 0
    
    var ref:DatabaseReference!
    var messagesRef:DatabaseReference!
    var delegates:[MessagesBankDelegate] = [MessagesBankDelegate]()
 
    
    init(key:String) {
        
        super.init()
        
        self.key = key
        
        setupHandlers()
    }
    
    func setupHandlers() {
        
        if exists == false {
       
            exists = true
            
            ref = Database.database().reference()
            self.messages = [MessageModel]()
            
            self.messagesRef = ref.child("event-messages").child(key!)
            
            handleAdded = messagesRef.observe(.childAdded, with: { (snapshot) in
                
                print("Message added \(snapshot)")
                
                if let dict = snapshot.value as? [String:String] {
                    
                    let newMessage = MessageModel(key: snapshot.key, value: dict)
                    self.messages.append(newMessage)
                    
                    for delegate in self.delegates {
                        
                        delegate.onChildAdded()
                        
                    }
                    
                   
                }
                
            })
            
            handleDeleted = messagesRef.observe(.childRemoved, with: { (snapshot) in
                
               
                let index = self.messages.index(where: { (message) -> Bool in
                    
                    return message.key == snapshot.key
                    
                })
                
                if index != nil {
                    
                    self.messages.remove(at: index!)
                    
                    for delegate in self.delegates {
                        
                        delegate.onChildDeleted(index:index!)
                        
                    }
                    
                }
                
                
            })
        
        
        }
        
    }
    
    
    func removeHandlers() {
        
    }
    
    func addMessage(message:String) {
        
        let messageKey = messagesRef.childByAutoId().key
        
        let postMessage = ["uid" : userModel?.uid,
                           "message": message,
                           "date" : getCurrentDate()]
        
        let childUpdates = ["/event-messages/\(key!)/\(messageKey)": postMessage]
        
        ref.updateChildValues(childUpdates) { (error, ref) in
            
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            } else {
                
                SVProgressHUD.showSuccess(withStatus: "Message Sent")
            }
            
        }
        
    }
    
    
    func getCurrentDate() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium //Set time style
        dateFormatter.dateStyle = .medium //Set date style
        
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
    
    func deleteMessageAt(index:Int) {
        
        let messageKey = messages[index].key!
        ref.child("event-messages").child(key!).child(messageKey).removeValue()
        
    }
    
    
    
    
    
}
