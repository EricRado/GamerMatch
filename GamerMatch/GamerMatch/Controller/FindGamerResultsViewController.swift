//
//  FindGamerResultsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/13/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

final class FindGamerResultsViewController: UIViewController {

    private let vcIdentifier = "GamerProfileViewController"
    private var usersCacheInfo = [UserCacheInfo]()
    private var userIds: [String]

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .white
		collectionView.register(UserSearchResultCell.self, forCellWithReuseIdentifier: UserSearchResultCell.identifier)
		collectionView.dataSource = self
		collectionView.delegate = self
		return collectionView
	}()

	init(userIds: [String]) {
		self.userIds = userIds
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .white
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])

        getUsersResults(from: userIds)
    }
    
    fileprivate func getUsersResults(from gamerIds: [String]) {
        for id in gamerIds {
            guard id != User.onlineUser.uid else { continue }
            FirebaseCalls.shared.getUserCacheInfo(for: id) { [weak self] (userCacheInfo, error) in
				guard let self = self else { return }

				if let error = error {
                    print(error.localizedDescription)
					return
                }

                if let userCacheInfo = userCacheInfo {
                    self.usersCacheInfo.append(userCacheInfo)
					let indexPath = IndexPath(row: self.usersCacheInfo.count - 1, section: 0)
					self.collectionView.insertItems(at: [indexPath])
                }
            }
        }
    }

}

extension FindGamerResultsViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return usersCacheInfo.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView
				.dequeueReusableCell(withReuseIdentifier: UserSearchResultCell.identifier, for: indexPath)
				as? UserSearchResultCell else { return UICollectionViewCell() }
		let userCacheInfo = usersCacheInfo[indexPath.row]
		cell.configure(with: userCacheInfo.username ?? "", urlString: userCacheInfo.url)
		return cell
	}
}

extension FindGamerResultsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		let userCacheInfo = usersCacheInfo[indexPath.row]

		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		guard let gamerProfileViewController = mainStoryboard
				.instantiateViewController(withIdentifier: vcIdentifier)
				as? GamerProfileViewController else { return }
		gamerProfileViewController.userCacheInfo = userCacheInfo

		navigationController?.navigationBar.topItem?.backBarButtonItem?.title = "Back"
		navigationController?.pushViewController(gamerProfileViewController, animated: true)
	}

	func collectionView(
		_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: UserSearchResultCell.preferredHeight)
	}
}
