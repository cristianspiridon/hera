//
//  AreaViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 11/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import SVProgressHUD


extension AreaViewController:NavigationDelegateMoreOptions {
    
    func onMoreOptions() {
        
        let alertController = UIAlertController(title: "What do you want to do now?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let markArea = UIAlertAction(title: "\(isAreaClosed == true ? "Open Area" : "Close Area")", style: UIAlertActionStyle.default) { (action) in
            
            
            if self.isAreaClosed == true {
                
                currentSelectedArea?.update(status: "in progress")
                self.runTimer()
                
                self.hideEditDetails(isHidden:false)
                
                currentSelectedRegion?.substractAreaDetails(areaModel: currentSelectedArea!)
                currentSelectedFeed?.substractAreaDetails(areaModel: currentSelectedArea!)
                
                
            } else {
                
                currentSelectedArea?.update(status: "completed")
                self.stopTimer()
                
                self.hideEditDetails(isHidden:true)
                currentSelectedRegion?.addAreaDetails(areaModel: currentSelectedArea!)
                currentSelectedFeed?.addAreaDetails(areaModel: currentSelectedArea!)
                
                
                self.stopTimer()
                self.dismiss(animated: true)
                
                SVProgressHUD.showSuccess(withStatus: "Area completed!")
                
            }
            
        }
        
        let actionMulticount = UIAlertAction(title: "Switch to \(multicount == true ? "Singlescan" : "Multicount")", style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
             
                self.setMulticount(isHidden: self.multicount)
                
             }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        let exitArea = UIAlertAction(title: "Exit Area", style: UIAlertActionStyle.default) { (action) in
            
            self.stopTimer()
            self.dismiss(animated: true)
        }
        
      
        alertController.addAction(markArea)
        
        if isAreaClosed == false {
     
            alertController.addAction(actionMulticount)
        }
        
     
        alertController.addAction(exitArea)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
}


extension AreaViewController:ScanLabelDelegate {
    
    func onScan(code: String, sender:ScanLabel) {
        
        if started == false {
            
            started = true
            runTimer()
            
        }
     
        
        if sender == scanBarcode {
      
            
            currentSelectedProduct = productsBank?.getProductBy(sku: "\(code)")
                
            
            if currentSelectedProduct?.title != nil {
            
                
                if multicount == true {
                    
                    scanQuantity.userInputLabel.becomeFirstResponder()
                    scanBarcode.userInputLabel.text = "\(code)"
                    
                } else {
                    
                    print("add single item")
                    barcodesList?.addProductToList(model: currentSelectedProduct!, times:1 )
                    
                    scanBarcode.userInputLabel.text = ""
                    scanBarcode.textFieldDidEndEditing(scanBarcode.userInputLabel)
                    scanBarcode.userInputLabel.text = ""
                    scanBarcode.userInputLabel.becomeFirstResponder()
                    
                }
                
            } else {
                
                self.performSegue(withIdentifier: "addNewProduct", sender: self)
                
            }
            
        } else {
            
            
            print("Add product onScan quantity")
            
                if let qty = Int(code) {
                    
                    if qty > 99 {
                        
                        SVProgressHUD.showError(withStatus: "Your maximum quantity limit is set to 99.")
                        
                    } else {
                        
                        
                        currentProductQuantity = qty
                        
                        barcodesList?.addProductToList(model: currentSelectedProduct!, times: currentProductQuantity)
                        
                        scanQuantity.userInputLabel.text = ""
                        scanQuantity.textFieldDidEndEditing(scanQuantity.userInputLabel)
                        
                        scanBarcode.userInputLabel.text = ""
                        scanBarcode.textFieldDidEndEditing(scanBarcode.userInputLabel)
                        scanBarcode.userInputLabel.becomeFirstResponder()
                        
                    }
                    
                } else {
                    
                    
                    SVProgressHUD.showError(withStatus: "Your maximum quantity limit is set to 99.")
                }
        }
        
    }
}

extension AreaViewController:AddNewProductViewControllerDelegate {
    
    // After we added with success the new product we focus either to the scan Barcode label either to quantity
    
    func onProductUpdated() {
        
        if multicount == false {
            
            barcodesList?.addProductToList(model: currentSelectedProduct!, times:1)

            scanBarcode.userInputLabel.text = ""
            scanBarcode.textFieldDidEndEditing(scanBarcode.userInputLabel)
            scanBarcode.userInputLabel.becomeFirstResponder()
            
        } else {
            
            scanQuantity.userInputLabel.becomeFirstResponder()
            
        }
    }
}

extension AreaViewController:ProductListManagerDelegate {
    
