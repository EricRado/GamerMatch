//
//  FriendRequestCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/20/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

protocol FriendRequestCellDelegate: class {
	func friendRequestCellDidTapAcceptButton(_ cell: FriendRequestCell)
}

final class FriendRequestCell: UICollectionViewCell {
	weak var delegate: FriendRequestCellDelegate?

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

	private lazy var acceptFriendRequestButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Accept", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .blue
		return button
	}()

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
		contentView.addSubview(acceptFriendRequestButton)

		NSLayoutConstraint.activate([
			userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
			userImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor)
		])

		NSLayoutConstraint.activate([
			usernameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
			usernameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
		])

		NSLayoutConstraint.activate([
			acceptFriendRequestButton.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 8),
			acceptFriendRequestButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			acceptFriendRequestButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			acceptFriendRequestButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.12),
			acceptFriendRequestButton.heightAnchor
				.constraint(equalTo: acceptFriendRequestButton.heightAnchor, multiplier: 0.5)
		])
	}

	func configure(with username: String?, urlString: String?) {
		usernameLabel.text = username
	}

	@objc private func acceptFriendRequestButtonTapped() {
		delegate?.friendRequestCellDidTapAcceptButton(self)
	}
}
