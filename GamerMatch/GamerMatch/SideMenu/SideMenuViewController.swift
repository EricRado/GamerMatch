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
    var iconNameArray = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconNameArray = ["top","Profile","Settings", "Logout"]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePicCell") as! SideMenuTopTableViewCell
            //cell.profileNameLabel = Auth.auth().currentUser?.uid
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell") as! SideMenuTableViewCell
            cell.iconNameLabel.text = iconNameArray[indexPath.row]
            return cell
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
