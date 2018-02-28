import UIKit
import ColorWithHex


extension UserInputView:UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animateIn(time:0.3, color:blueColor)
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        animateOut(time:0.3)
        
    }
    
}


class UserInputView: XibView {
   
    @IBOutlet var titleValue: UILabel!
    @IBOutlet var userInputLabel: UITextField!
    @IBOutlet var borderLine: UIView!
    
    let blueColor:UIColor = UIColor.colorWithHex("#4285f4")!
    let grayColor:UIColor = UIColor.colorWithHex("#757575")!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.titleValue.layer.anchorPoint = CGPoint(x: 0, y: 0)
        self.titleValue.frame.origin.x = 0
        self.titleValue.frame.origin.y = 24
        
        userInputLabel.text = ""
        titleValue.text = ""
        titleValue.textColor = self.grayColor
        borderLine.backgroundColor = self.grayColor
    }
    
    func setValue(value:String, isBlue:Bool = false) {
        
        userInputLabel.text = value
        
        if value == "" {
            
            animateOut(time: 0.3)
            
        } else {
            animateIn(time:0, color: isBlue == true ? self.blueColor : grayColor )
            
        }
    }

    
    func animateIn(time:Double, color:UIColor) {
        
        UIView.animate(withDuration: time, delay: 0, options: .curveEaseInOut, animations: {
            
            self.titleValue.frame.origin.y = 0
            self.titleValue.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            self.titleValue.textColor = color
            self.borderLine.backgroundColor = color
            
            
        })
        
    }
    
    func animateOut(time:Double) {
        
        UIView.animate(withDuration: time, delay: 0, options: .curveEaseInOut, animations: {
            
            self.titleValue.textColor = self.grayColor
            self.borderLine.backgroundColor = self.grayColor
            
            if self.userInputLabel.text?.count == 0 {
                
                self.titleValue.frame.origin.y = 24
                self.titleValue.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        })
        
    }


   
}
