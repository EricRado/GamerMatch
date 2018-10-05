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
    private let vcIdentifier = "GamerProfileViewController"
    var results: [UserCacheInfo]?
    var resultIds: [String]?
    var taskIdToCellRowDict = [Int: Int]()
    var cellRowToUserImage = [Int: UIImage]()
    
    lazy var downloadSession: URLSession = {
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()
    
    lazy var mediaManager: ImageManager = {
        let manager = ImageManager(downloadSession: downloadSession)
        return manager
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        results = [UserCacheInfo]()
        getUsersResults(from: resultIds)
    }
    
    fileprivate func getUsersResults(from resultIds: [String]?) {
        guard let ids = resultIds else { return }
        
        for id in ids {
            print("This is the id : \(id)")
            FirebaseCalls.shared.getUserCacheInfo(for: id) { (userCacheInfo, error) in
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
        
        if let urlString = userCacheInfo.url, urlString != "" {
            let id = mediaManager.downloadImage(from: urlString)
            guard let taskId = id else { return cell }
            taskIdToCellRowDict[taskId] = indexPath.row
            
        } else {
            cell.gamerAvatarImageView.image = UIImage(named: "noAvatarImg")
        }
        
        return cell
    }
}

extension FindGamerResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userCacheInfo = results?[indexPath.row] else { return }
        
        guard let vc = storyboard?
            .instantiateViewController(withIdentifier: vcIdentifier)
            as? GamerProfileViewController else { return }
        vc.userCacheInfo = userCacheInfo
        vc.userImage = cellRowToUserImage[indexPath.row]
        
        navigationController?.navigationBar.topItem?.backBarButtonItem?.title = "Back"
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
}

extension FindGamerResultsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                guard let row = self.taskIdToCellRowDict[taskId] else { return }
                guard let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? GamerMatchTableViewCell else { return }
                let image = UIImage(data: data)
                cell.gamerAvatarImageView.image = image
                self.cellRowToUserImage[row] = image
            }
        } catch let error {
            print(error)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    
}













