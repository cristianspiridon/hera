//
//  BusinessBank.swift
//  myHera
//
//  Created by Cristian Spiridon on 07/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class BusinessBank: NSObject {
    
    var business:[BusinessBankModel] = [BusinessBankModel]()
    
    
    func getBusinessBankBy(id:String) -> BusinessBankModel {
        
        let i = business.index { (business) -> Bool in
            
            return business.key == id
            
        }
        
        if i != nil {
            
            return business[i!]
            
        } else {
            
            let newBusiness = BusinessBankModel(key: id)
            business.append(newBusiness)
            return newBusiness
            
        }
        
    }
    

}
