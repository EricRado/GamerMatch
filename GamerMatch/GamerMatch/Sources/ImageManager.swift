//
//  ImageManager.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/29/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

final class ImageManager {
    
    var downloadSession: URLSession!
    
    init(downloadSession: URLSession) {
        self.downloadSession = downloadSession
    }
    
    func downloadImage(from urlString: String) -> Int? {
        guard let url = URL(string: urlString) else { return nil }
        print("Download task is about to start with : \(urlString)")
        
        let downloadTask = downloadSession.downloadTask(with: url)
        downloadTask.resume()
        
        return downloadTask.taskIdentifier
    }
}













