//
//  MessageTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 29/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

extension MessageTableViewCell:UserBankObjectDelegate {
    
    func onProfileImageChange() {
        
        
        if userObject?.profileImage != nil {
        
            profilePicImage.image = userObject?.profileImage
        }
        
    }
    
    
    func onDisplayNameChange() {
        
        author.text = "\((userObject?.displayName)!) -  \((model?.dateStr)!)"
        
    }
}

class MessageTableViewCell: UITableViewCell {

    var model:MessageModel?
    
    
    @IBOutlet var author: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var profilePicImage: UIImageView!
    
    var userObject:UserBankObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(model:MessageModel){
        
        self.model = model
        
        userObject = (userBank?.getUserObject(with: model.uid!))!
        userObject?.delegates.append(self)
        
        if (userObject?.exists)! {
            
            onDisplayNameChange()
            onProfileImageChange()
        }
        
        message.text = model.message
        
        
        profilePicImage.layer.cornerRadius = profilePicImage.frame.width / 2
        profilePicImage.layer.masksToBounds = true
        
    }
    

}
