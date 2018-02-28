//
//  UserProfileViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 30/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import InteractiveSideMenu

extension UserProfileViewController: NavigationDelegateOptionalMenu, SideMenuItemContent {

    func onShowMenu() {
        
        showSideMenu()
    }
    
}

extension UserProfileViewController:UserBankObjectDelegate {
    
    
    func onDisplayNameChange() {
        
        displayName.setValue(value: (userModel?.selfObject?.displayName)!)
        
    }
    
    func onProfileImageChange() {
        
        if userModel?.selfObject?.profileImage != nil {
            
            updateProfileImage(with: (userModel?.selfObject?.profileImage)!)
            
        }
        
    }
    
    
    
    
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            
          //  updateProfileImage(with: image)
            
            userModel?.savePictureProfile(image: image)
            
            
        }
    }
    
}

extension UserProfileViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == displayName.userInputLabel {
            displayName.textFieldDidBeginEditing(textField)
            
        } else if textField == email.userInputLabel {
            email.textFieldDidBeginEditing(textField)
            
        } else if textField == password.userInputLabel {
            password.textFieldDidBeginEditing(textField)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == displayName.userInputLabel {
            displayName.textFieldDidEndEditing(textField)
            
        } else if textField == email.userInputLabel {
            email.textFieldDidEndEditing(textField)
            
        } else if textField == password.userInputLabel {
            password.textFieldDidEndEditing(textField)
            
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == displayName.userInputLabel {
            
            userModel?.updateDisplayName(with: textField.text!)
           
            
        } else if textField == email.userInputLabel {
            
            userModel?.updateEmail(with: textField.text!)
            
        } else if textField == password.userInputLabel {
           
            userModel?.updatePassword(with: textField.text!)
        }
        
        return true
    }
    
}


class UserProfileViewController: HeraViewController {
    
    @IBOutlet var navController: NavigationView!
    @IBOutlet var profilePicView: UIView!
    
    @IBOutlet var displayName: UserInputView!
    @IBOutlet var email: UserInputView!
    @IBOutlet var password: UserInputView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var profilePict: UIImageView!
    
    
    @IBOutlet var centerY: NSLayoutConstraint!
    @IBOutlet var profilePictHeight: NSLayoutConstraint!
    @IBOutlet var profilePictWidth: NSLayoutConstraint!
    
    @IBOutlet var imgContainerH: NSLayoutConstraint!
    @IBOutlet var imgContainerW: NSLayoutConstraint!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navController.labelTitle.text = "User profile"
        navController.showMenuButton(sender:self)
        
        
        profilePict.layer.cornerRadius = 50
        profilePict.layer.masksToBounds = true
        
        displayName.titleValue.text = "Display name"
        email.titleValue.text = "Email address"
        password.titleValue.text = "New password"
        
        
        email.setValue(value: (userModel?.emailAddress())!)
        
        password.userInputLabel.isSecureTextEntry = true
        
        displayName.userInputLabel.returnKeyType = .done
        email.userInputLabel.returnKeyType = .done
        password.userInputLabel.returnKeyType = .done
        
        
        let touchScroll = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.singleTapGestureCaptured(gesture:)))
        
        scrollView.addGestureRecognizer(touchScroll)
        
        let changePicture = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.changePicture(gesture:)))
        
        profilePicView.addGestureRecognizer(changePicture)
        
        displayName.userInputLabel.delegate = self
        email.userInputLabel.delegate = self
        password.userInputLabel.delegate = self
        
        userModel?.selfObject?.delegates.append(self)
        
        if (userModel?.selfObject?.exists)! {
            
            onDisplayNameChange()
            onProfileImageChange()
        }
    }
    
    func updateProfileImage(with:UIImage) {
        
        profilePict.image = with
        
        
    }
    
    @objc func changePicture(gesture: UITapGestureRecognizer) {
        
        
        self.profilePicView.alpha = 0.6
        UIView.animate(withDuration: 0.5, animations: {
            
           self.profilePicView.alpha = 1
            
        })
        
        showImagePicker()
    }
    
    func showImagePicker() {
        
        print("show image picker")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addKeyboardNotifications()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Keyboard show and hide
    
    override func keyboardWillShow(notification: NSNotification) {
        
        print("Keyboard is showing")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.centerY.constant = -(keyboardSize.height / 2)
                self.view.layoutIfNeeded()
                
            })
            
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        
        print("keyboard is hiding")
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.centerY.constant = 0
            
            self.view.layoutIfNeeded()
        })
    }
    
    
}

