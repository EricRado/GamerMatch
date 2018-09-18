//
//  Create1On1ChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class Create1On1ChatViewController: CreateNewChatViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        navigationItem.title = "New Chat"
    }

}


extension Create1On1ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let friend = friends?[indexPath.row] else { return }
        selectedUsers[friend.id!] = friend
        print(selectedUsers)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 7
    }
    
}
