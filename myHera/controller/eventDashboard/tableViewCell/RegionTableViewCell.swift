//
//  RegionTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension RegionTableViewCell:RegionBankModelDelegate {
    
    func onRegionUpdate() {
        
        regionTitle.text = reg?.title!
        areaRanges.text = "Area ranges between \((reg?.rangeIn!)!) and \((reg?.rangeOut!)!)"
        progress.text = prepareProgress(value: (reg?.progress)!)
    }
    
}

protocol RegionTableCellDelegate {
    
    func onSelect(model:RegionBankModel)
    
}

class RegionTableViewCell: UITableViewCell {
    
    @IBOutlet var regionTitle: UILabel!
    @IBOutlet var areaRanges: UILabel!
    @IBOutlet var progress: UILabel!
    
    var reg:RegionBankModel?
    
    var delegate:RegionTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareProgress(value:Double) -> String {
        
        return "\(Int(value * 100))%"
        
    }
    
    
    @IBAction func onSelect(_ sender: Any) {
        
        if delegate != nil {
            
            delegate?.onSelect(model:reg!)
            
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(region:RegionBankModel) {
        
        self.reg = region
        self.reg?.delegates.append(self)
        
        onRegionUpdate  ()
        
    }

}
