//
//  addEventController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/20/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit
import 
protocol AddGameDelegate: class {
    func didCreate(_ event: Game)
}
class addEventController: UIViewController {
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var sportTextField: UITextField!
    
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    var endDate : Date?
    var startDate : Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePickers()
    }
    
    func createDatePickers() {
        createStartDatePicker()
        createEndDatePicker()
    }
    
    func createStartDatePicker() {
        
        datePicker1.minuteInterval = 15
        datePicker1.datePickerMode = .dateAndTime
        datePicker1.minimumDate = Date()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(startDonePressed))
        toolbar.setItems([donebtn], animated: true)
        
        startDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputAccessoryView = toolbar
        
        startDateTextField.inputView = datePicker1
    }
    
    @objc func startDonePressed() {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = .medium
        myDateFormatter.timeStyle = .short
        startDate = datePicker1.date
        startDateTextField.text = "Starts: \(myDateFormatter.string(from: startDate ?? Date()))"
        self.view.endEditing(true)
    }
    
    func createEndDatePicker() {
        
        datePicker2.minuteInterval = 15
        datePicker2.datePickerMode = .dateAndTime
        datePicker2.minimumDate = Date()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endDonePressed))
        toolbar.setItems([donebtn], animated: true)
        
        endDateTextField.inputAccessoryView = toolbar
        
        endDateTextField.inputView = datePicker2
    }
    
    @objc func endDonePressed() {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = .medium
        myDateFormatter.timeStyle = .short
        myDateFormatter.timeZone = TimeZone.current
        endDate = datePicker2.date
        endDateTextField.text = "Ends: \(myDateFormatter.string(from: endDate ?? Date()))"
        self.view.endEditing(true)
    }
    @IBAction func barDonePressed(_ sender: Any) {
        
    }
    
}
