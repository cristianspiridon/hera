//
//  NavigationView.swift
//  myHera
//
//  Created by Cristian Spiridon on 18/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

enum RightActions {
    
    case closeSymbol
    case addSymbol
    case moreOptions
 
    
}

enum LeftActions {
    
    case menuSymbol
    case editSymbol
    case addUser
    case exportPDF
    
}

protocol NavigationDelegateMoreOptions {
    
    func onMoreOptions()
}

protocol NavigationDelegateOptionalExport {
    
    func onExportPDF()
    
}

protocol NavigationDelegateOptionalMenu {
    
    func onShowMenu()
    
}

protocol NavigationDelegateOptionalAddUser {
    
    func onAddUser()
    
}

protocol NavigationDelegateOptionalEdit {
    
     func onEdit()
    
}

protocol NavigationDelegateOptionalAdd {
    
      func onAdd()
    
}


protocol NavigationDelegate {
    
    func onDismiss()
    
}


import UIKit

class NavigationView: XibView {
 
    
    var delegate:NavigationDelegate!
    var exportDelegate:NavigationDelegateOptionalExport?
    var menuDelegate:NavigationDelegateOptionalMenu?
    var addUserDelegate:NavigationDelegateOptionalAddUser?
    var editDelegate:NavigationDelegateOptionalEdit?
    var addDelegate:NavigationDelegateOptionalAdd?
    var moreDelegate:NavigationDelegateMoreOptions?
    
    @IBOutlet var addUserSymbol: UIImageView!
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubtitle: UILabel!
    
    @IBOutlet var titleY: NSLayoutConstraint!
    
    @IBOutlet var menuSymbol: UIView!
    @IBOutlet var plusSymbol: UIView!
    @IBOutlet var editSymbol: UIView!
    @IBOutlet var roundedProfile: RoundedPicture!
    @IBOutlet var moreOptions: UIImageView!
    @IBOutlet var navBackdrop: UIView!
    
    
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    
    var leftAction:LeftActions?
    var rightAction:RightActions?
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        hideAll()
        
    }
    
    func setRecordingState() {
        
        let bgColor:UIColor = .red
        let textColor:UIColor = .white
        
        self.navBackdrop.backgroundColor = bgColor
        labelTitle.textColor = textColor
        labelSubtitle.textColor = textColor
        
        moreOptions.image = UIImage(named:"icons8-more-filled-50-white")
        
    }
    
    func setSubtitle(value:String){
        
        if value == "" {
            
            labelSubtitle.text = ""
            titleY.constant = 10
            
        } else {
            
            labelSubtitle.text = value
            titleY.constant = 3
            
        }
        
    }
    
    func hideAll() {
        
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        //left options
        
        menuSymbol.isHidden = true
        editSymbol.isHidden = true
        
        //right options
        
        plusSymbol.isHidden = true
        moreOptions.isHidden = true
        addUserSymbol.isHidden = true
        
        setSubtitle(value: "")
    }
    
    
    
    func showAddButton(sender: NavigationDelegateOptionalAdd) {
        
        addDelegate = sender
        
        rightAction = RightActions.addSymbol
        rotate(angle: 0, view: plusSymbol)
        plusSymbol.isHidden = false
        rightButton.isHidden = false
    }
    
    func showMoreOptions(sender:NavigationDelegateMoreOptions) {
        
        moreDelegate = sender
        
        rightAction = RightActions.moreOptions
     
        moreOptions.isHidden = false
        rightButton.isHidden = false
    }
    
    func showCloseButton(sender:NavigationDelegate) {
        
        delegate = sender
        
        rightAction = RightActions.closeSymbol
        rotate(angle: 45, view: plusSymbol)
        plusSymbol.isHidden = false
        rightButton.isHidden = false
    }
    
    func showMenuButton(sender: NavigationDelegateOptionalMenu) {
        
        menuDelegate = sender
        
        leftAction = LeftActions.menuSymbol
        menuSymbol.isHidden = false
        leftButton.isHidden = false
    
    }
    
    func showExportPDF(sender:NavigationDelegateOptionalExport) {
        
        exportDelegate = sender
        
        leftAction = LeftActions.exportPDF
        addUserSymbol.image = UIImage(named: "icons8-pdf")
        addUserSymbol.isHidden = false
        leftButton.isHidden = false
    }
    
    func showAddUserButton(sender: NavigationDelegateOptionalAddUser) {
        
        addUserDelegate = sender
        
        leftAction = LeftActions.addUser
        addUserSymbol.isHidden = false
        leftButton.isHidden = false
        
    }
    
    func showEditButton(sender: NavigationDelegateOptionalEdit) {
        
        editDelegate = sender
        
        leftAction = LeftActions.editSymbol
        editSymbol.isHidden = false
        leftButton.isHidden = false
    }
    
    func rotate(angle:CGFloat, view:UIView) {
        
        let radians = angle / 180.0 * CGFloat(Double.pi)
        let rotation = self.transform.rotated(by: radians)
        view.transform = rotation
        
    }
    
    func showProfilePictureFor(userID:String){
        
        roundedProfile.setupWith(userID: userID, pictSize: 30)
        
    }
    
    @IBAction func onLeftAction(_ sender: UIButton) {
    
       
            if leftAction == LeftActions.editSymbol {
                
                editDelegate?.onEdit()
                
            } else if leftAction == LeftActions.menuSymbol {
                
                menuDelegate?.onShowMenu()
                
            } else if leftAction == LeftActions.addUser {
                
                addUserDelegate?.onAddUser()
                
            } else if leftAction == LeftActions.exportPDF {
                
                exportDelegate?.onExportPDF()
                
            }
        
    }
    
    @IBAction func onRightAction(_ sender: Any) {
        
            if rightAction == RightActions.closeSymbol {
                
                delegate.onDismiss()
                
            } else if rightAction ==  RightActions.addSymbol {
                
                addDelegate?.onAdd()
            } else if rightAction == RightActions.moreOptions {
                
                moreDelegate?.onMoreOptions()
        }
        
    }
  
}
