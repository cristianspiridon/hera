//
//  AreaTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension AreaTableViewCell: AreaBankModelDelegate {
    func getClassKey() -> String {
        
        return classKey!
    }
    
    
    func onAreaUpdate() {
        
        
        areaCode.text = areaModel?.key
        
        if areaModel?.progress == "completed" {
            checkSymbol.isHidden = false
        } else {
            checkSymbol.isHidden = true
        }
    }
    
}

extension  AreaTableViewCell:UserBankObjectDelegate {
    
    func onDisplayNameChange() {
        
        authorLabel.text = "by \((author?.displayName)!)"
    }
    
    func onProfileImageChange() {}
    
}

protocol AreaTableViewDelegate {
    
    func onAreaSelected(area:AreaBankModel)
    
}

class AreaTableViewCell: UITableViewCell {

    var areaModel:AreaBankModel?
    
    @IBOutlet var areaCode: UILabel!
    @IBOutlet var roundedProfile: RoundedPicture!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var checkSymbol: UIImageView!
    
    var author:UserBankObject?
    var delegate:AreaTableViewDelegate?
    var classKey:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(model:AreaBankModel) {
        
        classKey = "\(Date().timeIntervalSince1970)"
        
        areaModel = model
        areaModel?.delegates.append(self)
    
        
        author = userBank?.getUserObject(with: (areaModel?.uid)!)
        author?.delegates.append(self)
        
        onDisplayNameChange()
        onAreaUpdate()
        
        
        roundedProfile.setupWith(userID: (areaModel?.uid)!, pictSize: 30)
    }
    
    @IBAction func onAreaSelected(_ sender: Any) {
        
        delegate?.onAreaSelected(area: areaModel!)
        
    }
    

}
