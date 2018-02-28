//
//  NavigationMenuViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 18/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import Firebase


extension NavigationMenuViewController: BusinessBankModelDelegate {
    
    func onName(name: String) {
        
        print("set busines name \(name)")
        
        if name == "" {
            
            self.titleView.labelSubtitle.text  = ""
            
        } else {
            
            self.titleView.labelSubtitle.text   = "Welcome to \((name))"
        }
    }
    
    func onImage(image: UIImage) {
        
        self.logoImageView.image = image
        
    }
    
}


extension NavigationMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (userModel?.currentRole == "owner" || userModel?.currentRole == "manager") ?  menuItems.count : invitedUserMenu.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MenuCellTableViewCell = self.menuTable.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCellTableViewCell
        
        let cellTitle = (userModel?.currentRole == "owner" || userModel?.currentRole == "manager") ?   menuItems[indexPath.row] :  invitedUserMenu[indexPath.row]
        
        cell.labelTitle.text = cellTitle
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var newPageIndex:Int = 1
        
        if menuItems[indexPath.row] == "Sign out" {
            
            try! Auth.auth().signOut()
           newPageIndex = 0
        }
        
        let switchValue = (userModel?.currentRole == "owner" || userModel?.currentRole == "manager") ?   menuItems[indexPath.row] :  invitedUserMenu[indexPath.row]
        
        
        switch switchValue {
            case "Sign out":
                
                try! Auth.auth().signOut()
                newPageIndex = 0
                
            break
            
            case "Home"          : newPageIndex = 0
            case "Business info" : newPageIndex = 1
            case "User profile"  : newPageIndex = 2
            
        default:
            print("nothing on default")
        }
        
        
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        
    menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[newPageIndex])
        menuContainerViewController.hideSideMenu()
        
    }
    
}

extension NavigationMenuViewController:UserBankObjectDelegate {
    func onProfileImageChange() {
        
    }
    
    
    func onDisplayNameChange() {
        
        print("Change user display name")
        
        titleView.labelTitle.text   = userModel?.selfObject?.displayName
        
    }
}


class NavigationMenuViewController: MenuViewController {

    var handle : AuthStateDidChangeListenerHandle?
    var menuItems:Array = ["Home", "Business info", "User profile", "Sign out"]
    var invitedUserMenu:Array = ["Home", "User profile", "Sign out"]
   
    var currentImagePath = ""
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backdropImage: UIImageView!
    @IBOutlet var titleView: TitleView!
    
    @IBOutlet var menuTable: UITableView!
    
    var businessBankModel:BusinessBankModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        titleView.labelTitle.text      = ""
        titleView.labelSubtitle.text   = ""
        
        titleView.labelTitle.textAlignment = .center
        titleView.labelSubtitle.textAlignment = .center
        
        
        
        businessBankModel = businessBank?.getBusinessBankBy(id: (userModel?.currentBUID)!)
        businessBankModel?.delegates.append(self)

        if (businessBankModel?.exists)! {
            onName(name: (businessBankModel?.name)!)
            
            if businessBankModel?.logoImage != nil {
                onImage(image: (businessBankModel?.logoImage)!)
            }
        }
        
   
        
        if userModel?.selfObject?.exists == true {
            
            onDisplayNameChange()
        }
        
        
        userModel?.selfObject?.delegates.append(self)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
