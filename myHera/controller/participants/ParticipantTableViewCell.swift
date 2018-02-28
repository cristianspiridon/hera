//
//  ParticipantTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 01/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension ParticipantTableViewCell:ParticipantDelegate {
    
    func onUpdate() {
        
        infoLabel.text = "\(convertToNumber(value: (model?.quantity!)!)) units in \(converToHHMMSS(seconds: (model?.duration!)!))"
        
       
        let duration:Int = (model?.duration)!
        let quantity:Int = (model?.quantity)!
        
        
        if duration != 0 && quantity != 0 {
          
            
            let perUnitTime:Float = (3600 / Float(duration))
            let bph = Int(perUnitTime * Float(quantity))
            
            speedLabel.text = "\(convertToNumber(value: bph))BPH"
            
        }
        
        
    }
    
}

extension ParticipantTableViewCell:UserBankObjectDelegate {
    func onProfileImageChange() {
       
    }
    
    
    func onDisplayNameChange() {
        
        userNameLabel.text = userObject?.displayName
        
    }
    
}


class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet var profilePic: RoundedPicture!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    var model:Participant?
    
    var userObject:UserBankObject?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setdData(model:Participant) {
        
        self.model = model
        model.delegate = self
       
        speedLabel.text = ""
        
        onUpdate()
        
        profilePic.setupWith(userID: model.uid!, pictSize: 45)
        
        userObject = userBank?.getUserObject(with: model.uid!)
        userObject?.delegates.append(self)
        
        if userObject?.exists == true  {
            
            onDisplayNameChange()
        }
        
    }
    
    
    func convertToNumber(value:Int) -> String {
        
        let cForm = NumberFormatter()
        cForm.usesGroupingSeparator = true
        cForm.numberStyle = .decimal
        
        let priceString = cForm.string(from: NSNumber(value: value))
        
        return priceString!
        
    }
    
    func converToHHMMSS (seconds : Int) -> String {
        
        let HH = doubleDigit(digit: seconds / 3600)
        let mm = doubleDigit(digit: (seconds % 3600) / 60)
        let ss = doubleDigit(digit: (seconds % 3600) % 60)
        
        return "\(HH):\(mm):\(ss)"
    }
    
    
    func doubleDigit(digit:Int) -> String {
        
        if digit < 10 {
            
            return "0\(digit)"
            
        } else {
            return "\(digit)"
        }
        
    }

}
