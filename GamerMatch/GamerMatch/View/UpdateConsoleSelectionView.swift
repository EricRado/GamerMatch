//
//  UpdateConsoleSelection.swift
//  GamerMatch
//
//  Created by Eric Rado on 10/4/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class UpdateConsoleSelectionView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet var consoleBtns: [UIButton]! {
        didSet {
            let consoles = VideoGameRepo.shared.getConsoles()
            for (index, btn) in consoleBtns.enumerated() {
                guard let console = consoles?[index] else { continue }
                btn.setBackgroundImage(console.notSelectedImage, for: .normal)
                btn.setBackgroundImage(console.selectedImage, for: .selected)
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
        Bundle.main.loadNibNamed("UpdateConsoleSelectionView", owner: self, options: nil)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
}
