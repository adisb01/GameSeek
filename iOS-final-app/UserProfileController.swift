//
//  UserProfileController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/23/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit

class UserProfileController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User!
    var posts = [Game]()
    var idToGames: [String: Game]!
    var idToUser: [String: User]!
    var friends: Int?
    var isFriend = false
    var currPostIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 75
        profileImageView.clipsToBounds = true
        usernameLabel.text = user.username
        friends = Int.random(in: 1 ... 1000)
        configureButtons()
    }
    
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBAction func addFriend(_ sender: Any) {
        if isFriend {
            friends = friends! - 1
        } else {
            friends = friends! + 1
        }
        isFriend.toggle()
        configureButtons()
    }
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var postsTableView: UITableView!
    
    func configureButtons() {
           friendsButton.layer.cornerRadius = 10
           addFriendButton.layer.cornerRadius = 10
           addFriendButton.setTitle(isFriend ? "Friend" : "Add Friend", for: .normal)
           addFriendButton.backgroundColor = (isFriend ? .systemGreen : .systemBlue)
           friendsButton.setTitle("\(friends!) Friends", for: .normal)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
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
        performSegue(withIdentifier: "seeUserPost", sender: self)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seeUserPost") {
            let gameDetailVC = segue.destination as! GameDetailController
            let currPost = posts[currPostIndex]
            gameDetailVC.game = currPost
            gameDetailVC.idtoUsers = idToUser
            gameDetailVC.idToGames = idToGames
            gameDetailVC.attendees = currPost.attendees
        }
    }
}
