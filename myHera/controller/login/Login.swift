//
//  ViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 15/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

var userModel:UserModel?
var imgBank:ImageBank?
var userBank:UserBank?
var messagesBank:MessagesBank?
var feedBank:FeedBank?
var locationsBank:LocationsBank?
var businessBank:BusinessBank?
var regionBank:RegionBank?
var areasBank:AreasBank?
var productsBank:ProductBank?
var participantsBank:ParticipantsBank?



struct LoginConstant {
    
    static let loginTitle           = "Sign in"
    static let forgotTitle          = "Account help"
    static let forgotSecondaryTitle = "Forgot Password?"
    
    static let loginSubtitle        = "to continue to Hera"
    static let forgotSubtitle       = "recover your password by email"
    
    static let emailLabel           = "Enter your email"
    static let passwordLabel        = "Enter your password"
    static let nameLabel            = "Enter your name"
    
    static let loginAction          = "LOG IN"
    static let forgotAction         = "RESET"
    
}


extension Login:UserModelDelegate {
    
    func onBusinessModel() {
        
        self.performSegue(withIdentifier: "startApp", sender: self)
        
    }
    
}

class Login: HeraViewController, UITextFieldDelegate, CreateNewAccountDelegate {
    
    @IBOutlet var centerViewConstrain: NSLayoutConstraint!
    @IBOutlet var emailInput: UserInputView!
    @IBOutlet var passwordInput: UserInputView!
    
    @IBOutlet var titleValue: TitleView!
    
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var labelButton: UIButton!
    
