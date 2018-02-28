//
//  CreateNewBusinessViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 17/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase


struct newAccountConstant {
    
    static let appTitle    = "New account"
    
}

protocol CreateNewAccountDelegate {
    
    func onCreated()
}

extension CreateNewAccount: NavigationDelegate {

    func onAddUser() {}
    
    
    func onEdit() {}
    func onAdd() {}
    func onShowMenu() {}
    
    func onDismiss() {
        
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    
}

class CreateNewAccount: HeraViewController, UITextFieldDelegate {
  
    var delegate:CreateNewAccountDelegate! = nil
    var ref: DatabaseReference!

    @IBOutlet var centerYConstraint: NSLayoutConstraint!
    
    @IBOutlet var nameView: UserInputView!
    @IBOutlet var emailView: UserInputView!
    @IBOutlet var navController: NavigationView!

    @IBOutlet var actionButton: UIButton!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var passwordView: UserInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.delegate = self
        navController.labelTitle.text = newAccountConstant.appTitle
        navController.showCloseButton(sender: self)
        
        nameView.titleValue.text     = LoginConstant.nameLabel
        emailView.titleValue.text    = LoginConstant.emailLabel
        passwordView.titleValue.text = LoginConstant.passwordLabel
        
        
        emailView.userInputLabel.keyboardType = UIKeyboardType.emailAddress
        passwordView.userInputLabel.isSecureTextEntry = true
        
        actionButton.setTitle("CREATE", for: .normal)
        
        nameView.userInputLabel.delegate     = self
        emailView.userInputLabel.delegate    = self
        passwordView.userInputLabel.delegate = self
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nameView.userInputLabel {
            nameView.textFieldDidBeginEditing(textField)
            
        } else  if textField == emailView.userInputLabel  {
            emailView.textFieldDidBeginEditing(textField)
            
        } else  if textField == passwordView.userInputLabel  {
            passwordView.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == nameView.userInputLabel {
            nameView.textFieldDidEndEditing(textField)
        } else if textField == emailView.userInputLabel  {
            emailView.textFieldDidEndEditing(textField)
        } else if textField == passwordView.userInputLabel  {
            passwordView.textFieldDidEndEditing(textField)
        }
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        
        print("Keyboard is showing")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.centerYConstraint.constant = -(keyboardSize.height / 2)
                self.view.layoutIfNeeded()
                
            })
            
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        
        print("keyboard is hiding")
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.centerYConstraint.constant = 0
            
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addKeyboardNotifications()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    @IBAction func onCreateAccount(_ sender: UIButton) {
        
       self.view.endEditing(true)
        SVProgressHUD.show()
        
        if (nameView.userInputLabel.text?.count)! < 2 {
            
            SVProgressHUD.showError(withStatus: "A name must be provided")
            
            nameView.userInputLabel.becomeFirstResponder()
            
        } else {
        
            sender.isEnabled = false
            
            Auth.auth().createUser(withEmail: emailView.userInputLabel.text!, password: passwordView.userInputLabel.text!) { (user, error) in
                
                if error != nil {
                    
                    let errorStr:String = (error?.localizedDescription)!
                    
                    SVProgressHUD.showError(withStatus: errorStr)
                    
                    if errorStr.range(of: "email") != nil {
                        
                        self.emailView.userInputLabel.becomeFirstResponder()
                        
                    } else if errorStr.range(of: "password") != nil {
                        
                        self.passwordView.userInputLabel.becomeFirstResponder()
                        
                    }
                    
                    sender.isEnabled = true
                    
                } else {
                    
                    SVProgressHUD.dismiss()
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.nameView.userInputLabel.text
                 
                    changeRequest?.commitChanges { (error) in
                        
                        if error != nil {
                            
                            SVProgressHUD.showError(withStatus: error?.localizedDescription)
                            
                        } else {
                            
                            SVProgressHUD.showSuccess(withStatus: "User created with success.")
                            
                            self.addInitialData()
                            self.switchToDashboard()
                            
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    func addInitialData() {
        
        
        ref = Database.database().reference()
        
        let key      = ref.childByAutoId().key
        let userID   = Auth.auth().currentUser?.uid
        let userName = Auth.auth().currentUser?.displayName
        
        let postBusiness = ["uid": userID,
                            "title": "",
                            "logo" : ""]
        
        let postUser = ["\(key)" : ["buid"  : key,
                        "role" : "owner"],
                        "default_buid" : key] as [String : Any]
        
        let postUserObject = ["displayName"  : userName,
                              "imageFilePath" : ""]
        
        let childUpdates = ["/business/\((key))/info": postBusiness,
                            "/user-roles/\(userID!)": postUser,
                            "/user-info/\(userID!)" : postUserObject]
        
        
        
        ref.updateChildValues(childUpdates)
    
    }
    
    func switchToDashboard() {
        
        self.dismiss(animated: true) {
            
            self.delegate.onCreated()
            
        }
    }
    
}
