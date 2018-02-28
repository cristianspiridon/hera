//
//  Pdf_ItemsList.swift
//  Hera
//
//  Created by Cristian Spiridon on 08/08/2017.
//  Copyright © 2017 DigitalInsomnia. All rights reserved.
//

import UIKit

class Pdf_ItemsList: NSObject {
    
    let exportNo = "1"
    var itemsList = [ListItem]()
    
    let pathToMainHTMLTemplate = Bundle.main.path(forResource: "items_list", ofType: "html")
    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "item_list", ofType:"html")
    
    var pdfFilename:String!
    var pdfData:NSData!
    
    override init() {
        super.init()
    }
    
    func renderHtml(itemsList:[ListItem])-> String {
    
        self.itemsList = itemsList
        
        do {
            
            var HTMLContent = try String(contentsOfFile: pathToMainHTMLTemplate!)
    
            var allItems = ""

            for i in 0...itemsList.count - 1 {
                
                var itemHTMLContent: String!
                itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DESCRIPTION#", with: itemsList[i].descr)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#EAN#", with: itemsList[i].key!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#QUNATITY#", with: itemsList[i].totalStock())
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PRICE#", with: itemsList[i].price)

                allItems += itemHTMLContent
 
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
           
            
            return HTMLContent
            
        } catch {
            
            print("error reading the html template")
        }
    
        return "no html found"
    
    }
    

    func exportHTMLContentToPDF(HTMLContent: String) {
        
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
    
        pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
       
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
       
        for i in 1...printPageRenderer.numberOfPages {
            
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            printPageRenderer.drawPage(at: i - 1, in: bounds)

        }
        
        
        
        UIGraphicsEndPDFContext()
        
        return data
    }

}
