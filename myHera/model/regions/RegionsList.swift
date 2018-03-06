//
//  RegionsList.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

protocol RegionBankCreateDelegate {
    
    func onRegionCreated()
    
}

protocol RegionListDelegate {
    
    func onRegionChildAdded()
    func onRegionChildDeleted(index:Int)
    
}


class RegionsList: NSObject {
    
    var key:String!
    var regions:[RegionBankModel] = [RegionBankModel]()
    var ref:DatabaseReference?
    
    var delegate:RegionBankCreateDelegate?
    var regionDelegate:RegionListDelegate?
    
    
    var handleAdded:   UInt = 0
    var handleDeleted: UInt = 0
    var handleChange:  UInt = 0
    
    init(key:String) {
        
        super.init()
        self.key = key
        
        setupHandler()
    }
    
    func setupHandler() {
        
        ref = Database.database().reference()
        regions = [RegionBankModel]()
        
        handleAdded = (ref?.child("regions").child(key).observe(.childAdded, with: { (snapshot) in
            
            let newRegion:RegionBankModel = RegionBankModel(key: snapshot.key, value: snapshot.value as! [String : Any])
            self.regions.append(newRegion)
            
            if self.regionDelegate != nil {
                
                self.regionDelegate?.onRegionChildAdded()
                
            }
            
        }))!
        
        handleChange = (ref?.child("regions").child(key).observe(.childChanged, with: { (snapshot) in
            
            let i = self.regions.index(where: { (region) -> Bool in
                
                return region.key == snapshot.key
                
            })
            
            if i != nil {
                
                self.regions[i!].updateWith(value:snapshot.value as! [String : Any])
                
            }
            
        }))!
        
        
        handleDeleted = (ref?.child("regions").child(key).observe(.childRemoved, with: { (snapshot) in
            
            let index = self.regions.index(where: { (regions) -> Bool in
                
                return regions.key == snapshot.key
                
            })
            
            if index != nil {
                
                self.regions.remove(at: index!)
                
                if self.regionDelegate != nil {
                    
                    self.regionDelegate?.onRegionChildDeleted(index:index!)
                    
                }
                
            }
            
        }))!
        
        
    }
    
    func removeObservers() {
        
        print("deinit region list")
        
        ref?.removeObserver(withHandle: handleAdded)
        ref?.removeObserver(withHandle: handleChange)
        ref?.removeObserver(withHandle: handleDeleted)
        
    }
    
    func addNewRegion(description:String, rangeIn:String, rangeOut:String) {
        
        SVProgressHUD.show()
        
        let regionKey      = ref?.child("regions").child(self.key!).childByAutoId().key
        
        let postRegion   = ["title": description,
                            "range-in": Int(rangeIn)!,
                            "range-out": Int(rangeOut)!,
                            "stock-value": 0,
                            "quantity"  : 0,
                            "duration": 0,
                            "progress": 0,
                            "completed-areas": 0] as [String : Any]
        
        let numfOf =  Int(rangeOut)! - Int(rangeIn)! + 1
        
        currentSelectedFeed?.update(totalAreasValue: numfOf)
        
        let childUpdates = ["/regions/\(key!)/\(regionKey!)": postRegion]
        
        
        ref?.updateChildValues(childUpdates) { (error, ref) in
            
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
            } else {
                
                SVProgressHUD.dismiss()
                
                if self.delegate != nil {
                    
                    self.delegate?.onRegionCreated()
                    SVProgressHUD.showSuccess(withStatus: "Region created")
                    
                }
                
            }
            
        }
        
    }
    
    func updateRegion(reg:RegionBankModel, title:String, rangeIn:Int, rangeOut:Int) {
        
        print("Update region ")
        
        if reg.title != title {
            
            ref?.child("regions").child(key).child(reg.key!).child("title").setValue(title)
            SVProgressHUD.showSuccess(withStatus: "Region updated")
            
        } else {
            
            let completed = reg.progress! * Double(reg.numberOfAreas())
            let newPerc   = completed / Double(rangeOut - rangeIn + 1)
            
            ref?.child("regions").child(key).child(reg.key!).child("progress").setValue(newPerc)
            
            let diff = (rangeOut - rangeIn + 1) - reg.numberOfAreas()
            currentSelectedFeed?.update(totalAreasValue: diff)
            
        }
        
        if reg.rangeIn != rangeIn {
            
            
            ref?.child("regions").child(key).child(reg.key!).child("range-in").setValue(rangeIn)
            
            SVProgressHUD.showSuccess(withStatus: "Region updated")
            
        }
        
        if reg.rangeOut != rangeOut {
            
            ref?.child("regions").child(key).child(reg.key!).child("range-out").setValue(rangeOut)
            SVProgressHUD.showSuccess(withStatus: "Region updated")
            
        }
        
    }
    
    
    func deleteRegion(at:Int){
        
        deleteRegion(reg: regions[at])
    }
    
    func deleteRegion(reg:RegionBankModel) {
        
        reg.removeFootPrint()
        
        currentSelectedFeed?.update(totalAreasValue: -(reg.numberOfAreas()))
        currentSelectedFeed?.update(quantityValue: -(reg.quantity!))
        currentSelectedFeed?.update(stockValue: -(reg.totalValue!))
        currentSelectedFeed?.update(durationValue: -(reg.duration!))
        currentSelectedFeed?.update(completed: -(reg.completedAreas!))
        
        
        let rootRef = ref?.child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!)
        
        ref?.child("regions").child(key!).child(reg.key!).removeValue()
        
        rootRef?.child("areas").child(reg.key!).removeValue()
        rootRef?.child("area_contents").child(reg.key!).removeValue()
        
    }
    
    
}

