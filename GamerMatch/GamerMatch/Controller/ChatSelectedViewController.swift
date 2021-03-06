//
//  ChatSelectedViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/9/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatSelectedViewController: UIViewController, UIGestureRecognizerDelegate {
    private let cellId = "messageCell"
    private let chatMetaDataVCId = "DisplayChatMetaDataVC"
    var chat: Chat?
    var messages = [Message]()
    var image: UIImage?
    var chatTitle: String?
    
    lazy var messagesRef: DatabaseReference? = {
        if let id = self.chat?.id {
           return Database.database().reference().child("Messages/\(id)/")
        }
        return nil
    }()
    
    lazy var chatRef: DatabaseReference? = {
        if let id = self.chat?.id {
            return Database.database().reference().child("Chats/\(id)/")
        }
        return nil
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: UIControlState())
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        
        return button
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // add notification observers to handle keyboard display when typing message
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        navigationItem.title = chatTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        
        setupCollectionView()
    
        setSettingsButton()
        
        // setup message field and send button
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        collectionView.bottomAnchor
            .constraint(equalTo: messageInputContainerView.topAnchor, constant: 0).isActive = true
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        getMessages()
    }
    
    fileprivate func setSettingsButton() {
        guard let isGroupChat = chat?.isGroupChat else { return }
        if isGroupChat {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Settings", style: .plain, target: self,
                action: #selector(settingsPressed(sender:)))
        }
    }
    
    @objc func settingsPressed(sender: UIBarButtonItem) {
        guard let vc = storyboard?
            .instantiateViewController(withIdentifier: chatMetaDataVCId)
            as? DisplayChatMetaDataViewController else { return }
        vc.chat = chat
        vc.groupImage = image
        navigationItem.title = ""
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        let p = touch.location(in: view)
        if collectionView.frame.contains(p) {
            return true
        }
        return false
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(ChatMessageCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.leadingAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
    }
    
    fileprivate func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]|", views: topBorderView)
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                if isKeyboardShowing {
                    if self.messages.count != 0 {
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    fileprivate func getMessages() {
        guard messagesRef != nil else { return }
        
        messagesRef?.queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else {return}
            print(dict)
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                let message = try JSONDecoder().decode(Message.self, from: jsonData)
                self.messages.append(message)
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView.insertItems(at: [indexPath])
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error)
        }
        
    }
    
    @objc func sendMessage(sender: UIButton!) {
        print("Sending message")
        if inputTextField.text == "" {
            return
        }
        
        if let senderId = Auth.auth().currentUser?.uid,
           let body = inputTextField.text{
            
            let timestamp = "\(Date().toMillis() ?? 0)"
            let newMessageRef = messagesRef?.childByAutoId()
            let id = newMessageRef?.key
            let message = Message(id: id!, senderId: senderId, body: body, timestamp: timestamp, username: User.onlineUser.username!)
            messagesRef?.childByAutoId().setValue(message.toAnyObject(), withCompletionBlock: { (error, _) in
                if let error = error {
                    print(error)
                }
            })
            FirebaseCalls.shared
                .updateReferenceWithDictionary(ref: chatRef!, values: ["lastMessage": body])
        }
        
        textFieldDidBeginEditing(textField: inputTextField)
    }
    
}

extension ChatSelectedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
}

extension ChatSelectedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("This is the indexPath: \(indexPath)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCollectionViewCell
        
        let message = messages[indexPath.item]
        
        guard let uid = Auth.auth().currentUser?.uid else { return cell }
        guard let messageText = message.body else { return cell }
        guard let usernameText = message.username else { return cell }
        
        // format string according to group or single chat
        let attributesBody = [NSAttributedStringKey.font:
            UIFont.systemFont(ofSize: 18)]
        let attributeUsername = [NSAttributedStringKey.font:
            UIFont.boldSystemFont(ofSize: 14)]
        
        let singleChatMsg = NSMutableAttributedString(string: messageText,
                                                      attributes: attributesBody)
        let groupChatMsg = NSMutableAttributedString(
            string: "\(usernameText) \n",
            attributes: attributeUsername)
        groupChatMsg.append(singleChatMsg)
        
        let text = (chat?.isGroupChat)! && message.senderId != uid ?
            groupChatMsg : singleChatMsg
        
        if message.senderId != Auth.auth().currentUser?.uid {
            // messages received
            cell.showIncomingMessage(text: text)
            
        } else {
            // messages sent
            cell.showOutgoingMessage(text: text)
        }
        
        return cell
    }
}

extension ChatSelectedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let uid = Auth.auth().currentUser?.uid
            else { return CGSize(width: view.frame.width, height: 100) }
        let message = messages[indexPath.item]
        
        if let messageText = message.body, let usernameText = message.username {
            let attributesBody = [NSAttributedStringKey.font:
                UIFont.systemFont(ofSize: 18)]
            let attributeUsername = [NSAttributedStringKey.font:
                UIFont.boldSystemFont(ofSize: 14)]
            // setup singleChatMsg and groupChatMsg
            let singleChatMsg = NSMutableAttributedString(string: messageText,
                                          attributes: attributesBody)
            let groupChatMsg = NSMutableAttributedString(
                string: "\(usernameText) \n",
                attributes: attributeUsername)
            groupChatMsg.append(singleChatMsg)
            
            // calculate the size of the cell with the selected text
            let text = (chat?.isGroupChat)! && message.senderId != uid ?
                 groupChatMsg : singleChatMsg
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            let estimatedFrame = text.boundingRect(with: size, options: options, context: nil)
            
             return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
}










