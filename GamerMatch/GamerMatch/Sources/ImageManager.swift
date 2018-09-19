//
//  ImageManager.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/29/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

final class ImageManager {
    
    var downloadSession: URLSession!
    
    init(downloadSession: URLSession) {
        self.downloadSession = downloadSession
    }
    
    init() {}
    
    func downloadImage(from urlString: String) -> Int? {
        guard let url = URL(string: urlString) else { return nil }
        print("Download task is about to start with : \(urlString)")
        
        let downloadTask = downloadSession.downloadTask(with: url)
        downloadTask.resume()
        
        return downloadTask.taskIdentifier
    }
    
    func uploadImage(image: UIImage, at filePath: String,
                     completion: @escaping (String?, Error?) -> Void) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let storageRef = Storage.storage().reference()
        storageRef.child(filePath)
            .putData(data, metadata: metaData) { (metaData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil, error)
                    return
                } else {
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    print(downloadURL ?? "no url")
                    completion(downloadURL, nil)
                }
        }
    }
}













