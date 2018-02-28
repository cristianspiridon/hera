//
//  StocktakeStats.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension StocktakeStats:FeedBankModelDelegate {
    func onUpdate() {
        
        stockValue.label.text = convertToCurrency(value: (feedModel?.totalValue)!)
        totalQuantity.label.text = "\(convertToNumber(value: (feedModel?.quantity)!))"
        time.label.text = converToHHMMSS(seconds: (feedModel?.duration)!)
        progress.label.text = prepareProgress(value: Double((feedModel?.progress)!))
        
    }
    
    func onLocationImageReady(image: UIImage) {
        
    }
    
}

extension StocktakeStats:RegionBankModelDelegate {
    
    func onRegionUpdate() {
    
        stockValue.label.text = convertToCurrency(value: (regionModel?.totalValue)!)
        totalQuantity.label.text = "\(convertToNumber(value: (regionModel?.quantity)!))"
        time.label.text = converToHHMMSS(seconds: (regionModel?.duration)!)
        progress.label.text = prepareProgress(value: (regionModel?.progress)!)
    }
    
}

extension StocktakeStats:AreaBankModelDelegate {
    func getClassKey() -> String {
        
        return classKey!
    }
    
    
    func onAreaUpdate(){
        
        stockValue.label.text = convertToCurrency(value: (areaModel?.totalValue)!)
        totalQuantity.label.text = "\(convertToNumber(value: (areaModel?.quantity)!))"
       
        
        let duration:Int = (areaModel?.duration)!
        let quantity:Int = (areaModel?.quantity)!
      
        
        if duration != 0 && quantity != 0 {
        
            time.label.text = converToHHMMSS(seconds: duration)
            
            let perUnitTime:Float = (3600 / Float(duration))
            let bph = Int(perUnitTime * Float(quantity))
            
            progress.label.text = "\(convertToNumber(value: bph))BPH"
            
        }
        
    }
    
}

class StocktakeStats: XibView {

    @IBOutlet var stockValue: LabelView!
    @IBOutlet var time: LabelView!
    @IBOutlet var totalQuantity: LabelView!
    @IBOutlet var progress: LabelView!
    
    var classKey:String?
    var feedModel:FeedBankModel?
    var regionModel:RegionBankModel?
    var areaModel:AreaBankModel?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        stockValue.titleLabel.text    = "STOCK VALUE"
        time.titleLabel.text     = "DURATION"
        totalQuantity.titleLabel.text = "TOTAL QUANTITY"
        progress.titleLabel.text      = "PROGRESS"
        
        stockValue.label.text = "£0.00"
        totalQuantity.label.text = "0"
        time.label.text = "00:00:00"
        progress.label.text = "0%"
        
        totalQuantity.setAlignement(to: NSTextAlignment.right)
        progress.setAlignement(to: NSTextAlignment.right)
        
        classKey = "\(Date().timeIntervalSince1970)"
        
    }
    
    func setFeed(feed:FeedBankModel){
        
        feedModel = feed
        feedModel?.delegates.append(self)
        
        onUpdate()
    }
    
    func setRegion(feed:RegionBankModel){
        
        regionModel = feed
        regionModel?.delegates.append(self)
        
        onRegionUpdate()
    }
    
    func setArea(area:AreaBankModel) {
        
        areaModel = area
        areaModel?.delegates.append(self)
        
        progress.titleLabel.text      = "SPEED"
        progress.label.text = "BPH"
        onAreaUpdate()
    }
    
    func convertToCurrency(value:Double) -> String {
        
 
        let cForm = NumberFormatter()
        cForm.usesGroupingSeparator = true
        cForm.numberStyle = .currency
        
        let priceString = cForm.string(from: NSNumber(value: value))
        
        
        return priceString!
        
    }
    
    func convertToNumber(value:Int) -> String {
        
        let cForm = NumberFormatter()
        cForm.usesGroupingSeparator = true
        cForm.numberStyle = .decimal
        
        let priceString = cForm.string(from: NSNumber(value: value))
        
        
        return priceString!
        
    }
    
    func converToHHMMSS (seconds : Int) -> String {
        
        let HH = doubleDigit(digit: seconds / 3600)
        let mm = doubleDigit(digit: (seconds % 3600) / 60)
        let ss = doubleDigit(digit: (seconds % 3600) % 60)
        
        return "\(HH):\(mm):\(ss)"
    }
    
    func prepareProgress(value:Double) -> String {
        
        return "\(Int(value * 100))%"
        
    }
    
    func doubleDigit(digit:Int) -> String {
        
        if digit < 10 {
            
            return "0\(digit)"
            
        } else {
            return "\(digit)"
        }
        
    }

}
