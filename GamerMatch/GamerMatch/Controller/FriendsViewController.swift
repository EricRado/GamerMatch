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
        return Database.database().reference().child("Friends/")
    }()
    
    private let friendRequestRef: DatabaseReference = {
        return Database.database().reference().child("FriendRequests/")
    }()
    
    private let receivedFriendRequestsRef: DatabaseReference? = {
        guard let id = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference().child("ReceivedFriendRequests/\(id)")
    }()
    
    private let pendingFriendRequestsRef: DatabaseReference? = {
        guard let id = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference().child("PendingFriendRequests/\(id)")
    }()
    
    lazy var onlineFriends: [UserCacheInfo] = {
        var arr = [UserCacheInfo]()
        return arr
    }()
    
    lazy var offlineFriends: [UserCacheInfo] = {
        var arr = [UserCacheInfo]()
        return arr
    }()
    
    lazy var receivedFriendRequests: [FriendRequest] = {
        var arr = [FriendRequest]()
        return arr
    }()
    
    lazy var pendingFriendRequests: [FriendRequest] = {
        var arr = [FriendRequest]()
        return arr
    }()
    
    lazy var friendRequestUsersDict: [String: UserCacheInfo] = {
        var arr = [String: UserCacheInfo]()
        return arr
    }()
    
    lazy var taskIdsToIndexPathCVDict: [Int: (Int, Int)] = {
        var dict = [Int: (Int, Int)]()
        return dict
    }()
    
    lazy var taskIdsToIndexPathTVDict: [Int: (Int, Int)] = {
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
    
   
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: FriendRequestTableViewCell.identifier,
                            bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: FriendRequestTableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.insertSections([0, 1], with: .automatic)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: FriendCollectionViewHeader.identifier, bundle: nil)
            collectionView.register(
                nib,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: FriendCollectionViewHeader.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.addTarget(
                self,
                action: #selector(segmentedControlPressed(sender:)),
                for: .valueChanged)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        segmentedControl.selectedSegmentIndex = 0
       
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
        
        getReceivedFriendRequests() { userCacheInfo, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = userCacheInfo else { return }
            self.updateTableViewRow(with: user, section: 0)
        }
        
        getPendingFriendRequests() { userCacheInfo, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = userCacheInfo else { return }
            self.updateTableViewRow(with: user, section: 1)
        }
    }
    
    @objc fileprivate func segmentedControlPressed(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Friends control pressed")
            tableView.isHidden = true
            collectionView.isHidden = false
            
        case 1:
            print("Friend requests pressed")
            collectionView.isHidden = true
            tableView.isHidden = false
        default:
            break
        }
    }
    
    @objc func acceptFriendRequestBtnPressed(sender: UIButton) {
        let friendRequest = receivedFriendRequests[sender.tag]
        guard let fromId = friendRequest.fromId else { return }
        guard let toId = friendRequest.toId else { return }
        
        // insert new friend to user's frinds list
        guard let toRef = friendRef?.child("\(toId)/") else { return }
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: toRef, values: [fromId: "true"])
        
        // insert user's id to new friend's friends list
        guard let fromRef = friendRef?.child("\(fromId)/") else { return }
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: fromRef, values: [toId: "true"])
        
        // update friend request accepted field
        let requestRef = friendRequestRef.child("\(friendRequest.id!)/")
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: requestRef, values: ["accepted": "true"])
        
        // remove accepted friend request from table view
        receivedFriendRequests.remove(at: sender.tag)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)],
                             with: .right)
        tableView.endUpdates()
    }
    
    fileprivate func getUserFriends(completion: @escaping (() -> Void)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        friendRef?.child("\(uid)/").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
            var counter = 0
            for child in snapshots {
                let id = child.key

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
                    if counter == snapshots.count { completion() }
                })
                counter += 1
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    fileprivate func updateTableViewRow(with user: UserCacheInfo, section: Int) {
        self.friendRequestUsersDict[user.id!] = user
        let row: Int
        if section == 0 {
            row = self.receivedFriendRequests.count - 1
        } else {
            row = self.pendingFriendRequests.count - 1
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
    }
    
    fileprivate func getReceivedFriendRequests(completion:
        @escaping (UserCacheInfo?, Error?) -> Void) {
        receivedFriendRequestsRef?.observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            FirebaseCalls.shared.getFriendRequest(for: id) { (friendRequest, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let request = friendRequest else { return }
                guard let accepted = request.accepted?.toBool(), !accepted
                    else { return }
                
                self.receivedFriendRequests.append(request)
                
                self.tableView.beginUpdates()
                let row = self.receivedFriendRequests.count - 1
                self.tableView.insertRows(at: [IndexPath(row: row, section: 0)],
                                          with: .none)
                self.tableView.endUpdates()
                
                guard let id = request.fromId else { return }
                FirebaseCalls.shared.getUserCacheInfo(for: id, completion: completion)
                
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    fileprivate func getPendingFriendRequests(completion:
        @escaping (UserCacheInfo?, Error?) -> Void) {
        pendingFriendRequestsRef?.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            let id = snapshot.key
            FirebaseCalls.shared.getFriendRequest(for: id) { [unowned self] (friendRequest, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let request = friendRequest else { return }
                self.pendingFriendRequests.append(request)
                
                self.tableView.beginUpdates()
                let row = self.pendingFriendRequests.count - 1
                self.tableView.insertRows(at: [IndexPath(row: row, section: 1)],
                                          with: .none)
                self.tableView.endUpdates()
                
                guard let id = request.toId else { return }
                FirebaseCalls.shared.getUserCacheInfo(for: id, completion: completion)
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
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
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
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
        
        if let url = friend.url, url != "" {
            let id = mediaManager .downloadImage(from: url)
            guard let taskId = id else { return cell }
            taskIdsToIndexPathCVDict[taskId] = (indexPath.item, indexPath.section)
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



extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row pressed")
    }
}



extension FriendsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return receivedFriendRequests.count
        } else {
            return pendingFriendRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestTableViewCell.identifier, for: indexPath)
            as? FriendRequestTableViewCell else { return UITableViewCell() }
        let (section, row) = (indexPath.section, indexPath.row)
        
        let friendRequest = section == 0 ? receivedFriendRequests[row] :
            pendingFriendRequests[row]
        cell.friendImageView.image = UIImage(named: "noAvatarImg")
       
        if section == 0 {
            cell.friendUsernameLabel.text =
                friendRequestUsersDict[friendRequest.fromId!]?.username
            cell.acceptFriendRequestBtn.tag = row
            cell.acceptFriendRequestBtn.addTarget(
                self,
                action: #selector(acceptFriendRequestBtnPressed(sender:)),
                for: .touchUpInside)
        } else {
            cell.friendUsernameLabel.text =
                friendRequestUsersDict[friendRequest.toId!]?.username
            cell.acceptFriendRequestBtn.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Received Friend Requests"
        } else {
            return "Pending Friend Requests"
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 6
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
        -> CGFloat {
        return 50.0
    }
}

extension FriendsViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                guard let (row, section) = self.taskIdsToIndexPathCVDict[taskId]
                    else { return }
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






















