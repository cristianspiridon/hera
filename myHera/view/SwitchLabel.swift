//
//  SwitchLabel.swift
//  myHera
//
//  Created by Cristian Spiridon on 12/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

protocol SwitchLabelDelegate {
    
    func onSwitchLabelChange(isOn:Bool, sender:SwitchLabel)
    
}

class SwitchLabel: XibView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var theSwitch: UISwitch!
    
    var titleOn:String?
    var titleOff:String?
    
    var delegate:SwitchLabelDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        theSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
    }
    
    func setupWith(titleON:String, titleOFF:String) {
        
        self.titleOn = titleON
        self.titleOff = titleOFF
        
        onSwitch(self)
        
    }
    
    func setDefaultSwitch(isOn:Bool) {
        
        theSwitch.setOn(isOn, animated: false)
        setTitle(isOn: isOn)
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        

        setTitle(isOn: theSwitch.isOn)
        
        if delegate != nil {
            
            delegate?.onSwitchLabelChange(isOn: theSwitch.isOn, sender:self)
            
        }
        
    }
    
    func setTitle(isOn:Bool) {
        
        if isOn == true {
            
            titleLabel.text = titleOn
        } else {
            titleLabel.text = titleOff
        }
        
        
    }

    @IBAction func onAction(_ sender: Any) {
        
        
        
        if theSwitch.isOn == true {
        
            
            theSwitch.setOn(false, animated: true)
            
            
        } else {
            
            
            theSwitch.setOn(true, animated: true)
            
        }
        
        onSwitch(self)
        
    }
    
    
}
