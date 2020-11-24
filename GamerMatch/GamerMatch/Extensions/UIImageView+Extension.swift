//
//  UIImageView+Extension.swift
//  GamerMatch
//
//  Created by Eric Rado on 11/23/20.
//  Copyright © 2020 Eric Rado. All rights reserved.
//

import UIKit

extension UIImageView {
	func downloadImage(with urlString: String, defaultImage: UIImage) {
		let imageManager = ImageManager()
		imageManager.downloadImage(from: urlString) { result in
			switch result {
			case .failure:
				self.image = defaultImage
			case .success(let image):
				self.image = image ?? defaultImage
			}
		}
	}
}
