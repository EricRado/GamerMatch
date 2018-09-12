//
//  ChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/7/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    
    let chatRef: DatabaseReference = {
        return Database.database().reference().child("Chats/")
    }()
    
    let userCacheInfoRef: DatabaseReference = {
        return Database.database().reference().child("UserCacheInfo/")
    }()
    
    /* - chats - stores all of the user's chats meta data
       - chatParticipantDict - stores array of chat's participants ids, keyed to the chat id
       - chatUsers - stores all 1on1 chats participant username and avatar picture
    */
    
    var chats = [Chat]()
    var chatImageDict = [String: UIImage]()
    var chat1on1TitleDict = [String: String]()
    
    // selected chat information to pass to ChatSelectedViewController
    var selectedChat: Chat?
    var selectedParticipantIds = [String: String]()
    var selectedChatUser: ChatUserDisplay?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        getUserChatsDetails()
        
    }
    
    func getUserChatsDetails(){
        guard let dict = User.onlineUser.chatIds else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for (key, _) in dict {
            chatRef.child("\(key)/").observe(.value, with: { (snapshot) in
                let chat = Chat(snapshot: snapshot)
                guard chat != nil else { return }
                
                self.chats.append(chat!)
                if (chat?.isGroupChat)! {
                    print(chat?.lastMessage)
                } else {
                    for (key, _) in (chat?.members)! {
                        if key != userId {
                            self.getUsernameAndPic(id: String(key), chatId: (chat?.id)!)
                        }
                    }
                }
                self.chatTableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func getUsernameAndPic(id: String, chatId: String){
       
        let userInfoRef = userCacheInfoRef.child("\(id)/")
        
        userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dict = snapshot.value as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                let userCacheInfo = try JSONDecoder().decode(UserCacheInfo.self, from: jsonData)
                self.chat1on1TitleDict[chatId] = userCacheInfo.username
                print(userCacheInfo)
            } catch let error {
                print(error)
            }
            self.chatTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            let vc = segue.destination as! ChatSelectedViewController
            
            // if the chat is 1on1 set title for message log screen to user's
            // username else to group chat's title
            if let user = selectedChatUser {
                vc.navigationItem.title = user.username
                vc.selectedChatUser = user
            }else {
                vc.navigationItem.title = selectedChat?.title
            }
            
            // send chat meta data and participant ids to message log screen
            vc.chat = selectedChat
            vc.participantIds = selectedParticipantIds
            
            // reset selectedChatUser
            selectedChatUser = nil
        }
    }
}


extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        
        selectedChat = chat
        selectedParticipantIds = chat.members!
        
        // this is a 1on1 chat get user's username and avatar pic
        if selectedParticipantIds.count == 2 {
            let userId = chat.members?.filter({$0.key != Auth.auth().currentUser?.uid}).first?.key
            if let userId = userId, let username = chat1on1TitleDict[userId],
                let image = chatImageDict[userId]{
                selectedChatUser = ChatUserDisplay(username: username, image: image)
            }
        }
        
        performSegue(withIdentifier: "chatSegue", sender: self)
        
        chatTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return chatTableView.rowHeight
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
        let chat = chats[indexPath.row]
        
        if let title = chat.title, title != "" {
            cell.chatUsernameLabel.text = title
        } else {
            cell.chatUsernameLabel.text = chat1on1TitleDict[chat.id!]
        }
        
        if let message = chat.lastMessage {
            cell.lastMessageLabel.text = message
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
}




























