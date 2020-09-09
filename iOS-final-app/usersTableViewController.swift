//
//  usersTableViewController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/22/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    //doesn't really matter if this isn't dynamic with updating data
    var users : [User]!
    var idToUser : [String: User]!
    var idToGame: [String: Game]!
    var currUserIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")!
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = users[indexPath.row].username!
        }
        if let image = cell.viewWithTag(1) as? UIImageView {
            image.layer.cornerRadius = 30
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Deselect the cell, and toggle the "favorited" property in your model
        tableView.deselectRow(at: indexPath, animated: true)
        currUserIndex = indexPath.row
        performSegue(withIdentifier: "seeUser", sender: self)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seeUser") {
            let userVC = segue.destination as! UserProfileController
            let currUser = users[currUserIndex]
            userVC.user = currUser
            if !currUser.postIds!.isEmpty {
                userVC.posts = FeedController.getGames(forUser: currUser, idToGames: idToGame)
            }
            userVC.idToGames = idToGame
            userVC.idToUser = idToUser
        }
    }
}
