//
//  FindGamerResultsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/13/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

final class FindGamerResultsViewController: UIViewController {

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

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .white
		collectionView.register(UserSearchResultCell.self, forCellWithReuseIdentifier: UserSearchResultCell.identifier)
		collectionView.dataSource = self
		collectionView.delegate = self
		return collectionView
	}()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .white
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
        
        results = [UserCacheInfo]()
        getUsersResults(from: resultIds)
    }
    
    fileprivate func getUsersResults(from resultIds: [String]?) {
        guard let ids = resultIds else { return }
        
        for id in ids {
            print("This is the id : \(id)")
            guard id != User.onlineUser.uid else { continue }
            FirebaseCalls.shared.getUserCacheInfo(for: id) { [weak self] (userCacheInfo, error) in
				guard let self = self else { return }

				if let error = error {
                    print(error.localizedDescription)
                }

                if let userCacheInfo = userCacheInfo {
                    self.results?.append(userCacheInfo)
                    
                    guard let count = self.results?.count else { return }
                    let indexPath = IndexPath(row: count - 1, section: 0)
                    print("Inserting at row : \(indexPath.item)")
					self.collectionView.insertItems(at: [indexPath])
                }
            }
        }
    }

}

extension FindGamerResultsViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return results?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView
				.dequeueReusableCell(withReuseIdentifier: UserSearchResultCell.identifier, for: indexPath)
				as? UserSearchResultCell else { return UICollectionViewCell() }
		guard let userCacheInfo = results?[indexPath.row] else { return cell }
		
		if let urlString = userCacheInfo.url, urlString != "" {
			let id = mediaManager.downloadImage(from: urlString)
			guard let taskId = id else { return cell }
			taskIdToCellRowDict[taskId] = indexPath.row
		}

		return cell
	}
}

extension FindGamerResultsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		guard let userCacheInfo = results?[indexPath.row] else { return }

		guard let gamerProfileViewController = storyboard?
			.instantiateViewController(withIdentifier: vcIdentifier)
			as? GamerProfileViewController else { return }
		gamerProfileViewController.userCacheInfo = userCacheInfo
		gamerProfileViewController.userImage = cellRowToUserImage[indexPath.row]

		navigationController?.navigationBar.topItem?.backBarButtonItem?.title = "Back"
		navigationController?.pushViewController(gamerProfileViewController, animated: true)
	}

	func collectionView(
		_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 80)
	}
}

extension FindGamerResultsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                guard let item = self.taskIdToCellRowDict[taskId] else { return }
				guard let username = self.results?[item].username else { return }
				let indexPath = IndexPath(item: item, section: 0)
				guard let cell = self.collectionView.cellForItem(at: indexPath)
						as? UserSearchResultCell else { return }
                let image = UIImage(data: data)
				cell.configure(with: username, image: image)
                self.cellRowToUserImage[item] = image
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
