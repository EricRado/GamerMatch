//
//  NewGroupChatSetupViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

final class NewGroupChatSetupViewController: UIViewController, UITextViewDelegate,
    UINavigationControllerDelegate {
    let cellId = "friendCell"
    let headerId = "headerCell"
    let destVCId = "ChatSelectedVC"
    
    let chatRef: DatabaseReference = {
        return Database.database().reference().child("Chats/")
    }()
    let userChatsRef: DatabaseReference = {
        return Database.database().reference().child("UserChats/")
    }()
    
    var selectedUsers: [UserCacheInfo]?
    var selectedUsersIdToUIImage: [String: UIImage]?
    var chat: Chat?
    var groupImage: UIImage?
    
    @IBOutlet weak var addPhotoBtn: UIButton! {
        didSet {
            addPhotoBtn.addTarget(self,
                                  action: #selector(addPhotoBtnPressed(sender:)),
                                  for: .touchUpInside)
            addPhotoBtn.layer.cornerRadius = addPhotoBtn.frame.height / 2.0
            addPhotoBtn.clipsToBounds = true
        }
    }
    @IBOutlet weak var groupTitleTextView: UITextView! {
        didSet {
            groupTitleTextView.delegate = self
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let cellNib = UINib(nibName: FriendCollectionViewCell.identifier, bundle: nil)
            collectionView.register(cellNib, forCellWithReuseIdentifier: cellId)
            
            let headerNib = UINib(nibName: FriendCollectionViewHeader.identifier,
                                  bundle: nil)
            collectionView
                .register(headerNib,
                          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                          withReuseIdentifier: headerId)
            
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
    
    fileprivate func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("This device has no access to photo library")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func uploadToDatabase(chat: Chat, at ref: DatabaseReference) {
        ref.setValue(chat.toAnyObject()) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        guard let members = chat.members else { return }
        // add chat ids to each user node who is in the group chat
        for (key, value) in members {
            let chatIdsUserRef = userChatsRef.child("\(key)/")
            FirebaseCalls.shared.updateReferenceList(ref: chatIdsUserRef,
                                                     values: [chat.id!: value])
        }
    }
    
    fileprivate func createChat(with title: String) {
        let newRef = chatRef.childByAutoId()
        let id = newRef.key
        let message = "\(User.onlineUser.username ?? "") created group chat."
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // transform the selected members to dictionary which contains {memberId : true}
        let dict = selectedUsers?.reduce(into: [String: String]()) {
            $0[$1.uid!] = "true"
        }
        guard var members = dict else { return }
        members[userId] = "true"
        let chat = Chat(id: id, creatorId: userId, isGroupChat: true,
                        title: title, members: members, lastMessage: message)
        self.chat = chat
        uploadToDatabase(chat: chat, at: newRef)
    }
    
    func createAlert() {
        let ac = UIAlertController(title: "Empty Text Field",
                                   message: "Please enter a name for this group",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss",
                                   style: .cancel,
                                   handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    fileprivate func transitionToSelectedChatVC() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: destVCId)
            as? ChatSelectedViewController else { return }
        vc.chat = self.chat
        
        // pop the select users for new chat and group chat setup VCs
        let navigationController = self.navigationController
        self.navigationController?.popToRootViewController(animated: false)
        
        // push selected chat VC to the top
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func createPressed(sender: UIBarButtonItem) {
        
        self.transitionToSelectedChatVC()
        
        // verify group title was set
        guard !groupTitleTextView.text.isEmpty else {
            createAlert()
            return
        }
        SVProgressHUD.show(withStatus: "Creating Group Chat")
        guard let title = groupTitleTextView.text else { return }
        createChat(with: title)
       
        // verify if photo was selected
        guard let image = groupImage else {
            transitionToSelectedChatVC()
            return
        }
        guard let createdChat = chat else { return }
        
        // upload image if selected
        let manager = ImageManager()
        manager.uploadImage(image: image,
            at: "groupProfileImages/\(createdChat.id!).jpg") {
                [unowned self] (urlString, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let url = urlString else { return }
            FirebaseCalls.shared.updateReferenceWithDictionary(
                ref: self.chatRef.child("\(createdChat.id!)"),
                values: ["url": url])
            print("Finish all uploads")
            SVProgressHUD.dismiss()
            self.transitionToSelectedChatVC()
        }
    }
    
    @objc func addPhotoBtnPressed(sender: UIButton) {
        openPhotoLibrary()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}

extension NewGroupChatSetupViewController: UIImagePickerControllerDelegate{
    @objc func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        
        // get the image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Image was not retrieved")
            return
        }
        groupImage = image
        addPhotoBtn.setImage(image, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
        print("Running cell for item at ")
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            as? FriendCollectionViewCell else { return UICollectionViewCell() }
        guard let friend = selectedUsers?[indexPath.row] else { return cell }
        let image = selectedUsersIdToUIImage?[friend.uid!] ??
            UIImage(named: "noAvatarImg")
        
        cell.friendUsernameLabel.text = friend.username
        cell.friendImageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}






















