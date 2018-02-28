//
//  ScanLabel.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD

extension ScanLabel:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string != "" {
            
            userInputBackgrund.text = ""
            
            
        } else {
            
            if textField.text?.count == 1 {
                
                userInputBackgrund.text = defaultValue
            }
            
            
        }
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == defaultValue {
            
            textField.text = ""
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text == "" {
            
            textField.text = defaultValue
            userInputBackgrund.text = defaultValue
            
        }
        
    }
    
}

protocol ScanLabelDelegate {
    
    func onScan(code:String, sender:ScanLabel)
    
}

class ScanLabel: XibView {

    @IBOutlet var borderView: UIView!
    @IBOutlet var userInputLabel: UITextField!
    @IBOutlet var userInputBackgrund: UITextField!
    
    var defaultValue = "SCAN AREA"
    var keyboardAction = "Scan code"
    var delegate:ScanLabelDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        borderView.layer.cornerRadius = 18
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.gray.cgColor
        
        userInputLabel.delegate = self
        userInputLabel.keyboardType = .numberPad
        
        addDoneButtonOnKeyboard()
        
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: keyboardAction, style: UIBarButtonItemStyle.done, target: self, action: #selector(ScanLabel.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        userInputLabel.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(resign:Bool = true) {

      
        if resign == true {
            
            userInputLabel.resignFirstResponder()
            
        }
        
        delegate?.onScan(code: userInputLabel.text!, sender: self)
        
      
       
    }
    @IBAction func onScanAction(_ sender: Any) {
        
        doneButtonAction(resign:false)
        
    }
    
    func setDefault(value:String) {
        
        defaultValue = value
        
        userInputLabel.text = value
        userInputBackgrund.text = value
    }
    
    


}
