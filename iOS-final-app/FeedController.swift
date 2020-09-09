//
//  FeedController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/16/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//


import UIKit
import Firebase
import FirebaseUI
import MapKit
class FeedController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: Variables
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var gameMap: MKMapView!
    @IBOutlet weak var addGameLabel: UILabel!
    
    var ref: DatabaseReference!
    var refHandlePosts: DatabaseHandle!
    var refHandleUsers: DatabaseHandle!
    var locationManager = CLLocationManager()
    var isAddingGame = false
    var tappedCoordinate: CLLocationCoordinate2D?
    var username: String?
    var uid: String?
    var idToGame = [String: Game]()
    var idToUser = [String : User]()
    var selectedGame : Game?
    var otherTab: ProfileController!
    //MARK: Set-up Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        otherTab = self.tabBarController?.viewControllers![1] as! ProfileController
        roundViews()
        requestLocation()
        activateDatabase()
        addGameLabel.clipsToBounds = true
        addGameLabel.layer.cornerRadius = 10
        addGameLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        addGameLabel.isHidden = true
    }
    
    //MARK: Database Interaction
    func activateDatabase() {
        ref = Database.database().reference()
        refHandlePosts = ref.child("posts").observe( .value, with: { (snapshot) in
            self.idToGame.removeAll()
            print("at least here")
            
            DispatchQueue.main.async {
                for gameObject in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    //getting values
                    let game = gameObject.value as? [String: AnyObject]
                    let gameId = gameObject.key
                    guard let title = game!["title"] as? String else { print("bad title"); return }
                    guard let sport = game!["sport"] as? String else { print("bad sport"); return }
                    guard let creator = game!["creator"] as? String else { print("bad create"); return}
                    guard let start = FeedController.stringToDate(forString: (game!["start"] as? String)!) as? Date else { print("bad start"); return  }
                    guard let end = FeedController.stringToDate(forString: (game!["end"] as? String)!) as? Date else { print("bad end"); return }
                    guard let desc = game!["desc"] as? String else { print("bad desc"); return  }
                    guard let isPrivate = game!["isPrivate"] as? Bool else { print("bad privacy"); return }
                    let lat = game!["lat"] as? CLLocationDegrees
                    let long  = game!["long"] as? CLLocationDegrees
                    let attendees = game!["attendees"] as? [String]
                    let coord = CLLocationCoordinate2DMake(lat! , long!)
                    
                    //Create game annotation and add it to map annotations
                    let gameAnnotation = Game(id: gameId, title: title, coordinate: coord, sport: sport, creator: creator, start: start, end: end, desc: desc, isPrivate: isPrivate, attendees: attendees)
                    dump(gameAnnotation)
                    self.idToGame[gameId] = gameAnnotation
                }
                var gameAnnotations = Array(self.idToGame.values) as [Game]
                self.gameMap.addAnnotations(gameAnnotations)
                print("annotations:")
                dump(self.gameMap.annotations)
                
                //this won't transfer the data?
                self.otherTab.idToGame = self.idToGame
                //this does transer the date
            }
        })
        
        refHandleUsers = ref.child("users").observe(.value, with: { (snapshot) in
            self.idToUser.removeAll()
            print("Reset users")
            
            DispatchQueue.main.async {
                for userObject in (snapshot.children.allObjects as? [DataSnapshot])! {
                    
                    //getting values
                    let userDict = userObject.value as! [String: AnyObject]
                    let userId = userObject.key
                    let name = userDict["username"]
                    if let postsDict = userDict["posts"] as? [String: AnyObject] {
                        let postIds = Array(postsDict.keys) as! [String]
                        let newUser = User(username: name as! String, postIds: postIds)
                        self.idToUser[userId] = newUser
                    } else {
                        let newUser = User(username: name as! String, postIds: [String]())
                        self.idToUser[userId] = newUser
                    }
                    
                    
                    
                }
            }
            print("USERS:")
            dump(self.idToUser)
            //this also won't transfer the data
            self.otherTab.idToUser = self.idToUser
        })
