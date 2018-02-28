//
//  AddNewStocktakeEventViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 26/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD


extension AddNewStocktakeEventViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
        print(" textFieldDid Begin Editing ")
        
        if textField == storeName.userInputLabel {
            storeName.textFieldDidBeginEditing(textField)
        } else if textField == eventName.userInputLabel {
            eventName.textFieldDidBeginEditing(textField)
        } else if textField == eventDate.userInputLabel {
            eventDate.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
          print(" textFieldDid END Editing ")
        
        if textField == storeName.userInputLabel {
            storeName.textFieldDidEndEditing(textField)
            
        } else if textField == eventName.userInputLabel {
            eventName.textFieldDidEndEditing(textField)
        } else if textField == eventDate.userInputLabel {
            eventDate.textFieldDidEndEditing(textField)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == storeName.userInputLabel {
            
            eventName.userInputLabel.becomeFirstResponder()
            
        } else if textField == eventName.userInputLabel {
            
            if exists == true  {
                
                self.view.endEditing(true)
                self.feed?.updateWith(name:eventName.userInputLabel.text!)
                SVProgressHUD.showSuccess(withStatus: "Event name updated")
                
            } else {
            
                eventDate.userInputLabel.becomeFirstResponder()
            }
            
        } else if textField == eventDate.userInputLabel {
            
            textField.resignFirstResponder()
            onCreate(actionButton)
            
        }
        
        return true
        
    }
    
}


extension AddNewStocktakeEventViewController:NavigationDelegate {

    func onDismiss() {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }

}

extension AddNewStocktakeEventViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        print("get no of components")
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        return (locationsBank!.businessLocations.count)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
   
   
        let locationM = (locationsBank?.businessLocations[row])!
        let labelStr = "\((locationM.name)) \((locationM.postcode))"
        
        
        return labelStr
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if  let locationM:LocationBankModel = (locationsBank?.businessLocations[row])! {
            
            let labelStr = "\((locationM.name)) \((locationM.postcode))"
            
            selectedStoreIndex = row
            
            storeName.setValue(value:labelStr, isBlue: true)
        }
    }
    
    
}


extension AddNewStocktakeEventViewController:LocationBankModelDelegate {
    func onEventCreatedWithSucces() {
    
        self.onDismiss()
    }
    
    func onLocationDataReady() {
        
    }
    
    func onImageReady() {
        
    }
    
    
}


class AddNewStocktakeEventViewController: HeraViewController {

    @IBOutlet var navController: NavigationView!
    
    @IBOutlet var storeName: UserInputView!
    @IBOutlet var eventName: UserInputView!
    @IBOutlet var eventDate: UserInputView!
    
    @IBOutlet var centerYConstrain: NSLayoutConstraint!
    
    @IBOutlet var actionButton: UIButton!
    
    var feed:FeedBankModel?
    var exists:Bool = false
    
    @IBAction func onCreate(_ sender: Any) {
     
       
        
            SVProgressHUD.show()
        
            if selectedStoreIndex == -1 {
                
                SVProgressHUD.showError(withStatus: "Store location must be selected")
                
            } else if eventName.userInputLabel.text == "" {
                
                SVProgressHUD.showError(withStatus: "Event name is invalid")
                
            } else if eventDate.userInputLabel.text == "" {
                
                SVProgressHUD.showError(withStatus: "Event date is invalid")
            } else {
                
                
                if exists == true {
                    
                    feed?.updateWith(name: eventName.userInputLabel.text!)
                    feed?.updateWith(date: eventDate.userInputLabel.text!)
                    
                    SVProgressHUD.showSuccess(withStatus: "Event updated")
                    
                    onDismiss()
                    
                } else {
                
                    let location = locationsBank?.businessLocations[selectedStoreIndex]
                    location?.delegates.append(self)
                    
                    location?.addNewStocktakeEvent(eventName: eventName.userInputLabel.text!, eventDate: eventDate.userInputLabel.text!)
                }
        
            }
    }
    
    func setFeedBank(model:FeedBankModel) {
        
        exists = true
        feed = model
    }
    
    
    var selectedStoreIndex = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.labelTitle.text = "New stocktake event"
        navController.showCloseButton(sender: self)
        
        storeName.titleValue.text = "Select store location"
        eventName.titleValue.text = "Enter event name"
        eventDate.titleValue.text = "Enter event date"
   
        if locationsBank?.businessLocations.count != 0  {
       
            let firstLocation = locationsBank?.businessLocations.first!
            
            if (firstLocation?.exists)! {
                
                selectedStoreIndex = 0
                storeName.setValue(value: "\((firstLocation?.name)!) \((firstLocation?.postcode)!)")
                
            }
            
        } else {
            
            locationsBank?.getLocationsBy(businessID: (userModel?.currentBUID)!)
            
        }
        
        
        
        storeName.userInputLabel.delegate = self
        eventName.userInputLabel.delegate = self
        eventDate.userInputLabel.delegate = self
        
        let storePicker:UIPickerView = UIPickerView()
        storePicker.delegate = self
        storePicker.dataSource = self
        
        storeName.userInputLabel.inputView = storePicker
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
    
        
        eventDate.userInputLabel.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddNewStocktakeEventViewController.datePickerStartTimeValueChanged), for: UIControlEvents.valueChanged)
        
        addKeyboardNotifications()
        
        
        if exists == true {
            
            navController.labelTitle.text = "Edit event details"
            navController.showCloseButton(sender: self)
            
            storeName.isHidden = true
            
            actionButton.setTitle("UPDATE EVENT", for: .normal)
            
            eventName.setValue(value: (feed?.name)!)
            eventDate.setValue(value: (feed?.eventDate)!)
            
            eventName.userInputLabel.returnKeyType = .done
            eventDate.userInputLabel.returnKeyType = .done
            
            selectedStoreIndex = 0
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func datePickerStartTimeValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        eventDate.setValue(value: dateFormatter.string(from: sender.date), isBlue:true)
        
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.centerYConstrain.constant = -(keyboardSize.height / 2)
                self.view.layoutIfNeeded()
                
            })
            
        }
        
    }
    
    
    override func keyboardWillHide(notification: NSNotification) {
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.centerYConstrain.constant = 0
            
            self.view.layoutIfNeeded()
        })
        
    }
}
