//
//  MenuCellTableViewCell.swift
//  myHera
//
//  Created by Cristian Spiridon on 18/12/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

class MenuCellTableViewCell: UITableViewCell {
   
    
    @IBOutlet var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
