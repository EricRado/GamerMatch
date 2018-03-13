//
//  ChatSelectedViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/11/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class ChatSelectedViewController: UIViewController {
    var participantIds = [String]()
    var selectedChatUser: ChatUserDisplay?
    var chat: Chat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Chat Selected View Controller...")
        print(participantIds)
    }

}
