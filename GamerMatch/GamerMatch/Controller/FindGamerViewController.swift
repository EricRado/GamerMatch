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
    var videoGames = [VideoGame]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoGames()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for btn in gameBtnsArr {
            btn.isHidden = true
        }
        middleText.isHidden = true
        bottomText.isHidden = true
    }
    
    func setupVideoGames() {
        videoGames.append(VideoGame(title: "halo5", notSelectedImage: UIImage(named: "halo5")!, selectedImage: UIImage(named: "selectedHalo5")!, gameTypes: ["xbox"]))
        videoGames.append(VideoGame(title: "leagueOfLegends", notSelectedImage: UIImage(named: "leagueOfLegends")!, selectedImage: UIImage(named: "selectedLeagueOfLegends")!, gameTypes: ["pc"]))
        videoGames.append(VideoGame(title: "fortnite", notSelectedImage: UIImage(named: "fortnite")!, selectedImage: UIImage(named: "selectedFortnite")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "overwatch", notSelectedImage: UIImage(named: "overwatch")!, selectedImage: UIImage(named: "selectedOverwatch")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "nba2k18", notSelectedImage: UIImage(named: "nba2k18")!, selectedImage: UIImage(named: "selectedNba2k18")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "battlefield1", notSelectedImage: UIImage(named: "battlefield1")!, selectedImage: UIImage(named: "selectedBattlefield1")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "uncharted4", notSelectedImage: UIImage(named: "uncharted4")!, selectedImage: UIImage(named: "selectedUncharted4")!, gameTypes: ["playstation"]))
        videoGames.append(VideoGame(title: "rocketLeague", notSelectedImage: UIImage(named: "rocketLeague")!, selectedImage: UIImage(named: "selectedRocketLeague")!, gameTypes: ["xbox", "playstation", "pc"]))
    }
    
    func showGameBtns(consoleChoice: String) {
        var counter = 0
        for videoGame in videoGames {
            if videoGame.gameTypes.contains(consoleChoice) {
                gameBtnsArr[counter].setImage(videoGame.notSelectedImage, for: .normal)
                gameBtnsArr[counter].setImage(videoGame.selectedImage, for: .selected)
                gameBtnsArr[counter].isHidden = false
                counter = counter + 1
            }
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
        
        // if the same console choice is pressed again reset the questionaire
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
        
        isTapped = true
        sender.isSelected = true
        
        // show text for game choice question
        middleText.isHidden = false
        
        // show games based on console image pressed
        if sender.tag == 0 {
            print("Xbox was pressed...")
            showGameBtns(consoleChoice: "xbox")
        }else if sender.tag == 1 {
            print("Playstation was pressed...")
            showGameBtns(consoleChoice: "playstation")
        }else {
            print("PC was pressed...")
            showGameBtns(consoleChoice: "pc")
        }
        
    }
    
    @IBAction func gameBtnPressed(_ sender: UIButton) {
        
    }

}
