//
//  BusinessInfoViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 19/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase
import InteractiveSideMenu
import FirebaseStorage



extension BusinessInfoViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nameView.userInputLabel {
            nameView.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == nameView.userInputLabel {
            nameView.textFieldDidEndEditing(textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameView.userInputLabel {
            
            textField.resignFirstResponder()
            businessBankModel?.updateName(with: textField.text!)
        }
       
        
        return true
    }
    
}


extension BusinessInfoViewController:BusinessLocationsDelegate {
    
    func onChildAdded() {
    
        self.tableView.insertRows(at: [IndexPath(row: (locationsBank?.businessLocations.count)!-1, section: 0)], with: UITableViewRowAnimation.automatic)
     
        updateScrollHeight()
        
        
    }
    
    func onChildDeleted(index:Int) {
    
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
        updateScrollHeight()
        
    }
    
    
}


extension BusinessInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            
            businessBankModel?.saveLogo(image: image)
        }
    }
    
}

extension BusinessInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (locationsBank?.businessLocations.count)! + 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       
              return 75
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == locationsBank?.businessLocations.count
        {
            let cellAdd = tableView.dequeueReusableCell(withIdentifier: "addLocation") as! AddBusinessLocationTableViewCell
            
            return cellAdd
            
        } else {
            
            let cell:BussinessLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "businessLocation") as! BussinessLocationTableViewCell
            
            cell.setData(locationData: (locationsBank?.businessLocations[indexPath.row])!)
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == locationsBank?.businessLocations.count {
            
            return false
        } else {
            return true
       }
        
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            print("Deleted")
            
            locationsBank?.deleteLocationAt(index: indexPath.row)
            
        }
        
    }
    
}

extension BusinessInfoViewController: NavigationDelegateOptionalMenu, SideMenuItemContent {

    func onShowMenu() {
        
        print("Show side menu")
        showSideMenu()
    }
    
}

extension BusinessInfoViewController:BusinessLocationCellDelegate {
    func onSelect(locationModel: LocationBankModel) {
        
        self.selectedLocation = locationModel
        self.performSegue(withIdentifier: "showLocation", sender: self)
        
    }
}

extension BusinessInfoViewController:BusinessBankModelDelegate {
    
    func onName(name: String) {
        
         self.nameView.setValue(value: name)
    }
    
    func onImage(image: UIImage) {
        
        print("Business logo has changed in Business Info view ")
        
        self.logoImageView.image = image
        self.pictureAction.setTitle("Change logo", for: .normal)
    }
    
}

class BusinessInfoViewController: HeraViewController {

    @IBOutlet var nameView: UserInputView!
    @IBOutlet var navController: NavigationView!
    @IBOutlet var pictureAction: UIButton!
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var contentScrollHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollConstraint: NSLayoutConstraint!
    
    var imageUploadManager: ImageUploadManager?
    var selectedLocation:LocationBankModel?
    
    var businessId:String?
    var currentLogoPath:String = ""
    
    
    var businessBankModel:BusinessBankModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        parentClassName = "Business Info"
        
        
        navController.labelTitle.text = "Business info"
        navController.showMenuButton(sender: self)
        
        locationsBank?.getLocationsBy(businessID: (userModel?.currentBUID)!)
        locationsBank?.businessDelegates.append(self)
        
        businessBankModel = businessBank?.getBusinessBankBy(id: (userModel?.currentBUID)!)
        businessBankModel?.delegates.append(self)
        
        setBusinessName()
        setPicture()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        setKeyboard(constraint: scrollConstraint)
        setScrollTap(scrollView: scrollView)
   
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLocation" {
            
            let vc:LocationViewController = segue.destination as! LocationViewController
            vc.locationModel = selectedLocation
            
            
        }
        
    }
    
    
    
    func updateScrollHeight() {
        
        let tableH = CGFloat(((locationsBank?.businessLocations.count)! + 1) * 75)
        
        tableHeight.constant = tableH
        contentScrollHeight.constant = 376 + tableH - self.view.frame.height
        
        
    }
    

    
    // MARK: - Business name
    
    
    func setBusinessName() {
        
        nameView.titleValue.text = "Business name"
        
        nameView.userInputLabel.delegate = self
        nameView.userInputLabel.returnKeyType = .done
        
        if (businessBankModel?.exists)! {
            
            nameView.setValue(value: (businessBankModel?.name)!)
        }
   
        
    }

     // MARK: - Picture action
    @IBAction func onPictureAction(_ sender: UIButton) {
        
        showImagePicker()
        
    }
    
    func setPicture() {
        
        //default value
        
        pictureAction.setTitle("Add business logo", for: .normal)
     
        if businessBankModel?.logoImage != nil {
            onImage(image: (businessBankModel?.logoImage)!)
        }
        
    }
    
    func showImagePicker() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
