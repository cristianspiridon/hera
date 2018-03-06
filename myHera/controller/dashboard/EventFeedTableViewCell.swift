//
//  EventFeedTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 27/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

protocol FeedCellDelegate {
    
    func showDiscussionsFor(feed:FeedBankModel)
    
}



extension EventFeedTableViewCell:FeedBankModelDelegate {

    func onLocationImageReady(image: UIImage) {
        
        if image != nil {
        
            self.imgView.image = image
            
        }
        
    }
    
    
    func onUpdate() {
        
        print("on Update \(feed.locationName)")
        
        titleLabel.text = "\(feed.locationName) - \(feed.name!)"
        
        showAuthorDetails()
        
        
    }
    
    
}

extension EventFeedTableViewCell:UserBankObjectDelegate {
    func onProfileImageChange() {
        
        
        if userObject?.profileImage != nil {
            
            profilePicView.image = userObject?.profileImage
        }
        
    }
    
    
    func onDisplayNameChange() {
        
        subtitleLabel.text = "\((userObject?.displayName)!) on \((feed.eventDate!))"
        
    }
    
}

extension EventFeedTableViewCell:MessagesBankDelegate {
    
    func onChildDeleted(index: Int) {
        numOfMessages.text = "\((messagesObject?.messages.count)!)"
    }
    
    
    func onChildAdded() {
        
        numOfMessages.text = "\((messagesObject?.messages.count)!)"
        
    }
    
}

class EventFeedTableViewCell: UITableViewCell {
    
    @IBOutlet var actionVIew: UIView!
    @IBOutlet var profilePicView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var numOfMessages: UILabel!
    
    @IBOutlet var imgView: UIImageView!
    
    var userObject:UserBankObject?
    
    var feed:FeedBankModel!
    var delegate:FeedCellDelegate!
    
    var messagesObject:MessagesBankObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        actionVIew.layer.cornerRadius = 15
        actionVIew.layer.masksToBounds = true
        
        profilePicView.layer.cornerRadius = profilePicView.frame.width / 2
        profilePicView.layer.masksToBounds = true
        
       
    }
    
    
    @IBAction func showDiscussions(_ sender: Any) {
       
        delegate.showDiscussionsFor(feed: feed)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setData(feed:FeedBankModel) {
        
        print("add  feedbank data ")
        
        self.feed = feed
        self.feed.delegates.append(self)
        
        
        titleLabel.text = ""
        subtitleLabel.text = ""
        numOfMessages.text = "0"

        print("set Feedbank data \(feed.exists)")
        
        if feed.exists {
            
            onUpdate()
            
            onLocationImageReady(image: (feed.locationModel?.image)!)
            
        }
        
        messagesObject = messagesBank?.getMessagesFor(stocktakeId: feed.key!)
        messagesObject?.delegates.append(self)
        
    }
    
    func showAuthorDetails() {
        
        userObject = userBank?.getUserObject(with: feed.uid!)
        userObject?.delegates.append(self)
        
        if userObject?.exists == true  {
            
            onDisplayNameChange()
            onProfileImageChange()
        }
        
    }

}