//            if let games = snapshot.value as? [NSDictionary] {
//                print("got here")
//                DispatchQueue.main.async {
//                   for game in games {
//                        //Extract fields or exit if fail
//                        guard let title = game["title"] as? String else { print("bad title"); return }
//                        guard let sport = self.getSport(game["sport"] as! String) else { print("bad sport"); return }
//                        guard let creator = game["creator"] as? String else { print("bad create"); return}
//                        guard let start = self.stringToDate(forString: (game["start"] as? String)!) as? Date else { print("bad start"); return  }
//                        guard let end = self.stringToDate(forString: (game["end"] as? String)!) as? Date else { print("bad end"); return }
//                        guard let desc = game["desc"] as? String else { print("bad desc"); return  }
//                        guard let isPrivate = game["isPrivate"] as? Bool else { print("bad privacy"); return }
//                        let lat = game["lat"] as? CLLocationDegrees
//                        let long  = game["long"] as? CLLocationDegrees
//                        let coord = CLLocationCoordinate2DMake(lat! , long!)
//                        print("got here 2")
//
//                        //Create game annotation and add it to map annotations
//                        let gameAnnotation = Game(title: title, coordinate: coord, sport: sport, creator: creator, start: start, end: end, desc: desc, isPrivate: isPrivate)
//                        self.gameAnnotations.append(gameAnnotation)
//                        self.mapView.addAnnotations(self.gameAnnotations)
//                    }
//                }
//            } else {
//                print("failed to load data from Firebase")
//            }
        
    }
    
    static func getGames(forUser user: User, idToGames: [String: Game]) -> [Game] {
        var games = [Game]()
        let postIds = user.postIds
        for id in postIds! {
            let newGame = idToGames[id]
            games.append(newGame!)
        }
        return games
    }
    
    static func getUsers(forGame game: Game, idToUsers: [String: User]) -> [User] {
        var users = [User]()
        let userIds = game.attendees
        for id in userIds! {
            let newUser = idToUsers[id]
            users.append(newUser!)
        }
        return users
    }
    
    
    //MARK: Helper functions
    static func getSport(_ sportText: String) -> Sport? {
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
    
    func requestLocation() {
        //Location Permission Setup
        gameMap.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            loadUserData()
        } else {
            performSegue(withIdentifier: "deniedLocation", sender: self)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        let regionRadius: CLLocationDistance = 2000
        let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        gameMap.setRegion(viewRegion, animated: true)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        centerMapOnUser()
//
//    center on my home :)
//    func centerMapOnUser() {
//        let coord = CLLocationCoordinate2D(latitude: 45.060181, longitude: -93.476743)
//        let regionRadius: CLLocationDistance = 2000
//        let region = MKCoordinateRegion(center: coord, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//        mapView.setRegion(region, animated: true)
//    }
    
    func roundViews() {
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.layer.masksToBounds = true
    }
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        uid = userId
        Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? String else { return }
            print(user)
            self.username = user
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        isAddingGame.toggle()
        addGameLabel.isHidden.toggle()
    }
    
    @IBAction func tapMap(_ sender: UITapGestureRecognizer) {
        if (!isAddingGame && !addGameLabel.isHidden) {
            addGameLabel.isHidden = true
        }
        if (isAddingGame && sender.state == .ended) {
            let locationInView = sender.location(in: gameMap)
            tappedCoordinate = gameMap.convert(locationInView, toCoordinateFrom: gameMap)
            performSegue(withIdentifier: "addGame", sender: self)
            isAddingGame.toggle()
        }
    }
    
    //MARK: Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addGame") {
            let navVC = segue.destination as! UINavigationController
            let gameController = navVC.topViewController as! AddGameController
            gameController.location = tappedCoordinate
            gameController.username = username
            gameController.userId = uid
            gameController.delegate = self
        }
        if (segue.identifier == "gameDetail") {
            let gameDetailVC = segue.destination as! GameDetailController
            gameDetailVC.game = selectedGame
            gameDetailVC.attendees = selectedGame?.attendees
            gameDetailVC.userId = uid
            if (!idToGame.isEmpty) {
                gameDetailVC.idToGames = idToGame
            }
            if (!idToUser.isEmpty) {
                gameDetailVC.idtoUsers = idToUser
            }
            gameDetailVC.ref = ref
        }
    }
    
}


