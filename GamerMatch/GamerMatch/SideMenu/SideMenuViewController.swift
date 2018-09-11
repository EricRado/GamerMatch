//
//  SideMenuViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/26/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var interactor: Interactor? = nil
    let iconNameArray = ["top", "Home","Profile", "Friend Requests","Add A Tournament","Settings", "Logout"]
    let iconImageArray = [UIImage(named: "noAvatar"), UIImage(named: "home"), UIImage(named: "profile"), UIImage(named: "friendRequest"),UIImage(named: "addTournament"), UIImage(named: "settings"), UIImage(named: "logout")]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePicCell") as! SideMenuTopTableViewCell
            cell.profileNameLabel.text = User.onlineUser.username
            if let data = User.onlineUser.userImg?.image {
                print("there is something here...")
            }
            cell.profileImage.image = User.onlineUser.userImg?.image
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell") as! SideMenuTableViewCell
            cell.iconNameLabel.text = iconNameArray[indexPath.row]
            cell.iconImage.image = iconImageArray[indexPath.row]
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 1 {
            if iconNameArray[indexPath.row] == "Settings" {
                performSegue(withIdentifier: "settingsSegue", sender: self)
            }
            if iconNameArray[indexPath.row] == "Add A Tournament" {
                performSegue(withIdentifier: "addTournamentSegue", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.bounds.height * 0.3
        }
        return view.bounds.height * 0.08
    }
    
    @IBAction func closeMenu(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        // you use translation(in: view) to get the pan gesture coordinates
        let translation = sender.translation(in: view)
        
        // using MenuHelper's calculateProgress() method, you convert the coordinates
        // into progress in a specific direction
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        // does the work of syncing the gesture state with the interactive translation
        MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
