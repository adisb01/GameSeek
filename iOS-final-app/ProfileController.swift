//
//  ProfileController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/16/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MapKit

class ProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var posts = [Game]()
    var idToGame = [String: Game]()
    var idToUser = [String: User] ()
    var currPostIndex = 0
    var refHandlePosts : DatabaseHandle!
    var refHandleUsers: DatabaseHandle!
    var ref: DatabaseReference!
    var userId: String!
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        activateDatabase()
        profileImageView.layer.cornerRadius = 75
        friendsButton.layer.cornerRadius = 10
        editProfButton.layer.cornerRadius = 10
        loadUserData()
    }
    @IBAction func signoutTapped(_ sender: Any) {
        alertSignOut()
    }
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editProfButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
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
                        self.loadUserData()
                    }
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
                        let postsDict = userDict["posts"] as! [String: AnyObject]
                        let postIds = Array(postsDict.keys) as! [String]
                        let newUser = User(username: name as! String, postIds: postIds)
                        self.idToUser[userId] = newUser
                        self.loadUserData()
                    }
                }
                print("USERS:")
                dump(self.idToUser)
                //this also won't transfer the data
            })
        }
    
    func alertSignOut() {
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
                self.signOut()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userId = uid
        user = idToUser[userId]
        posts = getGames(forUser: user, idToGames: idToGame)
        self.usernameLabel.text = "\(user.username)"
    }
    
     
    func getGames(forUser user: User, idToGames: [String: Game]) -> [Game] {
        var games = [Game]()
        let postIds = user.postIds
        for id in postIds! {
            let newGame = idToGames[id]
            games.append(newGame!)
        }
        return games
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "backToLogin", sender: self)
        } catch let error {
            print("Failed to sign out with error", error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell")
        if let label = cell!.viewWithTag(1) as? UILabel {
            label.text = posts[indexPath.row].gameTitle!
        }
        if let imageIcon = cell!.viewWithTag(2) as? UIImageView {
            imageIcon.layer.cornerRadius = 25
            let sport = FeedController.getSport(posts[indexPath.row].sport!)!.rawValue
            imageIcon.image = UIImage(named: sport)
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Deselect the cell, and toggle the "favorited" property in your model
        tableView.deselectRow(at: indexPath, animated: true)
        currPostIndex = indexPath.row
        performSegue(withIdentifier: "showUserPost", sender: self)
        self.tableView.reloadData()
    }
    
    //if try to do anything at the game detail, will crash since data wasn't loaded
    //properly from FeedController for idToUser and idToGame, couldn't figure out bug
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showUserPost") {
            let gameDetailVC = segue.destination as! GameDetailController
            let currPost = posts[currPostIndex]
            gameDetailVC.game = currPost
            gameDetailVC.idtoUsers = idToUser
            gameDetailVC.idToGames = idToGame
            gameDetailVC.userId = userId
            gameDetailVC.ref = ref
            gameDetailVC.attendees = currPost.attendees
        }
    }
}
