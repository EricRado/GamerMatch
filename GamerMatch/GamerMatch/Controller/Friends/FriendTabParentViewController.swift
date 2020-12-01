//
//  FriendsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

final class FriendTabParentViewController: UIViewController {

	private lazy var segmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: ["Friends", "Friend Requests"])
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.addTarget(self, action: #selector(segmentedControlPressed(sender:)), for: .valueChanged)
		return segmentedControl
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc fileprivate func segmentedControlPressed(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Friends control pressed")
            
        case 1:
            print("Friend requests pressed")
        default:
            break
        }
    }
}
