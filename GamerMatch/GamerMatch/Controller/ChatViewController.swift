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
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration
            .background(withIdentifier: "chatVCBgSessionConfiguration")
        let session = URLSession(configuration: configuration,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()
    
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
    
    var chats: [Chat]?
    var chatsAlreadyDisplayed = [String: Int]()
    var chatImageDict = [String: UIImage]()
    var chat1on1TitleDict = [String: UserCacheInfo]()
    var taskIdToCellRowAndChatIdDict = [Int: (Int,String)]()
    
    // selected chat information to pass to ChatSelectedViewController
    var selectedChat: Chat?
    var selectedParticipantIds = [String: String]()
    var selectedChatUser: ChatUserDisplay?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chats = [Chat]()
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        ImageManager.shared.downloadSession = downloadSession
        
        getUserChatsDetails { (chats, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.chats = chats
            self.chatTableView.reloadData()
        }
        
    }
    
    fileprivate func updateChatRow(at id: String, chat: Chat) {
        guard let index = self.chatsAlreadyDisplayed[id] else { return }
        
        chats?[index] = chat
        chatTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func getUserChatsDetails(completion: @escaping ([Chat]?, Error?) -> Void){
        guard let dict = User.onlineUser.chatIds else { return }
        var counter = 0
        var chats = [Chat]()
        
        for (key, _) in dict {
            chatRef.child("\(key)/").observe(.value, with: { (snapshot) in
                guard let chat = Chat(snapshot: snapshot) else { return }
                guard let id = chat.id else { return }
                
                // if chat was updated reload the cell with the latest data
                if self.chatsAlreadyDisplayed[id] != nil {
                    self.updateChatRow(at: id, chat: chat)
                    return
                }
                
                chats.append(chat)
                self.chatsAlreadyDisplayed[id] = chats.count - 1
                
                if !(chat.isGroupChat)! {
                    self.getUserInfo(membersDict: chat.members, chatId: chat.id) {
                        self.updateChatRow(at: id, chat: chat)
                    }
                }
                
                counter += 1
                
                if counter == dict.count {
                    completion(chats, nil)
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserInfo(membersDict: [String: String]?, chatId: String?, completion: @escaping () -> Void){
        guard let dict = membersDict else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        var friendId: String?
        
        for (key, _) in dict {
            if key != userId {
                friendId = key
            }
        }
        
        FirebaseCalls.shared.getUserCacheInfo(for: friendId) { (userCacheInfo, error) in
            if let error = error {
                print(error)
            } else {
                self.chat1on1TitleDict[chatId!] = userCacheInfo
                completion()
            }
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
        guard let chat = chats?[indexPath.row] else { return }
        
        selectedChat = chat
        selectedParticipantIds = chat.members!
        
        // this is a 1on1 chat get user's username and avatar pic
        if selectedParticipantIds.count == 2 {
            if let user = chat1on1TitleDict[chat.id!], let image = chatImageDict[chat.id!] {
               selectedChatUser = ChatUserDisplay(username: user.username!, image: image)
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
        guard let chat = chats?[indexPath.row] else { return cell }
        
        if let title = chat.title, title != "" {
            cell.chatUsernameLabel.text = title
        } else {
            cell.chatUsernameLabel.text = chat1on1TitleDict[chat.id!]?.username
        }
        
        if let message = chat.lastMessage {
            cell.lastMessageLabel.text = message
        }
        
        // image was downloaded and stored to the dictionary
        if let image = chatImageDict[chat.id!] {
            cell.chatUserPic.image = image
            return cell
        }
        
        // if image was not downloaded create a background download task
        let urlString = chat.isGroupChat! ? chat.urlString : chat1on1TitleDict[chat.id!]?.avatarURL
        if let urlString = urlString, !urlString.isEmpty {
            if let taskIdentifier = ImageManager.shared.downloadImage(from: urlString) {
                taskIdToCellRowAndChatIdDict[taskIdentifier] = (indexPath.row, chat.id!)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chats = chats {
            return chats.count
        }
        return 0
    }
    
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
}

extension ChatViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                if let (index, chatId) = self.taskIdToCellRowAndChatIdDict[taskId] {
                    let image = UIImage(data: data)
                    self.chatImageDict[chatId] = image
                    self.chatTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}


























