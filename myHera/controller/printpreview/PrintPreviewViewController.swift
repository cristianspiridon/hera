//
//  PrintPreviewViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 30/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import SVProgressHUD

extension PrintPreviewViewController: NavigationDelegate, NavigationDelegateOptionalExport {

    func onExportPDF() {
        
       showOptionsAlert()
        
    }
    
    func onDismiss() {
        
        self.footPrint?.removeAllObservers()
        
        self.dismiss(animated: true)
        
    }
    
}

extension PrintPreviewViewController :UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (footPrint?.items.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PrintPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProductPreviewCell") as! PrintPreviewTableViewCell
        
        cell.setData(model: (footPrint?.items[indexPath.row])!)
        
        return cell
    }
    
}

extension PrintPreviewViewController:FootPrintDelegate {
    func onFootPrintChildAdded() {
    
        self.tableView.insertRows(at: [IndexPath(row: (footPrint?.items.count)!-1, section: 0)], with: UITableViewRowAnimation.automatic)
        
    }
    
    func onFootPrintDeleted(index: Int) {
        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
    }
    
    
}



class PrintPreviewViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navController: NavigationView!
    
    var footPrint:FootPrint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.labelTitle.text = "Products list"
        
        navController.showExportPDF(sender: self)
        navController.showCloseButton(sender: self)
        
        footPrint = FootPrint(feed: currentSelectedFeed!)
        footPrint?.delegates.append(self)
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func showOptionsAlert() {
        
        let alertController = UIAlertController(title: "Yay!", message: "\nYour export is ready.\nWhat do you want to do now?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionCSV = UIAlertAction(title: "Export Stock Count CSV", style: UIAlertActionStyle.default) { (action) in
         /*   if let filename = self.itemsListComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            } */
            
            self.generateCSV()
        }
        
        let actionEmail = UIAlertAction(title: "Export PDF", style: UIAlertActionStyle.default) { (action) in
           /* DispatchQueue.main.async {
                self.sendEmail()
            } */
        }
        
        let actionPrint = UIAlertAction(title: "Print", style: UIAlertActionStyle.default) { (action) in
            /*
            DispatchQueue.main.async {
                self.printDoc()
            } */
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action) in
            /*
             DispatchQueue.main.async {
             self.printDoc()
             } */
        }
        
        alertController.addAction(actionCSV)
        alertController.addAction(actionEmail)
        alertController.addAction(actionPrint)
        alertController.addAction(actionCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func generateCSV() {
        
        SVProgressHUD.show()
        
        let fileName = "Tasks.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Barcode,Quantity\n"
        
        let ref:DatabaseReference = Database.database().reference()
        
        ref.child("stocktake_footPrint").child((currentSelectedFeed?.locationId)!).child((currentSelectedFeed?.key!)!).child("footPrint").observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                if let dict:[String:Int] = snapshot.value as? [String:Int] {
                    
                    for (barcode, qty) in dict {
                        
                        let newLine = "\(barcode),\(qty)\n"
                        
                        csvText.append(newLine)
                        
                        do {
                            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                            
                            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                            vc.excludedActivityTypes = [
                                UIActivityType.assignToContact,
                                UIActivityType.saveToCameraRoll,
                                UIActivityType.postToFlickr,
                                UIActivityType.postToTencentWeibo,
                                UIActivityType.postToTwitter,
                                UIActivityType.openInIBooks
                            ]
                            
                            self.present(vc, animated: true, completion: nil)
                            
                        } catch {
                            print("Failed to create file")
                            print("\(error)")
                        }
                        
                        SVProgressHUD.dismiss()
                        
                    }
                    
                }
                
            } else {
                
                SVProgressHUD.showError(withStatus: "No data found")
                
            }
            
        }
        
    }
    

}
