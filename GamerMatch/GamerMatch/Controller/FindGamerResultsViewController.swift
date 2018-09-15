//
//  FindGamerResultsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/13/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class FindGamerResultsViewController: UIViewController {
    
    private let cellId = "gamerCell"
    @IBOutlet weak var tableView: UITableView!
    var results: [UserCacheInfo]?
    var resultIds: [String]?
    var gamerMatchRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        results = [UserCacheInfo]()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print("FindGamerResultsVC : \(gamerMatchRef)")
        getUsersResults(from: resultIds)
    }
    
    fileprivate func getUsersResults(from resultIds: [String]?) {
        guard let ids = resultIds else { return }
        
        for id in ids {
            print("This is the id : \(id)")
            FirebaseCalls.shared.getUserCacheInfo(userId: id) { (userCacheInfo, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let userCacheInfo = userCacheInfo {
                    self.results?.append(userCacheInfo)
                    
                    guard let count = self.results?.count else { return }
                    let indexPath = IndexPath(row: count - 1, section: 0)
                    print("Inserting at row : \(indexPath.item)")
                    self.tableView.insertRows(at: [indexPath], with: .none)
                }
                
            }
        }
    }

}

extension FindGamerResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GamerMatchTableViewCell
        guard let userCacheInfo = results?[indexPath.row] else { return cell }
        
        cell.gamerUsernameLabel.text = userCacheInfo.username
        
        if userCacheInfo.avatarURL == "" {
            cell.gamerAvatarImageView.image = UIImage(named: "noAvatarImg")
        }
        
        return cell
    }
}

extension FindGamerResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
}
