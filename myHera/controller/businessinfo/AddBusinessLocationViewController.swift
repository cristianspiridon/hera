//
//  AddBusinessLocationViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 22/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

extension AddBusinessLocationViewController:LocationsBankDelegate {
    
    func onLocationCreatedWithSuccess() {
        
        onDismiss()
    }
    
}

extension AddBusinessLocationViewController: NavigationDelegate {

    func onDismiss() {
        
        self.dismiss(animated: true)
        
    }
    
    
}

extension AddBusinessLocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == locationNameView.userInputLabel {
            locationNameView.textFieldDidBeginEditing(textField)
        }
        
        if textField == postCodeView.userInputLabel {
            postCodeView.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == locationNameView.userInputLabel {
            locationNameView.textFieldDidEndEditing(textField)
        }
        
        if textField == postCodeView.userInputLabel {
            postCodeView.textFieldDidEndEditing(textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == locationNameView.userInputLabel {
            
            postCodeView.userInputLabel.becomeFirstResponder()
            
        } else if textField == postCodeView.userInputLabel {
            
           createNewLocation()
        }
        
        
        return true
    }
    
}


extension AddBusinessLocationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
     
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)

            imageView.image   = image
            userSelectedImage = image
            pictureAction.setTitle("Change image", for: .normal)
            
        }
    }
    
}

class AddBusinessLocationViewController: HeraViewController {

    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var pictureAction: UIButton!
    
    @IBOutlet var locationNameView: UserInputView!
    @IBOutlet var postCodeView: UserInputView!
    
    @IBOutlet var navController: NavigationView!
    
    @IBOutlet var centerYConstraint: NSLayoutConstraint!
    
    var userSelectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.labelTitle.text = "New location"
        navController.showCloseButton(sender: self)
        
        
        locationNameView.titleValue.text = "Enter location name"
        postCodeView.titleValue.text = "Enter location postcode"
        
        locationNameView.userInputLabel.delegate = self
        postCodeView.userInputLabel.delegate = self
        
        locationsBank?.delegates.append(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addKeyboardNotifications()
        
    }
    
    // Mark: - Create new location
    @IBAction func onCreate(_ sender: Any) {
        createNewLocation()
    }
    
    func createNewLocation() {
        
        self.view.endEditing(true)
        
        if imageView.image == nil {
            
            
            locationsBank?.createNewLocation(locationName: locationNameView.userInputLabel.text!, locationPostcode: postCodeView.userInputLabel.text!, imgPath: "")
            
        } else {
            
            locationsBank?.createNewLocationWithImage(locationName: locationNameView.userInputLabel.text!, locationPostcode: postCodeView.userInputLabel.text!, image: userSelectedImage!)
            
        }
        
    }
    
    
    // Mark: Picture action
    
    
    @IBAction func onPictureAction(_ sender: Any) {
        
        self.showImagePicker()
    }
    
    func showImagePicker() {
        
        print("show image picker")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
  
   
    
    //Mark: - Keyboard view action
    
    override func keyboardWillShow(notification: NSNotification) {
        
        print("Keyboard is showing")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.centerYConstraint.constant -= (keyboardSize.height / 2)
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

}
