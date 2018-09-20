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
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.dataSource = self
            chatTableView.delegate = self
        }
    }
    
    private let createNewChatVCId = "CreateNewChatVC"
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration
            .background(withIdentifier: "chatVCBgSessionConfiguration")
        let session = URLSession(configuration: configuration,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()
    
    lazy var mediaManager: ImageManager = {
        let manager = ImageManager(downloadSession: downloadSession)
        return manager
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
    var chatsAlreadyDisplayedToCellRow = [String: Int]()
    var chatImageDict = [String: UIImage]()
    var chat1on1TitleDict = [String: UserCacheInfo]()
    var taskIdToCellRowAndChatIdDict = [Int: (Int,String)]()
    
    // selected chat information to pass to ChatSelectedViewController
    var selectedChat: Chat?
    var selectedChatUser: ChatUserDisplay?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chats = [Chat]()
        setupBarButtonItems()
        getUserChatsDetails()
    }
    
    
    fileprivate func setupBarButtonItems() {
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add,
                                           target: self,
                                           action: #selector(addButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = addBarButton
        
        let newGroupButton = UIBarButtonItem(title: "New Group",
                                             style: .plain,
                                             target: self,
                                             action: #selector(newGroupButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = newGroupButton
    }
    
    @objc func addButtonPressed(sender: UIBarButtonItem) {
        guard let vc = storyboard?
            .instantiateViewController(withIdentifier: createNewChatVCId) as? CreateNewChatViewController else { return }
        vc.downloadSessionId = "CreateGroupChatVCBgConfig"
        object_setClass(vc, Create1On1ChatViewController.self)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func newGroupButtonPressed(sender: UIBarButtonItem) {
        guard let vc = storyboard?
            .instantiateViewController(withIdentifier: createNewChatVCId) as? CreateNewChatViewController else { return }
        vc.downloadSessionId = "Create1On1ChatVCBgConfig"
        object_setClass(vc, CreateGroupChatViewController.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func updateChatRow(at id: String, chat: Chat) {
        guard let index = self.chatsAlreadyDisplayedToCellRow[id] else { return }
        
        chats?[index] = chat
        chatTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    fileprivate func insertChatToTableView(_ chat: Chat) {
        chats?.append(chat)
        let row = (chats?.count)! - 1
        chatsAlreadyDisplayedToCellRow[chat.id!] = row
        chatTableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
    func getUserChatsDetails(){
        guard let dict = User.onlineUser.chatIds else { return }
   
        for (key, _) in dict {
            chatRef.child("\(key)/").observe(.value, with: { (snapshot) in
                guard let chat = Chat(snapshot: snapshot) else { return }
                guard let id = chat.id else { return }
                
                // if chat was updated reload the cell with the latest data
                if self.chatsAlreadyDisplayedToCellRow[id] != nil {
                    self.updateChatRow(at: id, chat: chat)
                    return
                }
                
                self.insertChatToTableView(chat)
                
                if !(chat.isGroupChat)! {
                    self.getUserInfo(membersDict: chat.members, chatId: chat.id) {
                        self.updateChatRow(at: id, chat: chat)
                    }
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
            guard let chat = selectedChat else { return }
            
            // if the chat is 1on1 set title for message log screen to user's
            // username else to group chat's title
            if let user = selectedChatUser {
                vc.navigationItem.title = user.username
                vc.selectedChatUser = user
            } else {
                vc.navigationItem.title = chat.title
            }
            
            // if chat has an image pass it to the next VC
            if let img = chatImageDict[chat.id!] {
                vc.image = img
            }
            
            // send chat meta data and participant ids to message log screen
            vc.chat = chat
            
            // reset selectedChatUser
            selectedChatUser = nil
        }
    }
}


extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chat = chats?[indexPath.row] else { return }
        
        selectedChat = chat
        
        // this is a 1on1 chat get user's username and avatar pic
        if (chat.isGroupChat)! {
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
            if let taskIdentifier = mediaManager.downloadImage(from: urlString) {
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


























