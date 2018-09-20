//
//  ViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/20/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FriendRequestViewController: UIViewController {
    
    private let cellId = "cellId"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: FriendRequestTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellId)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func acceptFriendRequestBtnPressed(sender: UIButton) {
        print("accept btn pressed")
    }

}

extension FriendRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension FriendRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            as? FriendRequestTableViewCell else { return UITableViewCell() }
        cell.acceptFriendRequestBtn.tag = indexPath.row
        cell.acceptFriendRequestBtn.addTarget(
            self,
            action: #selector(acceptFriendRequestBtnPressed(sender:)),
            for: .touchUpInside)
        
        return cell
    }
}