    func onProductChildDeleted(index: Int) {
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
        updateScrollHeight()
        totalQ = 0
        tableView.reloadData()
        
        
    }
    
    
    func onProductChildAdded() {
        
        self.tableView.insertRows(at: [IndexPath(row: /*(barcodesList?.barcodes.count)!-1*/ 0, section: 0)], with: UITableViewRowAnimation.automatic)
        
        updateScrollHeight()
        
    }
    
    
}

extension AreaViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return barcodesList!.barcodes.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ProductViewCellTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "productCell") as! ProductViewCellTableViewCell
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
       (cell as! ProductViewCellTableViewCell).setData(model: (barcodesList?.barcodes[indexPath.row])!, index: (barcodesList?.barcodes.count)! - indexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return !isAreaClosed
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            print("Deleted")
            barcodesList?.deleteProduct(at: indexPath.row)
        }
        
    }
    
}


var currentSelectedProduct:ProductBankModel?
var totalQ:Double = 0




class AreaViewController: HeraViewController {

    @IBOutlet var navController: NavigationView!
    @IBOutlet var stats: StocktakeStats!
    @IBOutlet var scanBarcode: ScanLabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var scrollContentHeight: NSLayoutConstraint!
    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet var tableTop: NSLayoutConstraint!
    @IBOutlet var scanQuantity: ScanLabel!
    
    @IBOutlet var scanWidth: NSLayoutConstraint!
    
    
    var classKey:String?
    var barcodesList:ProductListManager?
    var multicount:Bool = false
    var seconds:Int = 0
    var timer:Timer?
    var currentProductQuantity:Int = 1
    var started:Bool = false
    var isAreaClosed:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableHeight.constant = 0

        navController.labelTitle.text = "Area \((currentSelectedArea?.key!)!)"
        navController.setSubtitle(value: "\((currentSelectedRegion?.title)!)")
        
        navController.showMoreOptions(sender: self)
        navController.showProfilePictureFor(userID: (currentSelectedArea?.uid)!)
  
        setupSwitchArea()
        
        stats.setArea(area: currentSelectedArea!)
        
        scanBarcode.setDefault(value: "SCAN BARCODE")
        scanBarcode.delegate = self
        scanBarcode.keyboardAction = "ENTER BARCODE"
        scanBarcode.addDoneButtonOnKeyboard()
        
        scanQuantity.setDefault(value: "QUANTITY")
        scanQuantity.delegate = self
        scanQuantity.keyboardAction = "ADD QUANTITY"
        scanQuantity.addDoneButtonOnKeyboard()
        
        scanQuantity.isUserInteractionEnabled = false
        
        setScrollTap(scrollView: scrollView)
        
        barcodesList = ProductListManager(key: (currentSelectedArea?.key)!)
        barcodesList?.delegate = self
        
        classKey = "\(Date().timeIntervalSince1970)"
        seconds = (currentSelectedArea?.duration)!
        started = false
        
        setMulticount(isHidden:true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        stopTimer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        runTimer()
        
    }
    
    func hideEditDetails(isHidden:Bool) {
        
        self.view.endEditing(true)
        
        isAreaClosed = isHidden
        
        scanBarcode.isHidden = isHidden
        
        if multicount {
            
            scanQuantity.isHidden = isHidden
            
        }
        
        if isHidden == true {
            
            tableTop.constant = -50
            
            } else {
            
            tableTop.constant = 20
            navController.setRecordingState()
            
        }
        
    }
    
    func runTimer() {
        
        if started == true {

            if timer != nil {
                
                timer?.invalidate()
                timer = nil
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)

        }
        
    }
    
    func stopTimer() {
 
        if timer != nil {
         
            timer?.invalidate()
            
        }
    }
    
    @objc func updateTimer() {
        
        seconds += 1
        currentSelectedArea?.update(duration: seconds)
        
        print("on timer \(seconds)")
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        return "\(seconds / 3600) : \((seconds % 3600) / 60) : \((seconds % 3600) % 60))"
    }
    
    func updateValues() {
        
    }
    
    func setupSwitchArea() {
        
        if currentSelectedArea?.progress == "completed" {
            
            hideEditDetails(isHidden: true)
            
        } else {
            
            navController.setRecordingState()
        }
        
     }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addNewProduct" {
            
            let vc:AddNewProductViewController = segue.destination as! AddNewProductViewController
            vc.delegate = self
            
        }
        
    }
    
    func updateScrollHeight() {
     
        let tableH = (barcodesList?.barcodes.count)! * 60
        
        tableHeight.constant = CGFloat(tableH)
        scrollContentHeight.constant = max((tableView.frame.origin.y + tableHeight.constant - self.view.frame.height), 0)
        
        updateValues()
        
    }
    
    func setMulticount(isHidden:Bool) {
        
        scanQuantity.isHidden = isHidden
        
        if isHidden {
            
            scanWidth.constant = 0
            
        } else {
            
            scanWidth.constant = 120
            
        }
        
        multicount = !isHidden
        
    }
    

}
