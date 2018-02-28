//
//  AddNewProductViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 13/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseDatabase


extension AddNewProductViewController:NavigationDelegate {

    func onDismiss() {
        
        productsBank?.removeProduct(key: (currentSelectedProduct?.sku)!)
        self.dismiss(animated: true)
        
    }
    
}

extension AddNewProductViewController:UITextFieldDelegate {
    
   func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print(" textFieldDid Begin Editing ")
        
        if textField == productDescription.userInputLabel {
            productDescription.textFieldDidBeginEditing(textField)
        } else if textField == productPrice.userInputLabel {
            productPrice.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print(" textFieldDid END Editing ")
        
        if textField == productDescription.userInputLabel {
            productDescription.textFieldDidEndEditing(textField)
            
        } else if textField == productPrice.userInputLabel {
            productPrice.textFieldDidEndEditing(textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == productDescription.userInputLabel {
            
            productPrice.userInputLabel.becomeFirstResponder()
            
        }
        
        return true
        
    }
    
}


extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "£"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
       /* guard number != 0 as NSNumber else {
            return ""
        }*/
        
        return formatter.string(from: number)!
    }
    
    func getValueWithoutCurrency() -> Double {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "£"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
     
        return number as! Double
    }
}

protocol AddNewProductViewControllerDelegate {
    
    func onProductUpdated()
    
}



class AddNewProductViewController: HeraViewController {

    @IBOutlet var navController: NavigationView!
    
    @IBOutlet var productDescription: UserInputView!
    @IBOutlet var productPrice: UserInputView!
    
    @IBOutlet var centerY: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    var model:ProductBankModel?
    var delegate:AddNewProductViewControllerDelegate?
    
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        navController.labelTitle.text = "Add new product"
        navController.setSubtitle(value: (currentSelectedProduct?.sku)!)
        navController.showCloseButton(sender:self)
        
        productDescription.titleValue.text = "Enter product description"
        productDescription.userInputLabel.delegate = self
        
        productPrice.titleValue.text = "Enter product price"
        
        productPrice.userInputLabel.keyboardType = .numbersAndPunctuation
        productPrice.setValue(value: "£0.00")
        productPrice.userInputLabel.keyboardType = .numberPad
        
        
        setScrollTap(scrollView: scrollView)
        setKeyboard(constraint: centerY)
        addKeyboardNotifications()
        
        productPrice.userInputLabel.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        
        if currentSelectedProduct?.exists == true {
            
            navController.labelTitle.text = "Confirm product details"
            productDescription.setValue(value: (currentSelectedProduct?.title)!)
            
        } else {
            
        //    currentSelectedProduct?.update(title: "")
            
        }
        
        
        
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    @IBAction func onAddAction(_ sender: Any) {
        
        if productDescription.userInputLabel.text == "" {
            SVProgressHUD.showError(withStatus: "Invalid description")
        } else {
            if productPrice.userInputLabel.text?.getValueWithoutCurrency() == 0 {
                SVProgressHUD.showError(withStatus: "Invalid price")
            } else {
                
                addNewProduct()
                
               
            }
        }
        
    }
    
    func addNewProduct() {
        
        
        SVProgressHUD.show()
        
        let postItem:[String:Any]  = ["title": productDescription.userInputLabel.text!,
                                      "price" :productPrice.userInputLabel.text?.getValueWithoutCurrency()]
     
        ref = Database.database().reference()
        ref?.child((currentSelectedFeed?.locationId)!).child("addedBarcodes").child((currentSelectedProduct?.sku!)!).updateChildValues(postItem, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus:error?.localizedDescription)
                
            } else {
                
                currentSelectedProduct?.title = postItem["title"] as! String
                currentSelectedProduct?.price = postItem["price"] as! Double
                
                self.delegate?.onProductUpdated()
                self.dismiss(animated: true)
                
                SVProgressHUD.dismiss()
                
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
