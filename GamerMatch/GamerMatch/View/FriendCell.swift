//
//  FriendCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

final class FriendCell: UICollectionViewCell {
	private var userImageView = UIImageView() {
		didSet {
			userImageView.layer.cornerRadius = userImageView.frame.height / 2.0
			userImageView.clipsToBounds = true
		}
	}

	private let usernameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.preferredFont(forTextStyle: .body)
		return label
	}()

	private let defaultImage = UIImage(named: "noAvatarImg")!

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		userImageView.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(userImageView)
		contentView.addSubview(usernameLabel)

		NSLayoutConstraint.activate([
			userImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			userImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.60),
			userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),
			userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
		])

		NSLayoutConstraint.activate([
			usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			usernameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 8)
		])
	}

	func configure(with username: String, urlString: String?) {
		usernameLabel.text = username

		if let urlString = urlString {
			userImageView.downloadImage(with: urlString, defaultImage: defaultImage)
		} else {
			userImageView.image = defaultImage
		}
	}
}
