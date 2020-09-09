//
//  GameDetailController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/22/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class GameDetailController : UIViewController {
    
    @IBOutlet weak var startDateTextLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var endDateTextLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var attendeesButton: UIButton!
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var game: Game?
    var imageString: String?
    var userId: String?
    var attendees: [String]?
    var userIsGoing: Bool?
    var ref: DatabaseReference!
    var idToGames: [String: Game]!
    var idtoUsers: [String: User]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = Auth.auth().currentUser?.uid 
        ref = Database.database().reference()
        userIsGoing = attendees!.contains(userId!)
        imageString = "game\(getSport(game!.sport!)!.rawValue)"
        gameImageView.image = UIImage(named: imageString!)
        gameImageView.clipsToBounds = true
        fillText()
        configureButtons()
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
        case "tennis":
            return Sport.tennis
        case "baseball":
            return Sport.baseball
        case "volleyball":
            return Sport.volleyball
        default:
            return Sport.other
        }
    }
    
    func fillText() {
        descriptionText.text = game?.desc
        titleLabel.text = game?.gameTitle
        let privateString = game!.isPrivate! ? "Private" : "Public"
        hostLabel.text = "\(privateString) Event - Hosted by \(game?.creator ?? "Anonymous")"
        sportLabel.text = "Sport - \(game?.sport ?? "Other")"
        
        
        //set date
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = .medium
        myDateFormatter.timeStyle = .short
        myDateFormatter.timeZone = TimeZone.current
        startDateTextLabel.text = "Starts: \(myDateFormatter.string(from: game?.start ?? Date()))"
        endDateTextLabel.text = "Ends: \(myDateFormatter.string(from: game?.end ?? Date()))"
    }
    
    func configureButtons() {
        attendButton.layer.cornerRadius = 10
        attendeesButton.layer.cornerRadius = 10
        attendButton.setTitle(userIsGoing! ? "Going" : "Attend", for: .normal)
        attendButton.backgroundColor = (userIsGoing! ? .systemGreen : .systemBlue)
        attendeesButton.setTitle("\(attendees!.count) Going", for: .normal)
    }
    
//    //retrieving data in case it has changed since user tapped on game
//    func resetFromFirebase() {
//        DispatchQueue.main.async {
//            //didn't go inside closure function for some reason..?????
//            self.ref?.child("posts").child(self.game!.id!).child("attendees").observeSingleEvent(of: .value, with: { (snapshot) in
//                let oldAttendees = snapshot.value as! [String]
//                self.attendees = oldAttendees
//            }) { (error) in
//                print(error.localizedDescription)
//            }
//        }
//    }
 
// no idea why I can't read from database
//    func getUsers() -> [String] {
//        var users = [String]()
//        for userId in self.attendees! {
//            DispatchQueue.main.async {
//                Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
//                    guard let userDict = snapshot.value as? [String: Any] else { return }
//                    let username = userDict["username"] as? String
//                    users.append(username!)
//                }
//            }
//        }
//        return users
//    }
    
    @IBAction func attendTapped(_ sender: Any) {
//      resetFromFirebase()
        if userIsGoing! {
            let index = attendees?.firstIndex(of: userId!)
            attendees?.remove(at: index!)
        } else {
            attendees?.append(userId!)
        }
        game?.setAttendees(attendees: attendees!)
        ref?.child("posts").child(game!.id!).child("attendees").setValue(attendees)
        userIsGoing?.toggle()
        configureButtons()
    }

    @IBAction func viewAttendees(_ sender: Any) {
        performSegue(withIdentifier: "showAttendees", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAttendees") {
            let userTVC =  segue.destination as! UserTableViewController
            
            userTVC.users = FeedController.getUsers(forGame: game!, idToUsers: idtoUsers)
            userTVC.idToUser = idtoUsers
            userTVC.idToGame = idToGames
        }
    }
}
