//
//  FindGamerViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FindGamerViewController: UIViewController {
    
    @IBOutlet var gameBtnsArr: [UIButton]!
    
    @IBOutlet weak var middleText: UIImageView!
    @IBOutlet weak var bottomText: UIImageView!
    
    var isTapped: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for btn in gameBtnsArr {
            btn.isHidden = true
        }
        middleText.isHidden = true
        bottomText.isHidden = true
    }
    
    func showGameBtns() {
        for btn in gameBtnsArr {
            btn.isHidden = false
            btn.backgroundImage(for: .normal)
        }
    }
    
    func hideGameBtns() {
        for btn in gameBtnsArr {
            btn.isHidden = true
        }
    }
    
    func highlightBtn(btn: UIButton) {
        print("ran highlightbtn...")
        //btn.image(for: .selected)
        
    }
    
    
    @IBAction func consoleBtnPressed(_ sender: UIButton) {
        
        print("Btn is pressed : \(isTapped)")
        print("Btn pressed isHighlighted : \(sender.isSelected)")
        
        if sender.isSelected {
            sender.isSelected = false
            isTapped = false
            middleText.isHidden = true
            hideGameBtns()
            bottomText.isHidden = true
            return
        }
        
        if isTapped {
            return
        }
        
        if sender.tag == 0 {
            print("Xbox was pressed...")
        }else if sender.tag == 1 {
            print("Playstation was pressed...")
        }else {
            print("PC was pressed...")
        }
        
        //highlightBtn(btn: sender)
        isTapped = true
        sender.isSelected = true
        
        middleText.isHidden = false
        showGameBtns()
    }

}
