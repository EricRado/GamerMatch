//
//  FriendsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

final class FriendTabParentViewController: UIViewController {

	private enum ViewState: Int {
		case friends
		case friendRequests
	}

	private let friendsViewController = FriendsViewController()
	private let friendRequestsViewController = FriendRequestsViewController()

	private lazy var segmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: ["Friends", "Friend Requests"])
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.addTarget(self, action: #selector(segmentedControlPressed(sender:)), for: .valueChanged)
		return segmentedControl
	}()

	private let friendsContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()

	private let friendRequestsContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()

	private var viewState: ViewState = .friends {
		didSet {
			switch viewState {
			case .friends:
				friendsContainerView.isHidden = false
				friendRequestsContainerView.isHidden = true
			case .friendRequests:
				friendsContainerView.isHidden = true
				friendRequestsContainerView.isHidden = false
			}
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.title = "Friends"
		view.backgroundColor = .white
		setupView()
    }

	private func setupView() {
		view.addSubview(segmentedControl)
		view.addSubview(friendsContainerView)
		view.addSubview(friendRequestsContainerView)
		
		NSLayoutConstraint.activate([
			segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
		])

		NSLayoutConstraint.activate([
			friendsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			friendsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			friendsContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
			friendsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			friendRequestsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			friendRequestsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			friendRequestsContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
			friendRequestsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])

		addChildViewController(friendsViewController)
		friendsContainerView.addSubview(friendsViewController.view)
		friendsViewController.didMove(toParentViewController: parent)
		friendsViewController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			friendsViewController.view.leadingAnchor.constraint(equalTo: friendsContainerView.leadingAnchor),
			friendsViewController.view.trailingAnchor.constraint(equalTo: friendsContainerView.trailingAnchor),
			friendsViewController.view.topAnchor.constraint(equalTo: friendsContainerView.topAnchor),
			friendsViewController.view.bottomAnchor.constraint(equalTo: friendsContainerView.bottomAnchor)
		])

		addChildViewController(friendRequestsViewController)
		friendRequestsContainerView.addSubview(friendRequestsViewController.view)
		friendRequestsViewController.didMove(toParentViewController: parent)
		friendRequestsViewController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			friendRequestsViewController.view.leadingAnchor.constraint(equalTo: friendRequestsContainerView.leadingAnchor),
			friendRequestsViewController.view.trailingAnchor.constraint(equalTo: friendRequestsContainerView.trailingAnchor),
			friendRequestsViewController.view.topAnchor.constraint(equalTo: friendRequestsContainerView.topAnchor),
			friendRequestsViewController.view.bottomAnchor.constraint(equalTo: friendRequestsContainerView.bottomAnchor)
		])

		friendRequestsContainerView.isHidden = true
		segmentedControl.selectedSegmentIndex = 0
	}
    
    @objc fileprivate func segmentedControlPressed(sender: UISegmentedControl) {
		guard let selectedViewState = ViewState.init(rawValue: sender.selectedSegmentIndex) else { return }
		viewState = selectedViewState
    }
}
