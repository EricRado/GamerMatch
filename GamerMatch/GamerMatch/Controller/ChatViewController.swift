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
    
    /* - chats - stores all of the user's chats meta data
       - chatParticipantDict - stores chat's participants ids, keyed to the chat id
       - chatUsers - stores all 1on1 chats participant username and avatar picture
    */
    
    var chats = [Chat]()
    var chatParticipantDict = [String: [String]]()
    var chatUsers = Set<ChatUserDisplay>()
    
    // selected chat information to pass to ChatSelectedViewController
    var selectedChat: Chat?
    var selectedParticipantIds = [String]()
    var selectedChatUser: ChatUserDisplay?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        print(User.onlineUser.chatIds)
        
        //getUserChatsId()
        
    }
    
    
    func getUserChatsId(){
        guard userChatsRef != nil else { return }
        
        userChatsRef?.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                self.getChatDetails(chatId: child.key)
                self.getParticipantsId(chatId: child.key)
            }
        }
    }
    
    func getChatDetails(chatId: String){
        
        var creatorId = ""
        var id = ""
        var isGroupChat = false
        var title = ""
        var lastMessage = ""
        
        chatRef.child("\(chatId)/").observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                if let unwrapCreatorId = dict["creatorId"] as? String {
                    creatorId = unwrapCreatorId
                }
                if let unwrapId = dict["id"] as? String {
                    id = unwrapId
                }
                if let unwrapIsGroupChat = dict["isGroupChat"] as? String {
                    isGroupChat = unwrapIsGroupChat.toBool()!
                }
                if let unwrapTitle = dict["title"] as? String {
                    title = unwrapTitle
                }
                if let unwrapLastMessage = dict["lastMessage"] as? String {
                    lastMessage = unwrapLastMessage
                }
                self.chats.append(Chat(id: id, creatorId: creatorId,
                                       isGroupChat: isGroupChat, title: title, lastMessage: lastMessage))
            }
        }
    }
    
    func getParticipantsId(chatId: String){
        let chatMemberRef = chatRef.child(chatId).child("members")
     
        chatMemberRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if child.key != Auth.auth().currentUser?.uid {
                    
                    /* modify so it only runs for 1on1 chats */
                    self.getUsernameAndPic(id: child.key, chatId: chatId)
                }
            }
        }
    }
    
    func getUsernameAndPic(id: String, chatId: String){
        var username: String = ""
        var avatarURL: String = ""
       
        let userPicURL = Database.database().reference().child("Users/").child(id)
        
        userPicURL.observeSingleEvent(of: .value) { (snapshot) in
            // get the username and img url from the participant id
            if let dict = snapshot.value as? [String: Any]{
                username = (dict["username"] as? String)!
                if let imgURL = dict["avatarURL"] as? String{
                    avatarURL = imgURL
                }
                let chatUserDisplay = ChatUserDisplay(id: id, username: username, avatarURL: avatarURL)
                if !self.chatUsers.contains(chatUserDisplay) {
                    self.chatUsers.insert(chatUserDisplay)
                }
                
                var list = self.chatParticipantDict[chatId] ?? []
                list.append(id)
                self.chatParticipantDict[chatId] = list
                
                print(self.chatUsers)
                print(self.chatParticipantDict)
            }
            self.chatTableView.reloadData()
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
        let selectedChatId = chats[indexPath.row].id
        
        selectedChat = chats[indexPath.row]
        selectedParticipantIds = chatParticipantDict[selectedChatId!]!
        
        // this is a 1on1 chat get user's username and avatar pic
        if selectedParticipantIds.count == 1 {
            let user = chatUsers.filter({$0.id == selectedParticipantIds[0]})
            selectedChatUser = user.first
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
        
        let chatCell = chats[indexPath.row]
        
        if let chatDict = chatParticipantDict[chatCell.id!] {
            print("THIS IS CHATDICT...")
            print(chatDict)
            if chatDict.count >= 2 {
                print("This is a group chat...")
                if let title = chatCell.title {
                    cell.chatUsernameLabel.text = title
                }
            }else {
                print("This is a 1on1 chat...")
                let user = chatUsers.filter({$0.id == chatDict[0]})
                cell.chatUsernameLabel.text = user.first?.username
            }
            cell.lastMessageLabel.text = chats[indexPath.row].lastMessage
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatParticipantDict.count
    }
    
}




























