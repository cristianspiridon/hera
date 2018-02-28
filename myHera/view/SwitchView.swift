//
//  SwitchView.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

@IBDesignable class BigSwitch: UISwitch {
    
    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setup()
        }
    }
    
    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
    
    
}

class SwitchView: XibView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    

}
