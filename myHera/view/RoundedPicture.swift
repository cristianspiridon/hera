//
//  RoundedPicture.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension RoundedPicture:UserBankObjectDelegate {
    func onProfileImageChange() {
        
        
        if userObject?.profileImage != nil {
         
            image.image = userObject?.profileImage
           
        }
        
    }
    
    
    func onDisplayNameChange() {}
    
}

class RoundedPicture: XibView {

    @IBOutlet var backdrop: UIView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var heightConstant: NSLayoutConstraint!
    
    var userObject:UserBankObject?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }

    func setupWith(userID:String, pictSize:CGFloat) {
        
            backdrop.layer.cornerRadius = pictSize / 2
            backdrop.layer.masksToBounds = true
            
            image.layer.cornerRadius = (pictSize - 1) / 2
            image.layer.masksToBounds = true
            
         
            
            userObject = userBank?.getUserObject(with: userID)
            userObject?.delegates.append(self)
            
            if userObject?.exists == true  {
                
                onProfileImageChange()
            }
            
    }
    

}
