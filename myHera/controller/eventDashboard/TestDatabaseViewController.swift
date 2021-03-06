//
//  TestDatabaseViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 13/02/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

extension TestDatabaseViewController: NavigationDelegate {
    
    func onDismiss() {
        
        self.dismiss(animated: true)
        
    }
    
}


class TestDatabaseViewController: UIViewController {
    
    @IBOutlet var navController: NavigationView!
    
    @IBOutlet var textView: UITextView!
    
    var currentTestID:Int = -1
    
    var areaFootPrint:[String:[String:[String:[String:Any]]]]?
    var areaContents :[String:[String:[String:[String:Any]]]]?
    var areaStats :[String:[String:[String:Any]]]?
    var regionStats :[String:[String:Any]]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.labelTitle.text = "Database Validation"
        
        // navController.showExportPDF(sender: self)
        navController.showCloseButton(sender: self)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTestStart(_ sender: Any) {
        
        nextTest()
        
    }
    
    
    func nextTest() {
        
        
        currentTestID += 1
        
        print("Next test \(currentTestID)  ")
        
        dispatchMessage(msg: "Running Next Test ID: \(currentTestID)")
        
        switch currentTestID {
            
        case 0: loadAreaFootPrint(); break
        case 1: loadAreaContents(); break
        case 2: loadAreaDetailsAndCheckForErrors(); break
        case 3: loadRegionStats();  break
        case 4: loadStocktakeStats(); break
        case 5:
            
            dispatchMessage(msg: "Validation complete!")
            SVProgressHUD.showSuccess(withStatus: "Test complete! Some background updates may still run.")
            
        default:
            print("No more test")
        }
        
        
    }
    
