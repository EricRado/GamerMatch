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
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration
            .background(withIdentifier: "FriendVCBgSessionConfiguration")
        let session = URLSession(configuration: configuration,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()
    
    lazy var mediaManager: ImageManager = {
        let manager = ImageManager(downloadSession: downloadSession)
        return manager
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
        guard let friendIds = User.onlineUser.friendsIds else { return }
        let dictCount = friendIds.count
        var counter = 0
        
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
                if counter == dictCount {
                    completion()
                }
            }
            counter += 1
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
        
        if let url = friend.avatarURL, url != "" {
            let id = mediaManager.downloadImage(from: url)
            guard let taskId = id else { return cell }
            taskIdsToIndexPathRowDict[taskId] = (indexPath.item, indexPath.section)
        }
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
        else {
            headerCell.friendStatusLabel.text = "Offline"
        }
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
}

extension FriendsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                guard let (row, section) = self.taskIdsToIndexPathRowDict[taskId] else { return }
                let indexPath = IndexPath(row: row, section: section)
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? FriendCollectionViewCell else { return }
                let image = UIImage(data: data)
                cell.friendImageView.image = image
            }
        } catch let error {
            print(error)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}






















