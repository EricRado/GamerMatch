//
//  UserSearchResultCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 11/22/20.
//  Copyright © 2020 Eric Rado. All rights reserved.
//

import UIKit

final class UserSearchResultCell: UICollectionViewCell {
	static let preferredHeight: CGFloat = 85.0
	private let defaultAvatarImage = UIImage(named: "noAvatarImg")!
	private lazy var avatarImageView: UIImageView = {
		let avatarImageView = UIImageView()
		avatarImageView.translatesAutoresizingMaskIntoConstraints = false
		avatarImageView.image = defaultAvatarImage
		avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2.0
		avatarImageView.clipsToBounds = true
		return avatarImageView
	}()

	private let usernameLabel: UILabel = {
		let usernameLabel = UILabel()
		usernameLabel.translatesAutoresizingMaskIntoConstraints = false
		usernameLabel.font = UIFont.preferredFont(forTextStyle: .body)
		return usernameLabel
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		avatarImageView.image = defaultAvatarImage
		usernameLabel.text = nil
	}

	private func setupView() {
		contentView.addSubview(avatarImageView)
		contentView.addSubview(usernameLabel)

		NSLayoutConstraint.activate([
			avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
			avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor)
		])

		NSLayoutConstraint.activate([
			usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
			usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			usernameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
		])
	}

	func configure(with username: String, urlString: String?) {
		if let urlString = urlString {
			avatarImageView.downloadImage(with: urlString, defaultImage: defaultAvatarImage)
		} else {
			avatarImageView.image = defaultAvatarImage
		}

		usernameLabel.text = username
	}
}
