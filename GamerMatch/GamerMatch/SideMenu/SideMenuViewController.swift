//
//  SideMenuViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/26/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var interactor: Interactor? = nil
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SideMenuTableViewCell()
        return cell
    }
    
    
}
