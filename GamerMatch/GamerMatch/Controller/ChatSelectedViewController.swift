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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
