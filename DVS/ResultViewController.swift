/**
 * Copyright (c) 2018 Qualcomm Technologies, Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import SpreadsheetView
import SwiftyJSON

class ResultViewController: UIViewController, SpreadsheetViewDataSource {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var state: State?
    var json: JSON!
    var resultStatus = [String: [String]]()
    var rowToMerge = 0
    var resultRowsToMerge: [Int] = []
    
    var labels = [
        "IMEI",
        "IMEI Compliance Status",
        "Brand",
        "Model Name",
        "Model Number",
        "Manufacturer",
        "Device Type",
        "Operating System",
        "Radio Access Technology",
        "Registration Status",
        "Lost/Stolen Status",
        "Block as of Date"
    ]
    var labelValues = [
        "123456789012345",
        "Samsung",
        "Galaxy",
        "S6",
        "Samsung China",
        "Smart Phone",
        "Android",
        "GSMA CDMA",
        "Compliance (Active)",
        "N/A",
        "N/A",
        "N/A"
    ]
    
    
    
    var slotInfo = [IndexPath: (Int, Int)]()
    
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        //        let vc = ViewController()
        
        populateData()
        
        spreadsheetView.dataSource = self
        //        spreadsheetView.delegate = self s! SpreadsheetViewDelegate
        
        spreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
        spreadsheetView.register(ValueCell.self, forCellWithReuseIdentifier: String(describing: ValueCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: SlotCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SlotCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        
        spreadsheetView.backgroundColor = .white
        
        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)
        spreadsheetView.circularScrolling = CircularScrolling.Configuration.none
        
    }
    @IBAction func cancelBtnLIstener(_ sender: Any) {
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return labelValues.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let width = (((UIScreen.main.bounds.width-32)/2)-4)
        return width
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        var height:CGFloat = 40

        if labelValues[row].count > 40{
            height = CGFloat(Double(labelValues[row].count) * 1.5)
        }
        return height
    }   
  
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        print(indexPath.row)
        
        if indexPath.column == 0 {
            
            if labels[indexPath.row] == "N/A" && labelValues[indexPath.row] == "" {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
                
                cell.label.text = labels[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.right = cell.gridlines.left
                return cell
            }
            else{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
                cell.label.text = labels[indexPath.row]
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1, color: .black)
                return cell
            }
            
        }
        if indexPath.column == 1 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
            
            cell.label.text = labelValues[indexPath.row]
            
            cell.gridlines.top = .solid(width: 1, color: .black)
            cell.gridlines.bottom = .solid(width: 1, color: .black)
            cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
            cell.gridlines.right = cell.gridlines.left
           
            return cell
        }
      
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
    }
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }   
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.done()
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
           print("load more ")
            spreadsheetView.reloadData()
        }
    }
    func populateData(){
        
        if(self.json != nil)
        {
        print("JSON: \(json)")
            
        
            
        // imei from resuult
        if let imeiNumber = json["imei"].string {
            // imei found in the result
            self.labelValues[0] = imeiNumber
        } else {
            // imei not founc in the result
            self.labelValues[0] = "N/A"
        }
            
        // status from result
        if let status = json["compliant"]["status"].string {
            // model_name found in the result
            self.labelValues[1] = status
        } else {
            // model_name not founc in the result
            self.labelValues[1] = "N/A"
        }
        
        // brand from result
        
        if let brand = json["gsma"]["brand"].string {
            // brand found in the result
            self.labelValues[2] = brand
        } else {
            // brand not founc in the result
            self.labelValues[2] = "N/A"
        }
        
        // model_name from result
        if let model = json["gsma"]["model_name"].string {
            // model_name found in the result
            self.labelValues[3] = model
        } else {
            // model_name not founc in the result
            self.labelValues[3] = "N/A"
        }
        
        // model_number from result
        if let modelNumber = json["gsma"]["model_number"].string {
            // model_number found in the result
            self.labelValues[4] = modelNumber
        } else {
            // model_number not founc in the result
            self.labelValues[4] = "N/A"
        }
        
        // manufacturer from result
        if let manufacturer = json["gsma"]["manufacturer"].string {
            // manufacturer found in the result
            self.labelValues[5] = manufacturer
        } else {
            // manufacturer not founc in the result
            self.labelValues[5] = "N/A"
        }
        
        // device_type from result
        if let deviceType = json["gsma"]["device_type"].string {
            // device_type found in the result
            self.labelValues[6] = deviceType
        } else {
            // device_type not founc in the result
            self.labelValues[6] = "N/A"
        }
        
        // operating_system from result
        if let operatingSystem = json["gsma"]["operating_system"].string {
            // operating_system found in the result
            self.labelValues[7] = operatingSystem
        } else {
            // operating_system not founc in the result
            self.labelValues[7] = "N/A"
        }
        
        // radio_access_technology from result
        if let radioAccessTechnology = json["gsma"]["radio_access_technology"].string {
            // radio_access_technology found in the result
            self.labelValues[8] = radioAccessTechnology
        } else {
            // radio_access_technology not founc in the result
            self.labelValues[8] = "N/A"
        }
        
        // registration_status from result
        if let registrationStatus = json["registration_status"].string {
            // registration_status found in the result
            self.labelValues[9] = registrationStatus
        } else {
            // registration_status not founc in the result
            self.labelValues[9] = "N/A"
        }
        
        // stolen_status from result
        if let stolenStatus = json["stolen_status"].string {
            // model_name found in the result
            self.labelValues[10] = stolenStatus
        } else {
            // model_name not founc in the result
            self.labelValues[10] = "N/A"
        }
        
        // block_date from result
        if let blockDate = json["compliant"]["block_date"].string {
            // block_date found in the result
            self.labelValues[11] = blockDate
        } else {
            // block_date not founc in the result
            self.labelValues[11] = "N/A"
        }
        if labels.count < 13 
        {
        //TO POPULATE Classification State
        if let items = json["classification_state"]["blocking_conditions"].array {
                // inactivity_reasons found in the result
            
                self.labels.append("Per Condition Classification State")
                self.labelValues.append("")
            if items.isEmpty {
                self.labels.append("N/A")
                self.labelValues.append("")
                resultRowsToMerge.append((labels.count-1))
            }
                for item in items {
                    if let labelEl = item["condition_name"].string {
                        self.labels.append(labelEl)
                    }
                    else{
                        self.labels.append("N/A")
                        
                    }
                    if let labelValueEl = item["condition_met"].bool {
                        self.labelValues.append(labelValueEl.description)
                    }
                    else{
                        self.labelValues.append("N/A")
                    }
                    
                }
                
            }
            //TO POPULATE Informative Conditions
            if let items = json["classification_state"]["informative_conditions"].array {
                // inactivity_reasons found in the result
                
                    self.labels.append("IMEI Per Informational Condition")
                    self.labelValues.append("")
                rowToMerge = (labels.count - 1)
                if items.isEmpty {
                    self.labels.append("N/A")
                    self.labelValues.append("")
                    resultRowsToMerge.append((labels.count - 1))
                }
                
                for item in items {
                    if let labelEl = item["condition_name"].string {
                        self.labels.append(labelEl)
                    }
                    else{
                        self.labels.append("N/A")
                    }
                    if let labelValueEl = item["condition_met"].bool {
                        self.labelValues.append(labelValueEl.description)
                    }
                    else{
                        self.labelValues.append("N/A")
                    }
                    
                }
                
            }
            }
        
        }
    }
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var cellRange = [CellRange(from: (row: 12, column: 0), to: (row: 12, column: 1))]
        print("rowToMerge \(rowToMerge) ")
        if rowToMerge > 0 {
            cellRange.append(CellRange(from: (row: rowToMerge, column: 0), to: (row: rowToMerge, column: 1)))
        }
        for i in resultRowsToMerge {
            cellRange.append(CellRange(from: (row: i, column: 0), to: (row: i, column: 1)))
        }
        return cellRange
    }
   
    
    
}
