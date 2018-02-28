//
//  HeraViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 18/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD

class HeraViewController: UIViewController {

    
    var keyboardConstraint:NSLayoutConstraint?
    
    var parentClassName:String = ""
    
    override func viewDidLoad() {
        
        print("Hera controller loaded")
        
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        
        
        
    }
    
    func setScrollTap(scrollView:UIScrollView) {
        
        let touchScroll = UITapGestureRecognizer(target: self, action: #selector(self.singleTapGestureCaptured(gesture:)))
        scrollView.addGestureRecognizer(touchScroll)
        
    }
    
    @objc func singleTapGestureCaptured(gesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        addKeyboardNotifications()
        
    }
    
    
    
    func addKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func setKeyboard(constraint:NSLayoutConstraint) {
        
        print("set keyboard constraing \(constraint)")
        
        self.keyboardConstraint = constraint
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("\(parentClassName)    Keyboard will show \(keyboardConstraint)")
        
        if keyboardConstraint != nil {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                self.view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.keyboardConstraint?.constant = -(keyboardSize.height / 2)
                    self.view.layoutIfNeeded()
                    
                })
                
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        print("\(parentClassName)    keyboard will hide")
        
        if keyboardConstraint != nil {
           
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.keyboardConstraint?.constant = 0
                
                self.view.layoutIfNeeded()
            })
            
        }
        
       
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
