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
    var participantIds = [String]()
    
    
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
            self.chatTableView.reloadData()
        }
    }
    
    func getParticipantsId(chatId: String){
        let participantsRef = dbRef.child("Participants/\(chatId)").child("usersId")
        participantsRef.observeSingleEvent(of: .value, with: {(snapshot) in
            print(snapshot)
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                print("Participant id...")
                print(child.key)
                if child.key != Auth.auth().currentUser?.uid {
                    self.participantIds.append(child.key)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! chatTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "chatSegue", sender: self)
    }


}
