//
//  NewGroupChatSetupViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

final class NewGroupChatSetupViewController: UIViewController {
    let cellId = "friendCell"
    let headerId = "headerCell"
    var selectedUsers: [UserCacheInfo]?
    var selectedUsersIdToUIImage: [String: UIImage]?
    var groupTitle: String?
    
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var groupTitleTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let cellNib = UINib(nibName: FriendCollectionViewCell.identifier, bundle: nil)
            collectionView.register(cellNib, forCellWithReuseIdentifier: cellId)
            
            let headerNib = UINib(nibName: FriendCollectionViewHeader.identifier,
                                  bundle: nil)
            collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: headerId)
            
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let create = UIBarButtonItem(title: "Create", style: .plain, target: self,
            action: #selector(createPressed(sender:)))
        navigationItem.rightBarButtonItem = create
        navigationItem.title = "Setup"
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func createPressed(sender: UIBarButtonItem) {
        groupTitle = groupTitleTextView.text
        print(groupTitle ?? "noTitle")
    }

}

extension NewGroupChatSetupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension NewGroupChatSetupViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        print(selectedUsers?.count ?? 0)
        return selectedUsers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Running cell for item at ")
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            as? FriendCollectionViewCell else { return UICollectionViewCell() }
        guard let friend = selectedUsers?[indexPath.row] else { return cell }
        let image = selectedUsersIdToUIImage?[friend.id!] ??
            UIImage(named: "noAvatarImg")
        
        cell.friendUsernameLabel.text = friend.username
        cell.friendImageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerCell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: headerId,
            for: indexPath) as! FriendCollectionViewHeader
        
        headerCell.friendStatusLabel.text = "Participants: \(selectedUsers?.count ?? 0) of 256 "
        headerCell.friendsCountLabel.isHidden = true
        
        return headerCell
    }
}

extension NewGroupChatSetupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3,
                      height: collectionView.frame.height / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}






















