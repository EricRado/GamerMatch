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
    
	func downloadImage(from urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
		guard let url = URL(string: urlString) else { return }
		let urlRequest = URLRequest(url: url)

		let cache = URLCache.shared
		if let cachedURLResponse = cache.cachedResponse(for: urlRequest) {
			completion(.success(UIImage(data: cachedURLResponse.data)))
			return
		}

		URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
			guard error == nil else {
				completion(.failure(error!))
				return
			}

			if let response = response, let data = data, let image = UIImage(data: data) {
				let cachedImageData = CachedURLResponse(response: response, data: data)
				cache.storeCachedResponse(cachedImageData, for: urlRequest)
				DispatchQueue.main.async {
					completion(.success(image))
				}
			}
		}.resume()
    }
    
    func uploadImage(image: UIImage, at filePath: String, completion: @escaping (String?, Error?) -> Void) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let storageRef = Storage.storage().reference()
        storageRef.child(filePath).putData(data, metadata: metaData) { (metaData, error) in
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
