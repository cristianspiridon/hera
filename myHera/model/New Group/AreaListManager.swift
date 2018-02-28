//
//  AreaListManager.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol AreaListDelegate {
    
    func onAreaChildAdded()
    func onAreaDeleted(index:Int)
}


class AreaListManager: NSObject {
    
    var key:String?
    var areaListRef:DatabaseReference?
    var ref:DatabaseReference?
    var areas:[AreaBankModel] = [AreaBankModel]()
    
    var delegates:[AreaListDelegate] = [AreaListDelegate]()
    
    var handleAdded:   UInt = 0
    var handleDeleted: UInt = 0
    var handleChange:  UInt = 0
    
    init(key:String) {
    
        super.init()
        self.key = key
        ref = Database.database().reference()
        
        
        setupHandler()
    }
    
    func setupHandler() {
        
        ref = Database.database().reference()
        areas = [AreaBankModel]()
        
        print("Get area list by \(key!)")
        
        areaListRef = ref?.child("areas").child((currentSelectedFeed?.key)!).child((key!))
        
        handleAdded = (areaListRef?.observe(.childAdded, with: { (snapshot) in
            
            let newArea:AreaBankModel = AreaBankModel(key: snapshot.key, value: snapshot.value as! [String : Any])
         
            self.areas.insert(newArea, at: 0)
            
            for delegate in self.delegates {
                
                delegate.onAreaChildAdded()
                
            }
            
        }))!
        
        handleChange = (areaListRef?.observe(.childChanged, with: { (snapshot) in
            
            let i = self.areas.index(where: { (area) -> Bool in
                
                return area.key == snapshot.key
                
            })
            
            if i != nil {
                
                self.areas[i!].updateWith(value:snapshot.value as! [String : Any])
                
            }
            
        }))!
        
        handleDeleted = (areaListRef?.observe(.childRemoved, with: { (snapshot) in
            
            let index = self.areas.index(where: { (area) -> Bool in
                
                return area.key == snapshot.key
                
            })
            
            if index != nil {
                
                self.areas.remove(at: index!)
                
                for delegate in self.delegates {
                    
                    delegate.onAreaDeleted(index:index!)
                    
                }
                
            }
            
        }))!
        
    }
    

    
    func addNewArea(areaCode:String) {
        
        SVProgressHUD.show()
        
        
        let postArea   = ["uid": userModel?.uid!,
                            "stock-value": 0,
                            "quantity"  : 0,
                            "duration": 0,
                            "progress": "in progress"] as [String : Any]
        
        
        let childUpdates = ["/areas/\((currentSelectedFeed?.key!)!)/\((currentSelectedRegion?.key)!)/\(areaCode)": postArea]
        
        
        
        ref?.updateChildValues(childUpdates) { (error, ref) in
            
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            } else {
                
                SVProgressHUD.showSuccess(withStatus: "Area created")
                    
                }
                
            }
            
        }
    
    
    func deleteArea(at:Int){
        
        deleteArea(area: areas[at])
    }
    
    func deleteArea(area:AreaBankModel) {
        
        if area.progress == "completed" {
         
            currentSelectedRegion?.substractAreaDetails(areaModel: area)
            currentSelectedFeed?.substractAreaDetails(areaModel: area)
        }
        
        area.removeFootPrint()
        
        areaListRef?.child(area.key!).removeValue()
        ref?.child("area_contents").child((currentSelectedFeed?.key)!).child((currentSelectedRegion?.key!)!).child(area.key!).removeValue()
        
    }
        
}