    func loadStocktakeStats() {
        
        self.dispatchMessage(msg: "Start Stocktake Level Test")
        
        var stockValue:Double = 0
        var stockTakeDuration:Int = 0
        var completedAreas = 0
        var totalAreas = 0
        var stockQuantity = 0
        
        
        for region in (currentRList?.regions)! {
            
            stockQuantity     += region.quantity!
            stockValue        += region.totalValue!
            stockTakeDuration += region.duration!
            completedAreas    += region.completedAreas!
            totalAreas        += region.numberOfAreas()
            
        }
        
        var isPassingTest = true
        
        self.dispatchMessage(msg: "Stcktake Expected vs Found")
        
        self.dispatchMessage(msg: "stockQuantity \(stockQuantity) \((currentSelectedFeed?.quantity)!)")
        self.dispatchMessage(msg: "stockValue \(stockValue) \((currentSelectedFeed?.totalValue)!)")
        self.dispatchMessage(msg: "stockTakeDuration \(stockTakeDuration) \((currentSelectedFeed?.duration)!)")
        self.dispatchMessage(msg: "completedAreas \(completedAreas) \((currentSelectedFeed?.completedAreas)!)")
        self.dispatchMessage(msg: "totalAreas \(totalAreas) \((currentSelectedFeed?.totalAreas)!)")
        
        
        isPassingTest = isPassingTest && stockTakeDuration == currentSelectedFeed?.duration
        isPassingTest = isPassingTest && stockValue == currentSelectedFeed?.totalValue
        isPassingTest = isPassingTest && stockQuantity == currentSelectedFeed?.quantity
        isPassingTest = isPassingTest && completedAreas == currentSelectedFeed?.completedAreas
        isPassingTest = isPassingTest && totalAreas == currentSelectedFeed?.totalAreas
        
        let tempPerc:Double = Double(completedAreas) / Double(totalAreas)
        
        isPassingTest = isPassingTest && tempPerc == currentSelectedFeed?.progress
        
        let testStr = isPassingTest == true ? "passed" : "failed"
        
        self.dispatchMessage(msg: "Stocktake level test \(testStr)")
        
        if isPassingTest == false {
            
            // create FootPrintFromAllAreas
            
            var newFootPrint:[String:Any]  = [String:Any]()
            
            for (region, value) in areaFootPrint! {
                
                print("Foot print \(region)")
                
                if  let areaList = value as? [String:[String:Any]] {
                    
                    for (key, value) in areaList {
                        
                        if let tempFootPrint = value["footPrint"] as? [String:Any] {
                            
                            print(tempFootPrint)
                            
                            for (sku, qty) in tempFootPrint {
                                
                                let newQty:Int = qty as! Int
                                
                                if let tempQty = newFootPrint[sku] as? Int {
                                    
                                    newFootPrint[sku] = tempQty + newQty
                                    
                                } else {
                                    
                                    newFootPrint[sku] = newQty
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            let stocktakeFootPrint = Database.database().reference().child("stocktake_footPrint").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("footPrint").setValue(newFootPrint, withCompletionBlock: { (error, ref) in
                
                if error != nil {
                    
                    self.self.dispatchMessage(msg: "Stocktake footPrint update error")
                    
                } else {
                    
                    self.dispatchMessage(msg: "Stocktake FootPrint Updated with success")
                }
                
            })
            
            let stockQtyRef:DatabaseReference = Database.database().reference().child("stocktakes").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("quantity")
            stockQtyRef.setValue(stockQuantity)
            
            let stockValueRef:DatabaseReference = Database.database().reference().child("stocktakes").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("stock-value")
            stockValueRef.setValue(stockValue)
            
            let stockADuration:DatabaseReference =  Database.database().reference().child("stocktakes").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("duration")
            stockADuration.setValue(stockTakeDuration)
            
            let stockAreaCompleted:DatabaseReference =  Database.database().reference().child("stocktakes").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("completed-areas")
            stockAreaCompleted.setValue(completedAreas)
            
            let stockTotalAreasRef:DatabaseReference =  Database.database().reference().child("stocktakes").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("total-areas")
            stockTotalAreasRef.setValue(totalAreas)
            
            let regionTotalProgress:DatabaseReference =  Database.database().reference().child("stocktakes").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("progress")
            regionTotalProgress.setValue(tempPerc)
            
            dispatchMessage(msg: "Stocktake stats updated")
            
        }
        
        
        nextTest()
    }
    
    func loadRegionStats() {
        
        let regionStatsRef = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!)
        
        regionStatsRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                if let temp:[String:[String:Any]]  = snapshot.value as? [String:[String:Any]] {
                    
                    self.regionStats = temp
                    
                    self.dispatchMessage(msg: "Region stats loaded with success")
                    
                    // check if totalAreas are correct for region stats
                    
                    for (region, regionValues) in self.regionStats! {
                        
                        let numOFCompleted:Int = regionValues["completed-areas"] as! Int
                        let duration:Int       = regionValues["duration"] as! Int
                        let quantity:Int       = regionValues["quantity"] as! Int
                        let progress:Double       = regionValues["progress"] as! Double
                        let sValue:Double         = regionValues["stock-value"] as! Double
                        
                        let totalAreas:Double = (regionValues["range-out"] as! Double) - (regionValues["range-in"] as! Double)
                        
                        var Temp_numOFCompleted:Int = 0
                        var Temp_duration:Int       = 0
                        var Temp_quantity:Int       = 0
                        let Temp_progress:Int       = 0
                        var Temp_sValue:Double      = 0
                        
                        var newFootPrint:[String:Any] = [String:Any]()
                        
                        
                        for (area, value) in self.areaStats![region]! {
                            
                            print("\(area) \(value)")
                            
                            if (value["progress"] as! String) == "completed" {
                                
                                Temp_numOFCompleted += 1
                                Temp_duration += value["duration"] as! Int
                                Temp_quantity += value["quantity"] as! Int
                                Temp_sValue   += value["stock-value"] as! Double
                            }
                            
                            if self.areaFootPrint![region]![area] != nil {
                                
                                if let footPrint:[String:Any] = (self.areaFootPrint![region]![area]!["footPrint"])! {
                                    
                                    for (sku, qty) in footPrint {
                                        
                                        let newQty:Int = qty as! Int
                                        
                                        if let tempQty = newFootPrint[sku] as? Int {
                                            
                                            newFootPrint[sku] = tempQty + newQty
                                            
                                        } else {
                                            
                                            newFootPrint[sku] = newQty
                                        }
                                    }
                                }
                                
                            }
                            
                            
                        }
                        
                        var errorChecks:Bool = true
                        
                        if numOFCompleted != Temp_numOFCompleted {
                            
                            errorChecks = false
                            self.dispatchMessage(msg: "Region \(region) num of completed error \(Temp_numOFCompleted) expected \(numOFCompleted)")
                            
                        }
                        
                        if quantity != Temp_quantity {
                            
                            errorChecks = false
                            self.dispatchMessage(msg: "Region \(region) num of qunatity error \(Temp_quantity) expected \(quantity)")
                            
                        }
                        
                        if sValue != Temp_sValue {
                            
                            errorChecks = false
                            self.dispatchMessage(msg: "Region \(region) num of svalue error \(Temp_sValue) expected \(sValue)")
                            
                        }
                        
                        if errorChecks == false {
                            
                            self.dispatchMessage(msg: "Region \(region) error, update in progress")
                            
                            
                            let regionFootPrintRef = Database.database().reference().child("regions_footPrint").child((currentSelectedFeed?.key)!).child(region).child("footPrint").setValue(newFootPrint, withCompletionBlock: { (error, ref) in
                                
                                if error != nil {
                                    
                                    self.self.dispatchMessage(msg: "Region \(region) footPrint update error")
                                    
                                } else {
                                    
                                    self.dispatchMessage(msg: "Region \(region) FootPrint Updated with success")
                                }
                                
                            })
                            
                            let regionTotalQ:DatabaseReference = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!).child(region).child("quantity")
                            regionTotalQ.setValue(Temp_quantity)
                            
                            let regionTotalV:DatabaseReference = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!).child(region).child("stock-value")
                            regionTotalV.setValue(Temp_sValue)
                            
                            let regionTotalAreaCompleted:DatabaseReference = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!).child(region).child("completed-areas")
                            regionTotalAreaCompleted.setValue(Temp_numOFCompleted)
                            
                            let regionProgress:DatabaseReference = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!).child(region).child("completed-areas")
                            regionProgress.setValue(Temp_numOFCompleted)
                            
                            let newProgress = Double(Temp_numOFCompleted) / totalAreas
                            
                            
                            let regionTotalProgress:DatabaseReference = Database.database().reference().child("regions").child((currentSelectedFeed?.key)!).child(region).child("progress")
                            regionTotalProgress.setValue(newProgress)
                            
                            self.regionStats![region]!["quantity"] = Temp_quantity
                            self.regionStats![region]!["stock-value"] = Temp_sValue
                            self.regionStats![region]!["progress"] = newProgress
                            self.regionStats![region]!["completed-areas"] = Temp_numOFCompleted
                            
                            
                        }
                    }
                    
                    self.dispatchMessage(msg: "Region level validation complete!")
                    self.nextTest()
                }
                
            }
            
        }
        
    }
    
    
    
    func loadAreaFootPrint() {
        
        dispatchMessage(msg: "Download Area Foot Print")
        
        let areaFootPrintRef = Database.database().reference().child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("areas_footPrint")
        
        areaFootPrintRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                if let temp:[String:[String:[String:[String:Int]]]]  = snapshot.value as? [String:[String:[String:[String:Int]]]] {
                    
                    self.areaFootPrint = temp
                    
                    self.dispatchMessage(msg: "Area foot print loaded with success")
                    self.nextTest()
                    
                }
                
            } else {
                
                self.dispatchMessage(msg: "No foot print found for area")
                
            }
            
        }
        
    }
    
    func loadAreaContents() {
        
        dispatchMessage(msg: "Download Area Contents")
        
        let areaContetsPrintRef = Database.database().reference().child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("area_contents")
        
        areaContetsPrintRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                if let temp:[String:[String:[String:[String:Any]]]]  = snapshot.value as? [String:[String:[String:[String:Any]]]] {
                    
                    self.areaContents = temp
                    
                    self.dispatchMessage(msg: "Area contents loaded with success")
                    self.nextTest()
                    
                    
                }
                
            }
            
        }
        
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
    
    func loadAreaDetailsAndCheckForErrors() {
        
        dispatchMessage(msg: "Download Area List Status")
        
        
        let areaRef = Database.database().reference().child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!).child("areas")
        
        areaRef.observeSingleEvent(of: .value) { (snapshot) in
            
            self.dispatchMessage(msg: "Area list has loaded with success")
            
            if snapshot.exists() {
                
                if let temp = snapshot.value as? [String:[String:[String:Any]]] {
                    
                    self.areaStats = temp
                    
                }
                
                if let regionList:[String:Any] = snapshot.value as? [String:Any] {
                    
                    for var (region, value) in regionList {
                        
                        if let areaList:[String:Any] = value as! [String:Any] {
                            
                            self.dispatchMessage(msg: "Found \(areaList.count) areas")
                            
                            for (area, value) in areaList {
                                
                                
                                if let areaStats:[String:Any] = value as? [String:Any] {
                                    
                                    let quantity     = areaStats["quantity"] as! Int
                                    let sValue         = areaStats["stock-value"] as? Double ?? 0
                                    
                                    
                                    let testFootPrint = self.getFootPrintTestFor(area: area, region: region, expectedQ:quantity, expectedV: sValue )
                                    
                                    let tempStr = testFootPrint == true ? "has passed the test" : "has failed the test"
                                    
                                    self.dispatchMessage(msg: "\(area) \(tempStr)")
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    self.nextTest()
                    
                }
                
                
            } else {
                
                self.dispatchMessage(msg: "ERROR: Area List Snapshot doesn't exist! ")
                
            }
            
        }
        
    }
    
    func getFootPrintTestFor(area:String, region:String, expectedQ:Int, expectedV:Double) -> Bool {
        
        var footPrintError:Bool = true
        var totalQ:Int = 0
        var totalV:Double = 0
        
        if areaFootPrint![region] != nil {
            
            if areaFootPrint![region]![area] != nil {
                
                if let footPrint:[String:Any] = (areaFootPrint![region]![area]!["footPrint"])! {
                    
                    footPrintError = false
                    
                    for (barcode, quantity) in footPrint {
                        
                        let tempModel = productsBank?.getProductBy(sku: barcode)
                        
                        if let price = tempModel?.price {
                            
                            totalQ = totalQ + Int(quantity as! Int)
                            totalV = totalV + Double(quantity as! Int) * (tempModel?.price)!
                            
                        } else {
                            
                            print("Error getting price for \(barcode)")
                            dispatchMessage(msg: "Error getting price for sku \(barcode)")
                            
                        }
                    }
                }
            }
        }
        
        
        if footPrintError {
            
            dispatchMessage(msg: "FootPrint not found for area \(area)")
            
        } else {
            
            footPrintError = (totalQ == expectedQ) && (abs(expectedV - totalV) < 0.1)
            
            if footPrintError == false {
                
                dispatchMessage(msg: "\(area) test Failed \(footPrintError) Foot Print, Expected totalQ:\(totalQ) vs \(expectedQ) and totalV:\(totalV) vs \(expectedV)")
                
                self.refactorArea(area:area, region:region)
                
            }
            
        }
        
        return footPrintError
        
    }
    
    func refactorArea(area:String, region:String) {
        
        dispatchMessage(msg: "Refactor area \(area)")
        
        var totalValue:Double = 0
        var totalQty   = 0
        
        
        
        if  let areaConents:[String:[String:Any]] = areaContents![region]![area] as! [String:[String:Any]] {
            
            var newFootPrint:[String:Int] = [String:Int]()
            
            for (key, value) in areaConents {
                
                let sku = value["sku"] as! String
                let qty = value["qty"] as! Int
                
                print("\(sku) \(qty)")
                
                if let newQty = newFootPrint[sku] {
                    
                    newFootPrint[sku] = newQty + qty
                } else {
                    
                    newFootPrint[sku] = qty
                }
                
                let model = productsBank?.getProductBy(sku: sku)
                
                if model?.price != nil {
                    
                    totalValue = totalValue + (model?.price)! * Double(qty)
                    
                } else {
                    dispatchMessage(msg: "Error Getting price for \(sku)")
                }
                
                totalQty = totalQty + qty
                
            }
            
            dispatchMessage(msg: "New area \(area) stats totalV: \(totalValue) totalQ:\(totalQty)")
            
            // Update Area details
            
            areaFootPrint![region]![area]!["footPrint"] = newFootPrint
            
            let rootRef = Database.database().reference().child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key)!)
            
            let areaFootPrintRef = rootRef.child("areas_footPrint").child(region).child(area).child("footPrint")
            areaFootPrintRef.setValue(newFootPrint)
            
            let areaTotalQ:DatabaseReference = rootRef.child("areas").child(region).child(area).child("quantity")
            areaTotalQ.setValue(totalQty)
            
            let areaTotalV:DatabaseReference = rootRef.child("areas").child(region).child(area).child("stock-value")
            areaTotalV.setValue(totalValue)
            
            let areaStatus:DatabaseReference = rootRef.child("areas").child(region).child(area).child("progress")
            areaStatus.setValue("completed")
            
            
            areaStats![region]![area]!["quantity"] = totalQty
            areaStats![region]![area]!["stock-value"] = totalValue
            areaStats![region]![area]!["progress"] = "completed"
            
            
        } else {
            
            dispatchMessage(msg: "Could not refactor area:\(area)")
        }
        
        
        
        
    }
    
    func dispatchMessage(msg:String) {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        
        textView.text = textView.text + "[\(hour):\(minutes):\(seconds)]: \(msg)\n"
    }
    
}

