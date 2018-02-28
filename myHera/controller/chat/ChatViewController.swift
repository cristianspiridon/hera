//
//  ChatViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 28/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD


extension ChatViewController: NavigationDelegate {

    func onDismiss() {
        
        self.dismiss(animated: true)
        
    }
    
}

extension ChatViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print(" textFieldDid Begin Editing ")
        
        if textField == userComment.userInputLabel {
            userComment.textFieldDidBeginEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print(" textFieldDid END Editing ")
        
        if textField == userComment.userInputLabel {
            userComment.textFieldDidEndEditing(textField)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userComment.userInputLabel {
            
            onSelect(textField)
            
        }
        
        return true
        
    }
    
}

extension ChatViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return messagesObject.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! MessageTableViewCell
        
        cell.setData(model: (messagesObject.messages[indexPath.row]))
      
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            
            messagesObject.deleteMessageAt(index: indexPath.row)
            
        }
        
    }
    
}

extension ChatViewController: MessagesBankDelegate {
    func onChildAdded() {

        self.tableView.insertRows(at: [IndexPath(row: self.messagesObject.messages.count-1, section: 0)], with: UITableViewRowAnimation.none)
        updateScrollHeight()
       
    }
    
    func onChildDeleted(index:Int) {
     
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.none)
        updateScrollHeight()
    }
    
    
}

extension ChatViewController:LocationBankModelDelegate {
    func onEventCreatedWithSucces() {
        
    }
    
    
    func onImageReady() {
      
        if locationModel?.image != nil {
            mainImage.image = locationModel?.image
        }
       
    }
    
    func onLocationDataReady() {
    
        if locationModel != nil {
    
            
            eventTitle.text = currentFeed?.name
            eventSubtitle.text = "\((locationModel?.name)!) \((locationModel?.postcode)!)"

            
        }
     
    }
    
    
}




class ChatViewController: HeraViewController {

    @IBOutlet var navController: NavigationView!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var eventTitle: UILabel!
    @IBOutlet var eventSubtitle: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var blackCover: UIView!
    
    var currentFeed:FeedBankModel?
    
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var addCommnetConstrain: NSLayoutConstraint!
    @IBOutlet var scrollContentHeightConstant: NSLayoutConstraint!

    @IBOutlet var sendY: NSLayoutConstraint!
    @IBOutlet var userComment: UserInputView!
    @IBOutlet var scrollView: UIScrollView!
    
    var messagesObject:MessagesBankObject!
    var locationModel:LocationBankModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navController.labelTitle.text = "Discussions"
        navController.showCloseButton(sender: self)
        
        messagesObject = messagesBank?.getMessagesFor(stocktakeId: (currentFeed?.key)!)
        messagesObject.delegates.append(self)
        
        // Setup Location Model to get the image, title and adress
        
        locationModel = (locationsBank?.getLocationBy(locationID: (currentFeed?.locationId)!))!
        locationModel?.delegates.append(self)

        onImageReady()
        onLocationDataReady()
        
        userComment.titleValue.text = "Add a comment"
        userComment.userInputLabel.returnKeyType = .send
        userComment.userInputLabel.delegate = self
        
        
        sendY.constant = 10
        self.blackCover.alpha = 0
        self.blackCover.isUserInteractionEnabled = false
        
        addKeyboardNotifications()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let tableH = tableView.contentSize.height
        
        tableHeight.constant = tableH
        scrollContentHeightConstant.constant = max((380 + tableH - self.view.frame.height), 0)
        
        
    }
    
    @IBAction func onSelect(_ sender: Any) {
        
        
        SVProgressHUD.show()
        
        if userComment.userInputLabel.text != "" {
            
            self.view.endEditing(true)
            messagesObject.addMessage(message: self.userComment.userInputLabel.text!)
            userComment.setValue(value: "")
            self.sendY.constant = 10
            
         //   scrollToBottom()
           
            
        } else {
            
            SVProgressHUD.showError(withStatus: "Message is invalid or needs to be longer")
            
        }
        
    }
    
    func updateScrollHeight() {
        
        
        let tableH = tableView.contentSize.height + 200

        tableHeight.constant = tableH
        scrollContentHeightConstant.constant = max((380 + tableH - self.view.frame.height), 0)
       
        scrollToBottom()
    }
    
    func scrollToBottom(){
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height -
            scrollView.bounds.size.height + 100)
        scrollView.setContentOffset(bottomOffset, animated: true)
        
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        
        print("Keyboard is showing")
        self.blackCover.isUserInteractionEnabled = true
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.sendY.constant = -15
                self.addCommnetConstrain.constant = keyboardSize.height
                self.view.layoutIfNeeded()
                
                self.blackCover.alpha = 0.60
                
            })
            
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        
        print("keyboard is hiding")
        
        self.view.layoutIfNeeded()
        self.blackCover.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.addCommnetConstrain.constant = 0
            
            if self.userComment.userInputLabel.text != "" {
                self.sendY.constant = -15
            } else {
                 self.sendY.constant = 10
            }
            
             self.blackCover.alpha = 0
            
            
            self.view.layoutIfNeeded()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
