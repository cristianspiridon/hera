//
//  AddRegionViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD

enum RegionAction {
    
    case Add
    case Edit
    
}

extension AddRegionViewController:NavigationDelegate {

    func onDismiss() {
        self.dismiss(animated: true)
    }
    
}

extension AddRegionViewController:RegionBankCreateDelegate {
    func onRegionCreated() {
        
        onDismiss()
    }
    
    
}

class AddRegionViewController: HeraViewController {

    var type:RegionAction?
    var currentRList:RegionsList?
    
    @IBOutlet var navController: NavigationView!
    
    @IBOutlet var descriptionView: UserInputView!
    @IBOutlet var rangeIn: UserInputView!
    @IBOutlet var rangeOut: UserInputView!
    @IBOutlet var centerY: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var actionButton: UIButton!
    
    var regionModel:RegionBankModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.labelTitle.text = "New region"
        navController.showCloseButton(sender: self)
        
        descriptionView.titleValue.text = "Enter region description"
        rangeIn.titleValue.text = "Area range in"
        rangeOut.titleValue.text = "Area range out"
        
        rangeIn.userInputLabel.keyboardType = .numberPad
        rangeOut.userInputLabel.keyboardType = .numberPad

        // Do any additional setup after loading the view.
        
        setScrollTap(scrollView: scrollView)
        setKeyboard(constraint: centerY)
        addKeyboardNotifications()
        
        currentRList?.delegate = self
        
        if regionModel != nil {
            
            navController.labelTitle.text = "Edit region"
            
            descriptionView.setValue(value: (regionModel?.title)!)
            rangeIn.setValue(value: "\((regionModel?.rangeIn)!)")
            rangeOut.setValue(value: "\((regionModel?.rangeOut)!)")
            
            actionButton.setTitle("UPDATE REGION", for: .normal)
            
        }
    }
    
    func setRegion(model:RegionBankModel){
        
        regionModel = model
        type = RegionAction.Edit
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func onAction(_ sender: Any) {
        
        print("on action \(type)")
        
            if validate(string: descriptionView.userInputLabel.text!, errorMessage: "Description is invalid") {
                
                if validate(string: rangeIn.userInputLabel.text!, errorMessage: "Range In must be at least 100") {
                    
                    if validate(string:rangeOut.userInputLabel.text!, errorMessage: "Range Out must be at least 100 ") {
                        
                        if validateRangeValues(errorMessage:"Range Out must be greater than Range In") {
                            
                            self.view.endEditing(true)
                            
                            if type == RegionAction.Add {
                            
                                currentRList?.addNewRegion(description:descriptionView.userInputLabel.text!, rangeIn: rangeIn.userInputLabel.text!, rangeOut: rangeOut.userInputLabel.text!)
                                
                            } else {
                                
                                print("so let's update")
                                
                                currentRList?.updateRegion(reg: regionModel!, title: descriptionView.userInputLabel.text!, rangeIn: Int(rangeIn.userInputLabel.text!)!, rangeOut: Int(rangeOut.userInputLabel.text!)!)
                                
                                onDismiss()
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
        
        
    }
    
    
    func validateRangeValues(errorMessage:String) -> Bool {
        
        let rIn:Int = Int(rangeIn.userInputLabel.text!)!
        let rOut:Int = Int(rangeOut.userInputLabel.text!)!
        
        if  rOut >= rIn {
            return true
        } else {
            SVProgressHUD.showError(withStatus: errorMessage)
            return false
        }
        
    }
    
    func validate(string:String, errorMessage:String) -> Bool {
        
        if string.count < 3 {
            
            SVProgressHUD.showError(withStatus: errorMessage)
            return false
        } else {
            return true
        }
        
    }


}