// MARK: Map Delegate
extension FeedController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("getting annotationview")
        guard let gameAnnotation = annotation as? Game else { print("ann cast failed"); return nil }
        var gameAnnotationView : MKAnnotationView?
        let sport = FeedController.getSport(gameAnnotation.sport!)
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: sport!.rawValue) {
            gameAnnotationView = dequedView
            gameAnnotationView?.annotation = gameAnnotation
        } else {
            gameAnnotationView = MKAnnotationView(annotation: gameAnnotation, reuseIdentifier: sport?.rawValue)
        }
        if let gameAnnotationView = gameAnnotationView {
            gameAnnotationView.image = UIImage(named: sport!.rawValue)
            //configure callouts
            let detailButton = self.getCalloutButton()
            gameAnnotationView.rightCalloutAccessoryView = detailButton
            let titleLabel = self.getCalloutLabel(with: gameAnnotation.gameTitle!)
            gameAnnotationView.detailCalloutAccessoryView = titleLabel
            gameAnnotationView.canShowCallout = true
        }
        
        print("got annotation view")
        dump(gameAnnotationView)
        return gameAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        if let button = view.rightCalloutAccessoryView as? UIButton {
            if let gameAnnoation = view.annotation as? Game {
                selectedGame = gameAnnoation
                performSegue(withIdentifier: "gameDetail", sender: self)
            }
        }
    }
    
    private func getCalloutLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        return label
    }
    
    
    private func getCalloutButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Details", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.frame = CGRect.init(x: 0, y: 0, width: 100, height: 40)
        return button
    }
}

// MARK: Add Game Delegate
extension FeedController: AddGameDelegate {
    
    func dismissLabel() {
        addGameLabel.isHidden = true
        isAddingGame = false
    }
    
    func didCreate(_ game: Game) {
 //       addGameLabel.isHidden = true
        dismiss(animated: true, completion: nil)
        print("should be dismissed now")
        isAddingGame = false 
        addGameLabel.isHidden = true
        let gameDict = [
            "title": game.gameTitle!,
            "lat": game.location!.latitude,
            "long": game.location!.longitude,
            "sport": game.sport,
            "start": FeedController.dateToString(date: game.start!),
            "end": FeedController.dateToString(date: game.end!),
            "desc": game.desc!,
            "isPrivate": game.isPrivate!,
            "creator": game.creator!,
            "attendees": game.attendees!
            ] as [String : Any]
        
        //update total list of posts and list of posts for the current user
        guard let uid = Auth.auth().currentUser?.uid else { print("failed to get uid"); return }
        guard let key = ref.child("posts").childByAutoId().key else { return }
        let childUpdates = ["/posts/\(key)": gameDict,
                            "/users/\(uid)/posts/\(key)/": gameDict]
        ref.updateChildValues(childUpdates)
        
//        //add to list of games
//        let newPostId: String = String(gameAnnotations.count + 1)
//        ref?.child("games").child(newPostId).setValue(gameDict)
//        var posts: [String]?
//
//        //add to user's list of games posted
//
//        ref?.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let user = snapshot.value as? NSDictionary else { print("failed to get fb user"); return }
//            if let postIds = user["posts"] as? [String] {
//                //user currently has posts
//                posts = postIds
//                posts?.append(newPostId)
//            } else {
//                //posts are currently empty
//                posts = [String]()
//                posts!.append(newPostId)
//            }
//        })
//        ref?.child("users").child(uid).child("posts").setValue(posts)
        
        tappedCoordinate = nil
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: date)
    }
    
    static func stringToDate(forString stringDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: stringDate)!
    }

}

