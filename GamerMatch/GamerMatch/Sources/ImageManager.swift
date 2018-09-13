//
//  ImageManager.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/29/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

extension UIImageView {
    public func downloadImage(urlString: String) {
        print("DOWNLOADING IMAGE...")
        URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Sending to dispatch...")
            DispatchQueue.main.async {
                if let data = data {
                    print("Transfering to uiimage...")
                    self.image = UIImage(data: data)
                    print("DONE...")
                }
            }
        }.resume()
    }
}

final class ImageManager {
    static let shared = ImageManager()
    var downloadSession: URLSession!
    
    private init() {}
    
    func downloadImage(urlString: String) -> Int? {
        guard let url = URL(string: urlString) else { return nil }
        print("Download task is about to start with : \(urlString)")
        let downloadTask = downloadSession.downloadTask(with: url)
        downloadTask.resume()
        
        return downloadTask.taskIdentifier
    }
}













