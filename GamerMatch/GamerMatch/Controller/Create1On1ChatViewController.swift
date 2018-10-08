//
//  Create1On1ChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class Create1On1ChatViewController: CreateNewChatViewController {
    private var selectedUserId = ""
    private var selectedUsername: String?
    private var chat: Chat?
    private lazy var dbRef: DatabaseReference = {
        return Database.database().reference()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        navigationItem.title = "New Chat"
        print(existing1on1ChatUserIDToCache ?? [:])
    }
    
    fileprivate func transitionToSelectedChatVC() {
        let transitionVCId = "ChatSelectedVC"
        guard let vc = storyboard?
            .instantiateViewController(withIdentifier: transitionVCId)
            as? ChatSelectedViewController else { return }
        vc.chat = chat
        
        // pop the select users for new chat
        let navigationController = self.navigationController
        self.navigationController?.popToRootViewController(animated: false)
        
        // push selected chat VC to the top
        navigationController?.pushViewController(vc, animated: false)
        navigationController?.navigationBar.topItem?.title = selectedUsername
    }
    
    fileprivate func createChat() {
        guard let uid = User.onlineUser.uid else { return }
        guard let username = User.onlineUser.username else { return }
        let chatId = FirebaseCalls.shared.createANewUid(at: "Chats/")
        let message = "\(username) created a chat"
        let membersDict = [uid: "true", selectedUserId: "true"]
        
        let chat = Chat(id: chatId, creatorId: uid, isGroupChat: false, title: "",
                        members: membersDict, lastMessage: message)
        
        // upload chat to database
        let chatRef = dbRef.child("Chats/\(chatId)")
        chatRef.setValue(chat.toAnyObject()) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        // add chat ids to each user node who is in the chat
        for (key, value) in membersDict {
            let userRef = dbRef.child("UserChats/\(key)")
            FirebaseCalls.shared.updateReferenceList(ref: userRef,
                                                     values: [chatId: value])
        }
        
        self.chat = chat
        transitionToSelectedChatVC()
        
    }
    
    fileprivate func retrieveChat(at id: String) {
        let chatRef = dbRef.child("Chats/\(id)/")
        chatRef.observeSingleEvent(of: .value) { (snapshot) in
            print("This is the snapshot")
            print(snapshot)
            self.chat = Chat(snapshot: snapshot)
            self.transitionToSelectedChatVC()
        }
    }
}


extension Create1On1ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let friend = friends?[indexPath.row] else { return }
        selectedUserId = friend.uid!
        selectedUsername = friend.username
        
        // check if a chat exists with selected user
        let results = existing1on1ChatUserIDToCache?.filter { $1.uid == selectedUserId }
        
        if let arr = results , !arr.isEmpty {
            print("single chat already exists")
            // retrieve chat
            guard let chatId = arr.first?.key else { return }
            retrieveChat(at: chatId)
            
        } else {
            createChat()
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 7
    }
    
}
