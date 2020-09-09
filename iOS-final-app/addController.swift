//
//  addGameController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/20/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit

class failedAddGameController: UITableViewController {
    //TRIED TO implement in line date picker with a UITableViewController like is done for
    //adding an event in the actual calendar app from a tutorial but it wasn't working
    
    
    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 1
    let kDateEndRow   = 2
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"; // the cell containing the date picker
    let kOtherCellID      = "otherCell";      // the remaining cells at the end
    
    var dataArray: [[String: Any]] = []
    var dateFormatter = DateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    var pickerCellRowHeight: CGFloat = 215
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemOne = ["kTitleKey" : "Tap a cell to change its date:"]
        let itemTwo = ["kTitleKey" : "Start Date", "kDateKey" : NSDate()] as [String : Any]
        let itemThree = ["kTitleKey" : "End Date", "kDateKey" : NSDate()] as [String : Any]
        let itemFour = ["kTitleKey" : "(other item1)"]
        let itemFive = ["kTitleKey" : "(other item2)"]
        let itemSix = ["kTitleKey" : "(other item3)"]
        dataArray = [itemOne, itemFour, itemFive, itemSix, itemTwo, itemThree]
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

    }
    
    //MARK: TableView Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasInlineDatePicker() {
            // we have a date picker, so allow for it in the number of rows in this section
            return dataArray.count + 1;
        }
        
        return dataArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
            
        var cellID = kOtherCellID
            
        if indexPathHasPicker(indexPath: indexPath) {
                // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath: indexPath) {
                // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
            
        cell = myTableView.dequeueReusableCell(withIdentifier: "otherCell")
            
        
            
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && datePickerIndexPath?.row ?? 0 <= indexPath.row) { modelRow -= 1 }
        let itemData = dataArray[modelRow]
        if cellID == kDateCellID {
            // we have either start or end date cells, populate their date field //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = self.dateFormatter.string(from: (itemData[kDateKey] as! NSDate) as Date)
        } else if cellID == kOtherCellID {
            // this cell is a non-date cell, just assign it's text label //
            cell?.textLabel?.text = itemData[kTitleKey] as? String }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return (indexPathHasPicker(indexPath: indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    //MARK: Action Methods
    @IBAction func dateAction(_ sender: UIDatePicker) {
        var targetedCellIndexPath: IndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = self.myTableView.indexPathForSelectedRow!
        }
        
        let cell = self.myTableView.cellForRow(at: targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.string(from: targetedDatePicker.date)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        let targetedCellIndexPath: IndexPath =  IndexPath(row: 2, section: 0)
        let cell = myTableView.cellForRow(at: targetedCellIndexPath)
        let cellLabelText  = cell?.textLabel!.text
        let dateString = cell?.detailTextLabel!.text
        
        print("\(cellLabelText!): \(dateString!)")
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "MM/dd/yy, h:mm a"
        myDateFormatter.timeZone = TimeZone.current
        
        let providedDate = myDateFormatter.date(from: dateString!)! as Date
        
        print(myDateFormatter.string(from: providedDate))
    }
    
    //MARK: Helper Methods
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    func indexPathHasDate(indexPath: IndexPath) -> Bool {
        var hasDate = false
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }
    
    func indexPathHasPicker(indexPath: IndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: IndexPath) {
        
        // display the date picker inline with the table content
        self.myTableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = datePickerIndexPath!.row < indexPath.row
        }
        
        let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            self.myTableView.deleteRows(at: [IndexPath(row: datePickerIndexPath!.row, section: 0)], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPath: indexPathToReveal)
            datePickerIndexPath = NSIndexPath(row: indexPathToReveal.row + 1, section: 0)
        }
        
        // always deselect the row containing the start or end date
        self.myTableView.deselectRow(at: indexPath, animated:true)
        
        self.myTableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    func toggleDatePickerForSelectedIndexPath(indexPath: IndexPath) {
        
        self.myTableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: 0)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath: indexPath) {
            // found a picker below it, so remove it
            self.myTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            // didn't find a picker below it, so we should insert it
            self.myTableView.insertRows(at: indexPaths, with: .fade)
        }
         self.myTableView.endUpdates()
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = self.myTableView.cellForRow(at: indexPath as IndexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! Date, animated: false)
            }
        }
    }
    
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
     
     @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
     */
    func hasPickerForIndexPath(indexPath: IndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = self.myTableView.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
}
