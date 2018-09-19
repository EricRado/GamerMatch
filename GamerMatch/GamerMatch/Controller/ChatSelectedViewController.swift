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

class ChatSelectedViewController: UIViewController {
    private let cellId = "messageCell"
    var participantIds = [String: String]()
    var selectedChatUser: ChatUserDisplay?
    var chat: Chat?
    var messages = [Message]()
    var image: UIImage?
    
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
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.white
            collectionView.keyboardDismissMode = .onDrag
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(participantIds)
        
        inputTextField.delegate = self
        
        // setup message field and send button
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        // add notification observers to handle keyboard display when typing message
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let title = selectedChatUser != nil ? selectedChatUser?.username : chat?.title
        navigationItem.title = title
        
        getMessages()
    }
    
    fileprivate func setImageInNavBar() {
        guard let img = image else { return }
        
        let imageView = UIImageView(image: img)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            print(keyboardFrame!)
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
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
            } catch let error {
                print(error)
            }
            print("reloading...")
            self.collectionView.reloadData()
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
            let message = Message(id: id!, senderId: senderId, body: body, timestamp: timestamp)
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
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
}

extension ChatSelectedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCollectionViewCell
        
        if let messageText = messages[indexPath.item].body {
            cell.messageTextView.text = "\(messageText)"
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            if messages[indexPath.item].senderId != Auth.auth().currentUser?.uid {
                
                // messages recieved
                
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 40, height: estimatedFrame.height + 26)
                
                cell.profileImageView.isHidden = false
                
                if !(chat?.isGroupChat)! {
                    cell.profileImageView.image = selectedChatUser?.image
                }
                
                cell.bubbleImageView.image = ChatMessageCollectionViewCell.grayBubbleImage
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                
                //cell.profileImageView.image =
                
            } else {
                
                // messages sent
                
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 40, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 40 - 10, y: -4, width: estimatedFrame.width + 34, height: estimatedFrame.height + 26)
                
                cell.profileImageView.isHidden = true
                
                cell.bubbleImageView.image = ChatMessageCollectionViewCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
            }
        }
        
        return cell
    }
}

extension ChatSelectedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = messages[indexPath.item].body {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
}












