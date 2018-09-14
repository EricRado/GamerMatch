//
//  FindGamerResultsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/13/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FindGamerResultsViewController: UIViewController {
    
    private let cellId = "gamerCell"
    @IBOutlet weak var tableView: UITableView!
    var results: [UserCacheInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
                                         

}

extension FindGamerResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GamerMatchTableViewCell
        
        return cell
    }
}

extension FindGamerResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
