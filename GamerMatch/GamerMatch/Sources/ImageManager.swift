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

final class ImageManager: NSObject {
    static let shared = ImageManager()
    let sessionTag = "downloadImage"
    
    private override init() {}
    
    func downloadImage(urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .background(withIdentifier: sessionTag))
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else { return }
            
            DispatchQueue.main.async {
                if let data = data {
                    print("Image is done downloading...")
                    let image = UIImage(data: data)
                    completion(image, nil)
                }
            }
        }.resume()
    }
}













