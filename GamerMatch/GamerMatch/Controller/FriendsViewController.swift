//
//  FriendsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase


class FriendsViewController: UIViewController {
    
    private let cellId = "friendCell"
    private let onlineSectionId = 0
    private let offlineSectionId = 1
    
    private let friendRef: DatabaseReference? = {
        guard let id = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference().child("Friends/\(id)/")
    }()
    
    lazy var onlineFriends: [UserCacheInfo] = {
        var arr = [UserCacheInfo]()
        return arr
    }()
    
    lazy var offlineFriends: [UserCacheInfo] = {
        var arr = [UserCacheInfo]()
        return arr
    }()
    
    lazy var taskIdsToIndexPathRowDict: [Int: (Int, Int)] = {
        var dict = [Int: (Int, Int)]()
        return dict
    }()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: FriendCollectionViewHeader.identifier, bundle: nil)
        collectionView.register(nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: FriendCollectionViewHeader.identifier)
        getUserFriends()
    }
    
    fileprivate func getUserFriends() {
        guard let friendIds = User.onlineUser.friendsIds else { return }
        
        for (id, _) in friendIds {
            FirebaseCalls.shared.getUserCacheInfo(for: id) { (userCacheInfo, error) in
                if let error = error {
                    print(error.localizedDescription)
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
            }
        }
    }

}

extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension FriendsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return onlineFriends.count
        } else {
            return offlineFriends.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCollectionViewCell
        let friend = indexPath.section == onlineSectionId ? onlineFriends[indexPath.item] : offlineFriends[indexPath.item]
        
        cell.friendUsernameLabel.text = friend.username
        cell.friendImageView.image = UIImage(named: "noAvatarImg")
        
        return cell
    }
}

extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerCell = collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                              withReuseIdentifier: FriendCollectionViewHeader.identifier,
                                              for: indexPath) as! FriendCollectionViewHeader
        if indexPath.section == 0 {
            headerCell.friendStatusLabel.text = "Online"
        }
        /*else {
            headerCell.friendStatusLabel.text = "Offline"
        }*/
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
}
























