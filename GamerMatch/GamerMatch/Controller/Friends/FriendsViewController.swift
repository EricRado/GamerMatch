//
//  FriendsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 11/24/20.
//  Copyright © 2020 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

final class FriendsViewController: UIViewController {
	
	private let vcIdentifier = "GamerProfileViewController"
	private let onlineSectionId = 0
	private let offlineSectionId = 1

	private let friendRef: DatabaseReference = {
		return Database.database().reference().child("Friends/")
	}()

	private var onlineFriends = [UserCacheInfo]()
	private var offlineFriends = [UserCacheInfo]()

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView()
		return collectionView
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

		getUserFriends() {
			guard let onlineView = self.collectionView
				.supplementaryView(forElementKind: UICollectionElementKindSectionHeader,
								   at: IndexPath(item: 0, section: 0)) as?
				FriendCollectionViewHeader else { return }

			guard let offlineView = self.collectionView
				.supplementaryView(forElementKind: UICollectionElementKindSectionHeader,
								   at: IndexPath(item: 0, section: 1)) as?
				FriendCollectionViewHeader else { return }

			onlineView.friendsCountLabel.text = "\(self.onlineFriends.count)"
			offlineView.friendsCountLabel.text = "\(self.offlineFriends.count)"
		}
    }

	fileprivate func getUserFriends(completion: @escaping (() -> Void)) {
		guard let uid = User.onlineUser.uid else { return }

		var counter = 0
		let ref = friendRef.child("\(uid)/")

		ref.observe(.childAdded, with: { (snapshot) in
			let id = snapshot.key

			FirebaseCalls.shared.getUserCacheInfo(for: id, completion: { (userCacheInfo, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				guard let friend = userCacheInfo else { return }
				guard let status = friend.isOnline?.toBool() else { return }


				if status {
					self.onlineFriends.append(friend)
					let row = self.onlineFriends.count - 1
					self.collectionView
						.insertItems(at: [IndexPath(item: row, section: self.onlineSectionId)])
				} else {
					self.offlineFriends.append(friend)
					let row = self.offlineFriends.count - 1
					self.collectionView
						.insertItems(at: [IndexPath(item: row, section: self.offlineSectionId)])
				}
				counter += 1
				if counter == snapshot.childrenCount { completion() }
			})

		}, withCancel: { (error) in
			print(error.localizedDescription)
		})
	}

}

// MARK: - UICollectionViewDataSource
extension FriendsViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}

	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return onlineFriends.count
		} else {
			return offlineFriends.count
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: FriendCell.identifier,
				for: indexPath) as? FriendCell else { return UICollectionViewCell() }
		let friend = indexPath.section == onlineSectionId ? onlineFriends[indexPath.item] : offlineFriends[indexPath.item]
		cell.configure(with: friend.username ?? "", urlString: friend.url)
		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension FriendsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		let user = indexPath.section == 0 ? onlineFriends[indexPath.item] : offlineFriends[indexPath.item]

		guard let vc = storyboard?.instantiateViewController(withIdentifier: vcIdentifier)
			as? GamerProfileViewController else { return }
		vc.userCacheInfo = user
		navigationController?.pushViewController(vc, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {
		let headerCell = collectionView
			.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
											  withReuseIdentifier: FriendCollectionViewHeader.identifier,
											  for: indexPath) as! FriendCollectionViewHeader
		if indexPath.section == 0 {
			headerCell.friendStatusLabel.text = "Online"
		}
		else {
			headerCell.friendStatusLabel.text = "Offline"
		}

		headerCell.friendsCountLabel.isHidden = true

		return headerCell
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 50.0)
	}
}
