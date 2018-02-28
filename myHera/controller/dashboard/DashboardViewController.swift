//
//  DashboardViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 18/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import Firebase



extension DashboardViewController:FeedCellDelegate {
   
    func showDiscussionsFor(feed: FeedBankModel) {
        
        currentSelectedFeed = feed
        self.performSegue(withIdentifier: "showDiscussions", sender: self)
        
    }
}

extension DashboardViewController: NavigationDelegateOptionalMenu, NavigationDelegateOptionalAdd, SideMenuItemContent {

 
    func onAdd() {
        
        self.performSegue(withIdentifier: "AddStocktake", sender: self)
        
    }
    
    func onShowMenu() {
        
        print("Show menu")
        
        showSideMenu()
    }
    
}


extension DashboardViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return  1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 300
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (feed?.feeds.count) ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:EventFeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleEventCell") as! EventFeedTableViewCell
        
        let maskLayer = CAShapeLayer()
        let bounds = cell.bounds
        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7.5, width: bounds.width, height: bounds.height-15), cornerRadius: 0).cgPath
        cell.layer.mask = maskLayer
        
        cell.delegate = self
        cell.setData(feed: (feed?.feeds[indexPath.row])!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if feed?.feeds[indexPath.row].uid == userModel?.uid {
         
            return true
            
        } else {
            
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentSelectedFeed = feed?.feeds[indexPath.row]
        self.performSegue(withIdentifier: "showEvent", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            print("Deleted")
            
            if feed?.feeds[indexPath.row].uid == userModel?.uid {
                
            
                feed?.deleteFeedAt(index: indexPath.row)
                
                
            }
            
            
        }
        
    }
    
}



extension DashboardViewController: FeedBankObjectDelegate {
    
    func onChildAdded() {
        
        self.tableView.insertRows(at: [IndexPath(row: (self.feed?.feeds.count)!-1, section: 0)], with: UITableViewRowAnimation.automatic)
        
    }
    
    func onChildDeleted(index:Int) {
        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
    }
    
    
}

class DashboardViewController: HeraViewController {
    

    @IBOutlet var navController: NavigationView!
    @IBOutlet var tableView: UITableView!
    
    var currentSelectedFeed:FeedBankModel?
    var feed:FeedBankObject?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navController.labelTitle.text = "Feed"
    
        navController.showMenuButton(sender: self)
        navController.showAddButton(sender: self)
        
        feed =  feedBank?.getFeedBy(businessID: (userModel?.currentBUID)!)
        feed?.delegate = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDiscussions" {
            
            let vc:ChatViewController = segue.destination as! ChatViewController
            vc.currentFeed = currentSelectedFeed!
            
        }
        
        if segue.identifier == "showEvent" {
            
            let vc:EventDashboardViewController = segue.destination as! EventDashboardViewController
            vc.currentFeed = currentSelectedFeed!
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
