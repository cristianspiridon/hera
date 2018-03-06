//
//  RegionViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 10/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD

extension RegionViewController:NavigationDelegate, NavigationDelegateOptionalEdit {
    func onDismiss() {
        self.dismiss(animated: true)
    }
    
    
    
    func onEdit() {
        
        self.performSegue(withIdentifier: "editRegion", sender: self)
        
    }
    
    
}

extension RegionViewController:RegionBankModelDelegate {
    
    func onRegionUpdate() {
        
        navController.labelTitle.text = regionModel?.title
        navController.setSubtitle(value: "Area range \((regionModel?.rangeIn)!)-\((regionModel?.rangeOut)!)")
    }
    
}

extension RegionViewController:ScanLabelDelegate {
    
    func onScan(code: String
        , sender:ScanLabel) {
        
        if Int(code)! >= (regionModel?.rangeIn)! {
            
            if Int(code)! <= (regionModel?.rangeOut)! {
                
                //   if areaList.
                
                let i = areaList?.areas.index(where: { (area) -> Bool in
                    
                    return area.key == "\(code)"
                    
                })
                
                if i != nil {
                    
                    //open area
                    
                    onAreaSelected(area: (areaList?.areas[i!])!)
                    
                } else {
                    
                    lastAreaCodeScan = Int(code)!
                    
                    areaList?.addNewArea(areaCode: "\((code))")
                    
                }
                
                
            } else {
                SVProgressHUD.showError(withStatus: "Area code out of range")
            }
            
        } else {
            SVProgressHUD.showError(withStatus: "Area code out of range")
        }
        
    }
    
}

extension RegionViewController:AreaListDelegate {
    
    func onAreaDeleted(index: Int) {
        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
        updateScrollHeight()
    }
    
    
    func onAreaChildAdded() {
        
        self.tableView.insertRows(at: [IndexPath(row: /*(areaList?.areas.count)!-1*/ 0, section: 0)], with: UITableViewRowAnimation.automatic)
        
        if let model = areaList?.areas[0] {
            
            if model.key == "\(lastAreaCodeScan)" {
                
                lastAreaCodeScan = 0
                onAreaSelected(area: model)
                
            }
            
        }
        
        updateScrollHeight()
        
    }
    
    
}

extension RegionViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return areaList!.areas.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:AreaTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "areaCell") as! AreaTableViewCell
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let areaCell:AreaTableViewCell = cell as? AreaTableViewCell {
            
            areaCell.setData(model: (areaList?.areas[indexPath.row])!)
            areaCell.delegate = self
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let selectedArea = areaList?.areas[indexPath.row]
        return  selectedArea?.uid == userModel?.uid || (currentSelectedFeed?.hasAdminRoles())!
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            print("Deleted")
            
            areaList?.deleteArea(at: indexPath.row)
        }
        
    }
    
}

extension RegionViewController:AreaTableViewDelegate {
    
    func onAreaSelected(area: AreaBankModel) {
        
        currentSelectedArea = area
        self.performSegue(withIdentifier: "showArea", sender: self)
        
    }
    
}



var currentSelectedRegion:RegionBankModel?
var currentSelectedArea:AreaBankModel?

class RegionViewController: HeraViewController {
    
    @IBOutlet var navController: NavigationView!
    @IBOutlet var stats: StocktakeStats!
    @IBOutlet var scanArea: ScanLabel!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var exportView: UIView!
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var scrollContentHeight: NSLayoutConstraint!
    
    @IBOutlet var tableView: UITableView!
    var regionModel:RegionBankModel?
    var currentRList:RegionsList?
    var areaList:AreaListManager?
    var lastAreaCodeScan:Int = -1
    
    @IBOutlet var scanYConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSelectedRegion = regionModel
        
        navController.labelTitle.text = regionModel?.title
        navController.showCloseButton(sender: self)
        
        if (currentSelectedFeed?.hasAdminRoles())! {
            
            navController.showEditButton(sender: self)
            
        } else {
            
            navController.showProfilePictureFor(userID: (userModel?.uid)!)
            
        }
        
        regionModel?.delegates.append(self)
        stats.setRegion(feed: regionModel!)
        
        scanArea.delegate = self
        scanArea.setDefault(value: "SCAN AREA CODE")
        scanArea.keyboardAction = "ENTER AREA CODE"
        scanArea.addDoneButtonOnKeyboard()
        
        areaList = areasBank?.getAreaListBy(key:(regionModel?.key)!)
        areaList?.delegates.append(self)
        
        if areaList?.areas.count != 0 {
            updateScrollHeight()
        }
        
        setScrollTap(scrollView: scrollView)
        onRegionUpdate()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editRegion" {
            
            let vc:AddRegionViewController = segue.destination as! AddRegionViewController
            
            vc.currentRList = currentRList
            vc.setRegion(model: regionModel!)
            
        }
        
    }
    
    
    func updateScrollHeight() {
        
        
        let tableH = (areaList?.areas.count)! * 60
        
        tableHeight.constant = CGFloat(tableH)
        scrollContentHeight.constant = max(( tableView.frame.origin.y + tableHeight.constant - self.view.frame.height), 0)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

