//
//  BussinessLocationTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 19/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

protocol BusinessLocationCellDelegate {
    
    func onSelect(locationModel:LocationBankModel)
    
}


extension BussinessLocationTableViewCell:LocationBankModelDelegate {
    func onEventCreatedWithSucces() {
        
    }
    
    
    func onLocationDataReady() {
        
        labelTitle.text = location.name
        labelLocation.text = location.postcode
        
        
    }
    
    func onImageReady() {
        imgView.image = location.image
    }
    
}

class BussinessLocationTableViewCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelLocation: UILabel!
    
    var location:LocationBankModel!
    var delegate:BusinessLocationCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func onDidSelect(_ sender: Any) {
        
        if delegate != nil {
            
            delegate?.onSelect(locationModel: location)
            
        }
        
    }
    
    func setData(locationData:LocationBankModel) {
        
        location = locationData
        location.delegates.append(self)
        
        if location.exists {
            onLocationDataReady()
        }
        
        if location.image != nil {
            imgView.image = location.image
        }
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