    var isForgotPage:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLogin()
    }
    
    func initLogin() {
        
        titleValue.labelTitle.text = LoginConstant.loginTitle
        titleValue.labelSubtitle.text = LoginConstant.loginSubtitle
        actionButton.setTitle(LoginConstant.loginAction, for: .normal)
        labelButton.setTitle(LoginConstant.forgotSecondaryTitle, for: .normal)
        
        
        emailInput.titleValue.text = LoginConstant.emailLabel
        passwordInput.titleValue.text = LoginConstant.passwordLabel
        passwordInput.userInputLabel.isSecureTextEntry = true
        
        emailInput.userInputLabel.keyboardType = UIKeyboardType.emailAddress
        
        emailInput.userInputLabel.delegate = self
        passwordInput.userInputLabel.delegate = self
        
        imgBank = ImageBank()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (Auth.auth().currentUser?.uid) != nil {
            
            initClasses()
            
            
        } else {
            addKeyboardNotifications()
        }
        
    }
    
    func initClasses() {
        
        userBank  = UserBank()
        messagesBank = MessagesBank()
        feedBank = FeedBank()
        locationsBank = LocationsBank()
        businessBank = BusinessBank()
        regionBank = RegionBank()
        areasBank  = AreasBank()
        productsBank = ProductBank()
        participantsBank = ParticipantsBank()
        
        userModel = UserModel(uid: (Auth.auth().currentUser?.uid)!)
        userModel?.delegates.append(self)
        
    }
    
    
    func onCreated() {
        //  self.dismiss(animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CreateNewUser" {
            
            let vc:CreateNewAccount = (segue.destination as? CreateNewAccount)!
            
            vc.delegate = self
            
        }
        
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == emailInput.userInputLabel {
            emailInput.textFieldDidBeginEditing(textField)
            
        } else {
            passwordInput.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == emailInput.userInputLabel {
            emailInput.textFieldDidEndEditing(textField)
        } else {
            passwordInput.textFieldDidEndEditing(textField)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailInput.userInputLabel {
            
            
            if isForgotPage {
                
                recoverPassowrd()
                
            } else {
                
                passwordInput.userInputLabel.becomeFirstResponder()
            }
            
        }
        
        if textField == passwordInput.userInputLabel {
            
            self.onAction(actionButton)
        }
        
        
        
        return true
    }
    
    
    override func keyboardWillShow(notification: NSNotification) {
        
        print("Keyboard is showing")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.centerViewConstrain.constant = -(keyboardSize.height / 2)
                self.view.layoutIfNeeded()
                
            })
            
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        
        print("keyboard is hiding")
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.centerViewConstrain.constant = 0
            
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func onForgotPassword(_ sender: Any) {
        
        self.view.endEditing(true)
        self.disableAllButtons()
        
        if self.labelButton.titleLabel?.text == LoginConstant.loginTitle {
            
            gotoLogin()
            
        } else {
            
            gotoForgot()
        }
        
    }
    
    func gotoLogin(){
        
        isForgotPage = false
        
        animateToPage(midPointX: Double(self.view.layer.bounds.width),
                      newLabelButtonValue: LoginConstant.forgotSecondaryTitle,
                      newButtonValue: LoginConstant.loginAction,
                      newTitle: LoginConstant.loginTitle,
                      newSubtitle: LoginConstant.loginSubtitle,
                      isPasswordVisible: true)
        
    }
    
    func gotoForgot(){
        
        isForgotPage = true
        
        animateToPage(midPointX: Double(-self.view.layer.bounds.width),
                      newLabelButtonValue: LoginConstant.loginTitle,
                      newButtonValue: LoginConstant.forgotAction,
                      newTitle: LoginConstant.forgotTitle,
                      newSubtitle: LoginConstant.forgotSubtitle,
                      isPasswordVisible: false)
        
    }
    
    func animateToPage(midPointX:Double, newLabelButtonValue:String, newButtonValue:String, newTitle:String, newSubtitle:String, isPasswordVisible:Bool) {
        
        
        self.passwordInput.isUserInteractionEnabled  = false
        
        
        
        
        let originalButtonX = self.actionButton.frame.origin.x
        let originalLabelX  = self.labelButton.frame.origin.x
        let originalTitleX  = self.titleValue.frame.origin.x
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            self.titleValue.frame.origin.x  = CGFloat(midPointX)
            self.labelButton.frame.origin.x = CGFloat(midPointX)
            
            self.actionButton.frame.origin.x   = CGFloat(midPointX)
            self.actionButton.alpha = 0
            
            self.passwordInput.alpha = 0
            
            
        }) { (isFinished:Bool) in
            
            self.titleValue.labelTitle.text = newTitle
            self.titleValue.labelSubtitle.text = newSubtitle
            self.titleValue.frame.origin.x  = -CGFloat(midPointX)
            
            self.labelButton.frame.origin.x = -CGFloat(midPointX)
            
            self.actionButton.frame.origin.x   = -CGFloat(midPointX)
            
            self.actionButton.setTitle(newButtonValue, for: .normal)
            self.actionButton.isEnabled = true
            
            self.labelButton.titleLabel?.text = newLabelButtonValue
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                
                self.titleValue.frame.origin.x  = originalTitleX
                self.labelButton.frame.origin.x = originalLabelX
                self.actionButton.frame.origin.x   = originalButtonX
                
                self.actionButton.alpha = 1
                
                if isPasswordVisible {
                    
                    self.passwordInput.alpha = 1
                    self.passwordInput.isUserInteractionEnabled  = true
                    
                }
            })
        }
        
        
    }
    
    
    @IBAction func onGetStarted(_ sender: Any) {
        
        self.performSegue(withIdentifier: "CreateNewUser", sender: self)
    }
    
    @IBAction func onAction(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.disableAllButtons()
        
        SVProgressHUD.show()
        
        
        if actionButton.titleLabel?.text == LoginConstant.loginAction {
            
            loginWithEmail(sender:sender)
            
        } else {
            
            recoverPassowrd()
        }
    }
    
    func loginWithEmail(sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailInput.userInputLabel.text!, password: passwordInput.userInputLabel.text!) { (user, error) in
            
            if error != nil {
                
                let errorStr:String = (error?.localizedDescription)!
                
                SVProgressHUD.showError(withStatus: errorStr)
                
                if errorStr.range(of: "email") != nil {
                    
                    self.emailInput.userInputLabel.becomeFirstResponder()
                    
                } else if errorStr.range(of: "password") != nil {
                    
                    self.passwordInput.userInputLabel.becomeFirstResponder()
                    
                }
                
            } else {
                
                let userName = user?.displayName
                
                SVProgressHUD.showSuccess(withStatus: "Welcome \(userName!)")
                
                userModel = UserModel(uid: (Auth.auth().currentUser?.uid)!)
                userModel?.delegates.append(self)
                
                
            }
            
            self.enableAllButtons()
            
        }
        
    }
    
    func enableAllButtons() {
        
        view.isUserInteractionEnabled = true
        
    }
    
    func disableAllButtons() {
        view.isUserInteractionEnabled = true
    }
    
    func recoverPassowrd (){
        
        Auth.auth().sendPasswordReset(withEmail: emailInput.userInputLabel.text!) { (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
                self.emailInput.userInputLabel.becomeFirstResponder()
                
            } else {
                
                SVProgressHUD.showSuccess(withStatus: "We have sent you an email!")
                
                self.passwordInput.userInputLabel.text = ""
                self.gotoLogin()
                
            }
            
            self.enableAllButtons()
            
            
        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

