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
    var selectedUsers: [UserCacheInfo]?
    var selectedUsersIdToUIImage: [String: UIImage]?
    var groupTitle: String?
    
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var groupTitleTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: FriendCollectionViewCell.identifier, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: cellId)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let create = UIBarButtonItem(title: "Create", style: .plain, target: self,
            action: #selector(createPressed(sender:)))
        navigationItem.rightBarButtonItem = create
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
        return selectedUsers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}

extension NewGroupChatSetupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3,
                      height: collectionView.frame.height / 3)
    }
}






















