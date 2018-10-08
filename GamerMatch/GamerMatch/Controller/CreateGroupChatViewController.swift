//
//  CreateGroupChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class CreateGroupChatViewController: CreateNewChatViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        
        let nextBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextPressed(sender:)))
        
        navigationItem.rightBarButtonItem = nextBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = false
    
        navigationItem.title = "New Group"
    }
    
    @objc func nextPressed(sender: UIBarButtonItem) {
        print("This is the id : \(groupSetupVCId)")
        guard let vc = storyboard?.instantiateViewController(withIdentifier: groupSetupVCId)
            as? NewGroupChatSetupViewController else { return }
        vc.selectedUsers = selectedUsers.map {(_, value) in value }
        vc.selectedUsersIdToUIImage = selectedUsersIdToUIImage
        navigationController?.navigationBar.topItem?.backBarButtonItem?.title = "Back"
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension CreateGroupChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let arr = friends else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as?
            UserTableViewCell else { return }
        let friend = arr[indexPath.row]
        
        selectedUsers[friend.uid!] = friend
        if let url = friend.url, !url.isEmpty {
            selectedUsersIdToUIImage[friend.uid!] = cell.userImageView.image
        }
        
        cell.accessoryType = .checkmark
        
        if arr.count >= 1 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        print(selectedUsers)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let arr = friends else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let friend = arr[indexPath.row]
        
        selectedUsers.removeValue(forKey: friend.uid!)
        if let url = friend.url, !url.isEmpty {
           selectedUsersIdToUIImage.removeValue(forKey: friend.uid!)
        }
        
        cell.accessoryType = .none
        
        if arr.count < 1 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        print(selectedUsers)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 7
    }
    
}
