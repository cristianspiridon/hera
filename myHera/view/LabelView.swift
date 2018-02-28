//
//  LabelView.swift
//  myHera
//
//  Created by Cristian Spiridon on 08/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

class LabelView: XibView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var label: UILabel!
    

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    func setAlignement(to:NSTextAlignment) {
        
        titleLabel.textAlignment = to
        label.textAlignment = to
        
    }
    
    
}
