//
//  addEventController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/20/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseUI

protocol AddGameDelegate: class {
    func didCreate(_ game: Game)
    
    func dismissLabel()
}

class AddGameController: UIViewController {
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var sportTextField: UITextField!
    @IBOutlet weak var privacySwitch: UISwitch!
    
    weak var delegate: AddGameDelegate?
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    var endDate : Date?
    var startDate : Date?
    var location : CLLocationCoordinate2D?
    var username : String?
    var userId : String? 
    
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
    
    func createNewGame() -> Game? {
        guard let title = titleTextField.text else { return nil }
        guard let sportText = sportTextField.text else { return nil }
        guard let start = startDate else { return nil }
        guard let end = endDate else { return nil }
        guard let desc = descriptionTextField.text else { return nil }
        let isPrivate = privacySwitch.isOn
        
        var attendees = [String]()
        attendees.append(userId!)
        let game = Game(id: nil, title: title, coordinate: location, sport: sportText, creator: username, start: start, end: end, desc: desc, isPrivate: isPrivate, attendees: attendees)
        dump(game)
        return game
    }
    
    func getSport(_ sportText: String) -> Sport? {
        let sport = sportText.lowercased()
        switch sport {
        case "soccer":
            return Sport.soccer
        case "football":
            return Sport.football
        case "basketball":
            return Sport.basketball
        default:
            return Sport.other
        }
    }
    
    @IBAction func barDonePressed(_ sender: Any) {
        if let game = createNewGame() {
            print("made it to inside")
            self.delegate?.didCreate(game)
        }
    }
    @IBAction func cancelPressed(_ sender: Any) {
        delegate?.dismissLabel()
        dismiss(animated: true, completion: nil)
    }
    
}
