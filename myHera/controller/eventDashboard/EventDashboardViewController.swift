//
//  EventDashboardViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 06/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import InteractiveSideMenu

extension EventDashboardViewController: NavigationDelegate, NavigationDelegateOptionalEdit, SideMenuItemContent {
    
    func onDismiss() {
        
        self.dismiss(animated: true)
        
    }
    
    func onEdit() {
        
        self.performSegue(withIdentifier: "editEvent", sender: self)
    }
    
}

extension EventDashboardViewController:FeedBankModelDelegate {
    
    func onUpdate() {
        
        navController.labelTitle.text = currentFeed?.name
        
    }
    
    func onLocationImageReady(image: UIImage) {
        
        mainImage.image = image
        
    }
    
}

extension EventDashboardViewController:MessagesBankDelegate {
    func onChildAdded() {
        numOfMessages.text = "\(messagesObject?.messages.count ?? 0)"
    }
    
    func onChildDeleted(index: Int) {
        numOfMessages.text = "\(messagesObject?.messages.count ?? 0)"
    }
}

extension EventDashboardViewController: ParticipantsViewDelegate {
    
    func onSelect() {
        self.performSegue(withIdentifier: "showParticipants", sender: self)
    }
    
    
}

extension EventDashboardViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (currentRList?.regions.count)! + (currentFeed?.hasAdminRoles() == true ? 1 : 0)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == currentRList?.regions.count {
            
            return 44
            
        } else {
            
            return 80
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == currentRList?.regions.count {
            
            let cell:AddRegionTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "addRegionCell") as! AddRegionTableViewCell
            return cell
            
        } else {
            
            let cell:RegionTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "regionCell") as! RegionTableViewCell
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if let regCell:RegionTableViewCell = cell as? RegionTableViewCell {
            
            regCell.setData(region: (currentRList?.regions[indexPath.row])!)
            regCell.delegate = self
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == currentRList?.regions.count {
            
            return false
            
        } else {
            
            if currentFeed?.uid == userModel?.uid {
                
                return true
                
            } else {
                
                
                return false
                
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            print("Deleted")
            
            currentRList?.deleteRegion(at: indexPath.row)
        }
        
    }
    
}

extension EventDashboardViewController:RegionListDelegate {
    
    func onRegionChildAdded() {
        
        self.tableView.insertRows(at: [IndexPath(row: (currentRList?.regions.count)!-1, section: 0)], with: UITableViewRowAnimation.automatic)
        
        updateScrollHeight()
        
    }
    
    func onRegionChildDeleted(index: Int) {
        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
        updateScrollHeight()
    }
    
}

extension EventDashboardViewController:RegionTableCellDelegate {
    
    
    func onSelect(model: RegionBankModel) {
        
        selectedRegion = model
        self.performSegue(withIdentifier: "showRegion", sender: self)
        
    }
    
}

var currentSelectedFeed:FeedBankModel?
var currentRList:RegionsList?

class EventDashboardViewController: HeraViewController {
    
    @IBOutlet var navController: NavigationView!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var numOfMessages: UILabel!
    @IBOutlet var participantsView: Participants!
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var scrollContentHeight: NSLayoutConstraint!
    @IBOutlet var stocktakeStats: StocktakeStats!
    @IBOutlet var exportView: UIView!
    @IBOutlet var separatorLine: UIView!
    
    var currentFeed:FeedBankModel?
    
    var selectedRegion:RegionBankModel?
    
    var messagesObject:MessagesBankObject?
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBAction func showDiscussions(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showDiscussions", sender: self)
        
    }
    @IBAction func onAddRegion(_ sender: Any) {
        
        self.performSegue(withIdentifier: "addRegion", sender: self)
        
    }
    
    @IBAction func onExport(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showTestPage", sender: self)
        
    }
    
    
    func updateScrollHeight() {
        
        
        let tableH = tableView.contentSize.height
        
        tableHeight.constant = tableH
        scrollContentHeight.constant = max((551 + tableH - self.view.frame.height), 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        updateScrollHeight()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSelectedFeed = currentFeed
        currentFeed?.delegates.append(self)
        
        productsBank?.loadEntireBarcodeDataOffline()
        
        navController.labelTitle.text = currentFeed?.name
        
        navController.showCloseButton(sender: self)
        
        if (currentSelectedFeed?.hasAdminRoles())! {
            
            navController.showEditButton(sender: self)
            
            
        } else {
            
            exportView.isHidden = true
            separatorLine.isHidden = true
            navController.showProfilePictureFor(userID: (userModel?.uid)!)
            
        }
        
        participantsView.delegate = self
        participantsView.setup(feed: currentFeed!)
        
        
        
        if (currentFeed?.exists)! {
            if currentFeed?.locationModel?.image != nil {
                
                onLocationImageReady(image: (currentFeed?.locationModel?.image)!)
                
            }
        }
        
        //setup regions
        
        currentRList = regionBank?.getRegionsBy(stocktakeId: (currentFeed?.key)!)
        currentRList?.regionDelegate = self
        
        // Setup message number and delegates
        
        messagesObject = messagesBank?.getMessagesFor(stocktakeId: (currentFeed?.key!)!)
        messagesObject?.delegates.append(self)
        
        onChildAdded()
        
        stocktakeStats.setFeed(feed: currentFeed!)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editEvent" {
            
            let vc:AddNewStocktakeEventViewController  = segue.destination as! AddNewStocktakeEventViewController
            vc.setFeedBank(model: currentFeed!)
            
        }
        
        if segue.identifier == "showDiscussions" {
            
            let vc:ChatViewController = segue.destination as! ChatViewController
            vc.currentFeed = currentFeed!
            
        }
        
        if segue.identifier == "addRegion" {
            
            let vc:AddRegionViewController = segue.destination as! AddRegionViewController
            vc.type = RegionAction.Add
            
            vc.currentRList = currentRList
            
        }
        
        if segue.identifier == "showRegion" {
            
            let vc:RegionViewController = segue.destination as! RegionViewController
            vc.currentRList = currentRList
            vc.regionModel = selectedRegion
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

