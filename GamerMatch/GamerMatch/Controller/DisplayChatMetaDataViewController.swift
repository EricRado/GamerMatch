//
//  DisplayChatMetaDataViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/19/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class DisplayChatMetaDataViewController: UIViewController {
    
    private let cellId = "cellId"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: UserTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellId)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var groupImageButton: UIButton! {
        didSet {
            groupImageButton
                .setBackgroundImage(groupImage, for: .normal)
            groupImageButton.addTarget(
                self,
                action: #selector(imagePressed(sender:)),
                for: .touchUpInside)
         
        }
    }
    @IBOutlet weak var changeButton: UIButton!
    
    var groupImage: UIImage?
    var chat: Chat?
    var members: [UserCacheInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat Settings"
        members = [UserCacheInfo]()
        getUsers()
    }
    
    fileprivate func getUsers() {
        guard let dict = chat?.members else { return }
        for (key, _) in dict {
            FirebaseCalls.shared.getUserCacheInfo(for: key) { (member, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print(member)
                self.members?.append(member!)
                let row = (self.members?.count)! - 1
                self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .none)
            }
        }
    }
    
    @objc fileprivate func imagePressed(sender: UIButton) {
        print("image pressed")
        CamaraHandler.shared.showActionSheet(vc: self)
        CamaraHandler.shared.imagePickedBlock =
    }
}

extension DisplayChatMetaDataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DisplayChatMetaDataViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if let count = members?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            as? UserTableViewCell else { return UITableViewCell() }
        guard let user = members?[indexPath.row] else { return UITableViewCell()}
        
        cell.usernameLabel.text = user.username
            
        return cell
    }
}














