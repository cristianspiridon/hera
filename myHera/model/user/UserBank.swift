//
//  UserBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 02/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class UserBank: NSObject {

    var users:[UserBankObject] = [UserBankObject]()
    
    override init() {
        
        super.init()
    }
    
    
    func getUserObject(with:String) -> UserBankObject{
        
        let i = users.index { (userObject) -> Bool in
            
            return userObject.key == with
        
        }
        
        if i != nil {
            
            return users[i!]
            
        } else {
            
            let newUser = UserBankObject(key: with)
            users.append(newUser)
            return newUser
            
        }
        
    }
    
}
