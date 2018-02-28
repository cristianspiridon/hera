//
//  CustomPrintPageRenderer.swift
//  Hera
//
//  Created by Cristian Spiridon on 08/08/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

class CustomPrintPageRenderer: UIPrintPageRenderer {
    
    
    let A4PageWidth: CGFloat = 595.2
    
    let A4PageHeight: CGFloat = 841.8
    
    override init() {
        
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        self.setValue(NSValue(cgRect: pageFrame), forKey: "printableRect")
        
        
        self.headerHeight = 100.0
        self.footerHeight = 50.0
        
    }
    
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        // Specify the header text.
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "dd MMM YYYY | h:mm a"
        
        
        let headerText: NSString = "Date"
        let headerDate: NSString = formatter.string(from: date) as NSString
        let headerTitle:NSString = "Items List"
        
        drawText(textString: headerText, size: 14, offsetX: 60, offsetY: 0, headerRect: headerRect, fontName:   "HelveticaNeue-Bold")
        drawText(textString: headerDate, size: 10, offsetX: 60, offsetY: 15, headerRect: headerRect, fontName:  "HelveticaNeue-Light")
        drawText(textString: headerTitle,size: 20, offsetX: 0,  offsetY: 0, headerRect: headerRect, fontName:   "HelveticaNeue-Medium")
        
    }
    
    
    func drawText(textString:NSString, size:Int, offsetX:CGFloat, offsetY:CGFloat, headerRect:CGRect, fontName:String) {
        
       
        let font = UIFont(name: fontName, size: CGFloat(size))
          let attributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)]
        
        let textSize = getTextSize(text: textString as String, font: font!, textAttributes: attributes as [String : AnyObject]!)
       
        
        let pointX = offsetX != 0 ? headerRect.size.width - textSize.width - offsetX : 35
        let pointY = headerRect.size.height/2 - textSize.height/2 + offsetY
     
        textString.draw(at: CGPoint(x: pointX, y: pointY), withAttributes: attributes)
        
    }
    
    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        let footerText: NSString = "Page \(pageIndex)" as NSString
        
        let font = UIFont(name: "Helvetica Neue", size: 12.0)
        let textSize = getTextSize(text: footerText as String, font: font!)
        
        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        let attributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)]
        
        footerText.draw(at: CGPoint(x: centerX, y: centerY), withAttributes: attributes)
       
    }
    
    func getTextSize(text: String, font: UIFont!, textAttributes: [String: AnyObject]! = nil) -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.paperRect.size.width, height: footerHeight))
        if let attributes = textAttributes {
            testLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        else {
            testLabel.text = text
            testLabel.font = font!
        }
        
        testLabel.sizeToFit()
        
        return testLabel.frame.size
    }

}
