//
//  Participants.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

protocol ParticipantsViewDelegate {

    func onSelect()
}

extension Participants:ParticipantsListDelegate {
    func onParticipantChildAdded() {
        updatePicture()
    }
    
    func onParticipantFootPrintDeleted(index: Int) {
        updatePicture()
    }
}

class Participants: XibView {

    @IBOutlet var firstPicture: RoundedPicture!
    @IBOutlet var secondPicture: RoundedPicture!
    @IBOutlet var thirdPicture: RoundedPicture!
    @IBOutlet var label: UILabel!
    
    var delegate:ParticipantsViewDelegate?
    var list:ParticipantsList?
    
    var roundedPics:[RoundedPicture] = [RoundedPicture]()
    
    func updatePicture() {
        
        if let numOfParticipants = list?.participants.count {
            
            if numOfParticipants > 0 {
           
                
                for i in 0...min(2, numOfParticipants - 1) {
                    
                    addPicture(index:i, uid:(list?.participants[i].uid)!)
                    
                }
                
                if numOfParticipants == 1 {
                    
                    label.text = "1 participant in the event"
                    
                } else {
                    
                    label.text = "\(numOfParticipants) participants in the event"
                }
                
                
            }
           
        }
        
       
        
    }
    
    func addPicture(index:Int, uid:String) {
        
        print("Add rounded picture at \(index) for \(uid)")
        
        roundedPics[index].setupWith(userID: uid, pictSize: 35)
        roundedPics[index].isHidden = false
        
    }
    
    @IBAction func onAction(_ sender: Any) {
        
        if delegate != nil {
            delegate?.onSelect()
        }
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    func setup (feed:FeedBankModel) {
    
       
     //   firstPicture.setupWith(userID: (feed.uid)!, pictSize: 35)
        
        secondPicture.isHidden = true
        thirdPicture.isHidden = true
        
        roundedPics.append(firstPicture)
        roundedPics.append(secondPicture)
        roundedPics.append(thirdPicture)
        
        list = participantsBank?.getParticipantsBy(feedId: (feed.key)!)
        list?.delegates.append(self)
        
        updatePicture()
        
    }


}
