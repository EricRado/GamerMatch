//
//  FriendRequestsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 11/24/20.
//  Copyright © 2020 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

final class FriendRequestsViewController: UIViewController {

	private var receivedFriendRequests = [FriendRequest]()
	private var pendingFriendRequests = [FriendRequest]()

	private let pendingFriendRequestString = "PendingFriendRequests/"

	private let friendRef: DatabaseReference = {
		return Database.database().reference().child("Friends/")
	}()
	
	private let friendRequestRef: DatabaseReference = {
		return Database.database().reference().child("FriendRequests/")
	}()

	private let receivedFriendRequestsRef: DatabaseReference? = {
		guard let id = Auth.auth().currentUser?.uid else { return nil }
		return Database.database().reference().child("ReceivedFriendRequests/\(id)/")
	}()

	private let pendingFriendRequestsRef: DatabaseReference? = {
		guard let id = Auth.auth().currentUser?.uid else { return nil }
		return Database.database().reference().child("PendingFriendRequests/\(id)/")
	}()

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView()
		collectionView.dataSource = self
		collectionView.delegate = self
		return collectionView
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

		getReceivedFriendRequests() { userCacheInfo, error in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let user = userCacheInfo else { return }
		}

		getPendingFriendRequests() { userCacheInfo, error in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let user = userCacheInfo else { return }
		}
    }

	fileprivate func getReceivedFriendRequests(completion: @escaping (UserCacheInfo?, Error?) -> Void) {
		receivedFriendRequestsRef?.observe(.childAdded, with: { (snapshot) in
			let id = snapshot.key

			FirebaseCalls.shared.getFriendRequest(for: id) { (friendRequest, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}

				guard let request = friendRequest else { return }
				guard let id = request.fromId else { return }
				guard let accepted = request.accepted?.toBool(), !accepted
					else { return }

				self.receivedFriendRequests.append(request)

//				self.tableView.beginUpdates()
//				let row = self.receivedFriendRequests.count - 1
//				self.receivedUserIdToCellRowDict[id] = row
//				self.tableView.insertRows(at: [IndexPath(row: row, section: 0)],
//										  with: .none)
//				self.tableView.endUpdates()

				FirebaseCalls.shared.getUserCacheInfo(for: id, completion: completion)

			}
		}, withCancel: { (error) in
			print(error.localizedDescription)
		})
	}

	fileprivate func getPendingFriendRequests(completion: @escaping (UserCacheInfo?, Error?) -> Void) {
		pendingFriendRequestsRef?.observe(.childAdded, with: { (snapshot) in
			let id = snapshot.key

			FirebaseCalls.shared.getFriendRequest(for: id) { [unowned self] (friendRequest, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}

				guard let request = friendRequest else { return }
				guard let id = request.toId else { return }
				self.pendingFriendRequests.append(request)

//				self.tableView.beginUpdates()
//				let row = self.pendingFriendRequests.count - 1
//				self.pendingUserIdToCellRowDict[id] = row
//				self.tableView.insertRows(at: [IndexPath(row: row, section: 1)],
//										  with: .none)
//				self.tableView.endUpdates()

				FirebaseCalls.shared.getUserCacheInfo(for: id, completion: completion)
			}
		}, withCancel: { (error) in
			print(error.localizedDescription)
		})
	}

}

extension FriendRequestsViewController: FriendRequestCellDelegate {
	func friendRequestCellDidTapAcceptButton(_ cell: FriendRequestCell) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		let friendRequest = receivedFriendRequests[indexPath.item]
		guard let fromId = friendRequest.fromId else { return }
		guard let toId = friendRequest.toId else { return }

		// insert new friend to user's frinds list
		let toRef = friendRef.child("\(toId)/")
		FirebaseCalls.shared
			.updateReferenceWithDictionary(ref: toRef, values: [fromId: "true"])

		// insert user's id to new friend's friends list
		let fromRef = friendRef.child("\(fromId)/")
		FirebaseCalls.shared
			.updateReferenceWithDictionary(ref: fromRef, values: [toId: "true"])

		// update friend request accepted field
		let requestRef = friendRequestRef.child("\(friendRequest.id!)/")
		FirebaseCalls.shared
			.updateReferenceWithDictionary(ref: requestRef, values: ["accepted": "true"])

		// remove friend request pending id from new friend's pending request list
		let path = "\(pendingFriendRequestString)\(fromId)/\(friendRequest.id!)"
		FirebaseCalls.shared.removeReferenceValue(at: path)

		// remove accepted friend request from table view

	}
}

extension FriendRequestsViewController: UICollectionViewDelegate {
}

extension FriendRequestsViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return section == 0 ? receivedFriendRequests.count : pendingFriendRequests.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: FriendRequestCell.identifier, for: indexPath)
				as? FriendRequestCell else { return UICollectionViewCell() }
		let (section, row) = (indexPath.section, indexPath.row)

		let friendRequest = section == 0 ? receivedFriendRequests[row] :
			pendingFriendRequests[row]
//		let user = section == 0 ? receivedFriendRequests[indexPath.item].

		if section == 0 {
//			cell.friendUsernameLabel.text = user?.username
			cell.delegate = self
		} else {
//			cell.friendUsernameLabel.text = user?.username
//			cell.acceptFriendRequestBtn.isHidden = true
		}

		return cell
	}
}
