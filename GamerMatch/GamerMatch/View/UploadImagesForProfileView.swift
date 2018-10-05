//
//  UploadImagesForProfileView.swift
//  GamerMatch
//
//  Created by Eric Rado on 10/4/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class UploadImagesForProfileView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet var imageBtns: [UIButton]! {
        didSet {
            for (index, btn) in imageBtns.enumerated() {
                btn.tag = index
            }
        }
    }
    @IBOutlet var uploadBtns: [UIButton]! {
        didSet {
            for (index, btn) in uploadBtns.enumerated() {
                btn.tag = index
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UploadImagesForProfileView", owner: self, options: nil)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }

}

















