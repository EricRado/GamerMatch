//
//  GameAndConsoleSelectionViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/21/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class GameAndConsoleSelectionViewController: UIViewController {
    
    private lazy var consoleChoices: [String] = {
        var arr = [String]()
        return arr
    }()
    
    /*private lazy var gameChoices: [Game] = {
        var arr = [Game]()
        return arr
    }*/
    
    @IBOutlet var consoleBtns: [UIButton]! {
        didSet {
            for btn in consoleBtns {
                btn.addTarget(
                    self,
                    action: #selector(consoleBtnPressed(sender:)),
                    for: .touchUpInside)
            }
        }
    }
    @IBOutlet var gameBtns: [UIButton]! {
        didSet {
            for btn in gameBtns {
                btn.addTarget(
                    self,
                    action: #selector(gameBtnPressed(sender:)),
                    for: .touchUpInside)
            }
        }
    }
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var submitBtn: UIButton! {
        didSet {
            submitBtn.addTarget(
                self,
                action: #selector(submitBtnPressed(sender:)),
                for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @objc fileprivate func consoleBtnPressed(sender: UIButton) {
        print("console btn pressed with tag: \(sender.tag)")
    }
    
    @objc fileprivate func gameBtnPressed(sender: UIButton) {
        print("game btn pressed with tag: \(sender.tag)")
    }
    
    @objc fileprivate func submitBtnPressed(sender: UIButton) {
        print("submit btn pressed")
    }
    
  

}
