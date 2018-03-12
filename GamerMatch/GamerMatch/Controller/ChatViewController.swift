//
//  ChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/7/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatTableView: UITableView!
    
    let dbRef = Database.database().reference()
    
    var chats = [Chat]()
    var chatParticipantDict = [String: [String]]()
    
    // SET
    var chatUsers = Set<ChatUserDisplay>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        getUserChatsId()
        
    }
    
    func getUserChatsId(){
        let userChatsRef = dbRef.child("Users").child((Auth.auth().currentUser?.uid)!).child("chatIds")
        userChatsRef.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                self.getChatDetails(chatId: child.key)
                self.getParticipantsId(chatId: child.key)
            }
        }
    }
    
    func getChatDetails(chatId: String){
        let chatRef = dbRef.child("Chats").child(chatId)
        
        var creatorId = ""
        var id = ""
        var isGroupChat = false
        var title = ""
        
        chatRef.observe(.value) { (snapshot) in
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
                self.chats.append(Chat(id: id, creatorId: creatorId,
                                    isGroupChat: isGroupChat, title: title))
            }
        }
    }
    
    func getParticipantsId(chatId: String){
        let chatMemberRef = dbRef.child("Chats").child(chatId).child("members")
     
        chatMemberRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if child.key != Auth.auth().currentUser?.uid {
                    self.getUsernameAndPic(id: child.key, chatId: chatId)
                }
            }
        }
    }
    
    func getUsernameAndPic(id: String, chatId: String){
        var username: String = ""
        var avatarURL: String = ""
       
        let userPicURL = dbRef.child("Users/").child(id)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatParticipantDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! chatTableViewCell
        
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "chatSegue", sender: self)
        
        chatTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("Table view height...")
        print(chatTableView.rowHeight)
        return chatTableView.rowHeight
    }


}
