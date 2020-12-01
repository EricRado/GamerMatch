//
//  GamerMatchCoreTabBarController.swift
//  GamerMatch
//
//  Created by Eric Rado on 11/21/20.
//  Copyright © 2020 Eric Rado. All rights reserved.
//

import UIKit

final class GamerMatchCoreTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		setupTabBarViewControllers()
		selectedIndex = 0
    }

	private func setupTabBarViewControllers() {
		let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
		guard let findGamerViewControler =
				mainStoryBoard.instantiateViewController(withIdentifier: "FindGamerViewController")
				as? FindGamerViewController,
			  let chatsViewController =
				mainStoryBoard.instantiateViewController(withIdentifier: "ChatsViewController")
				as? ChatsViewController,
			  let profileSettingsViewController =
				mainStoryBoard.instantiateViewController(withIdentifier: "ProfileSettingsViewController")
				as? ProfileSettingsViewController else {
			return
		}

		let findGamerNavigationController = UINavigationController(rootViewController: findGamerViewControler)
		findGamerNavigationController.tabBarItem.title = "Find Gamer"
		findGamerNavigationController.tabBarItem.image = UIImage(named: "search")

		let friendTabParentViewController = FriendTabParentViewController()
		let friendTabNavigationController = UINavigationController(rootViewController: friendTabParentViewController)
		friendTabNavigationController.tabBarItem.title = "Friends"
		friendTabNavigationController.tabBarItem.image = UIImage(named: "friends")

		let chatsNavigationController = UINavigationController(rootViewController: chatsViewController)
		chatsNavigationController.tabBarItem.title = "Chats"
		chatsNavigationController.tabBarItem.image = UIImage(named: "chats")

		let profileSettingsNavigationController = UINavigationController(rootViewController: profileSettingsViewController)
		profileSettingsNavigationController.tabBarItem.title = "Settings"
		profileSettingsNavigationController.tabBarItem.image = UIImage(named: "settings")

		setViewControllers([
			findGamerNavigationController,
			friendTabNavigationController,
			chatsNavigationController,
			profileSettingsNavigationController
		], animated: true)
	}

}
