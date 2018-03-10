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
    var chatIds = [String]()
    var participantIds = [[String]]()
    var chatUsers = [ChatUserDisplay]()
    
    
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
                print("Chat id...")
                print(child.key)
                self.chatIds.append(child.key)
                self.getParticipantsId(chatId: child.key)
            }
        }
    }
    
    func getParticipantsId(chatId: String){
        print("This is chatId: \(chatId)")
        let chatRef = dbRef.child("Chats").child(chatId).child("members")
        /* COUNTTTTT */
        let count = participantIds.count
        chatRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                print(child.key)
                self.participantIds.append([])
                if child.key != Auth.auth().currentUser?.uid {
                    self.participantIds[count].append(child.key)
                    self.getUsernameAndPic(id: child.key)
                }
            }
            
        }
    }
    
    func getUsernameAndPic(id: String){
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
                self.chatUsers.append(ChatUserDisplay(id: id, username: username, avatarURL: avatarURL))
                print(self.chatUsers)
            }
            self.chatTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! chatTableViewCell
        
        if participantIds[indexPath.row].count >= 2 {
            print("This is a group chat...")
        }else {
            print("This is a 1on1 chat...")
            let user = chatUsers.filter({$0.id == participantIds[indexPath.row][0]})
            cell.chatUsernameLabel.text = user[0].username 
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "chatSegue", sender: self)
    }


}
