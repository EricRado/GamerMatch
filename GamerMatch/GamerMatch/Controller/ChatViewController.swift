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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        getUserChatsId()
        
    }
    
    func getUserChatsId(){
        let chatsRef = dbRef.child("Users").child((Auth.auth().currentUser?.uid)!).child("chatIds")
        chatsRef.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                print("Chat id...")
                print(child.key)
                self.chatIds.append(child.key)
                self.getParticipantsId(chatId: child.key)
            }
        }
    }
    
    func getParticipantsId(chatId: String){
        let participantsRef = dbRef.child("Participants/\(chatId)").child("usersId")
        let count = participantIds.count
        participantsRef.observeSingleEvent(of: .value, with: {(snapshot) in
            print(snapshot)
            
            // check if the chat is a group or 1on1 chat
            let isGroupChat = (snapshot.childrenCount - 1) > 1
            print("This is childCount: \(snapshot.childrenCount)")
            print(isGroupChat)
            self.participantIds.append([])
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                print("Participant id...")
                print(child.key)
                if child.key != Auth.auth().currentUser?.uid {
                    self.participantIds[count].append(child.key)
                }
                if !isGroupChat {
                    self.getUsernameAndPic(id: child.key)
                }
               
            }
            self.chatTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUsernameAndPic(id: String) -> String {
        var username: String = ""
        let usernameRef = dbRef.child("Users/").child(id).child("username")
        
        
        // retrieve the username and the user avatar pic with the parameter id
        usernameRef.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            username = snapshot.value as! String
        }
        
        return username
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! chatTableViewCell
        var username = ""
        
        if participantIds[indexPath.row].count >= 2 {
            print("This is a group chat...")
        }else {
            print("This is a 1on1 chat...")
            cell.chatUsernameLabel.text = username
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "chatSegue", sender: self)
    }


}
