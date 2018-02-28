//
//  LocationViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 05/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD

extension LocationViewController:NavigationDelegate {

    func onDismiss() {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }

}

extension LocationViewController:LocationBankModelDelegate {
    func onEventCreatedWithSucces() {
        
    }
    
    func onLocationDataReady() {
        
        nameView.setValue(value: (locationModel?.name)!)
        addressView.setValue(value: (locationModel?.postcode)!)
    }
    
    func onImageReady() {
        
        if locationModel?.image != nil {
       
            mainImageView.image = (locationModel?.image)!
            pictureAction.setTitle("Change image", for: .normal)
        }
        
    }
    
    
}

extension LocationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            
         
            if locationModel?.imageFilePath != "" {
            
                imgBank?.deleteImageAt(path: (locationModel?.imageFilePath)!)
                
            }
            
            SVProgressHUD.show()
            
            
            let imgPath:String = locationsBank!.getRandomFilePath()
            
            locationsBank?.upload(image: image, at: imgPath, completionHandler: { (success) in
                
                locationsBank?.updateImage(filePath: imgPath, forLocationId: (self.locationModel?.key)!)
                
                  SVProgressHUD.showSuccess(withStatus: "Image uploaded")
            })
            
        }
    }
    
}

extension LocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nameView.userInputLabel {
            
            nameView.textFieldDidBeginEditing(textField)
            
        } else if textField == addressView.userInputLabel {
            
            addressView.textFieldDidBeginEditing(textField)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == nameView.userInputLabel {
            
            nameView.textFieldDidEndEditing(textField)
            
        } else if textField == addressView.userInputLabel {
            
            addressView.textFieldDidEndEditing(textField)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameView.userInputLabel {
            
            self.view.endEditing(true)
            locationModel?.updateLocation(name: nameView.userInputLabel.text!)
            
        } else if textField == addressView.userInputLabel {
            
            self.view.endEditing(true)
            locationModel?.updateLocation(postcode: addressView.userInputLabel.text!)
            
        }
        
        
        return true
    }
    
}


class LocationViewController: HeraViewController {
    
    @IBOutlet var navController: NavigationView!
    
    @IBOutlet var nameView: UserInputView!
    @IBOutlet var addressView: UserInputView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollY: NSLayoutConstraint!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var pictureAction: UIButton!
    
    @IBAction func onPictureAction(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    var locationModel:LocationBankModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentClassName = "LocationViewController"

        navController.labelTitle.text = "Business location"
        navController.showCloseButton(sender: self)
        
        
        nameView.titleValue.text = "Enter location name"
        addressView.titleValue.text = "Enter location address"
        
        nameView.userInputLabel.returnKeyType = .done
        addressView.userInputLabel.returnKeyType = .done
        
        nameView.userInputLabel.delegate = self
        addressView.userInputLabel.delegate = self
        
  
        setKeyboard(constraint: scrollY)
        setScrollTap(scrollView: scrollView)
        
        if locationModel != nil {
    
            locationModel?.delegates.append(self)
            
            if (locationModel?.exists)! {
                
                onLocationDataReady()
                onImageReady()
                
            }
            
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }


}
