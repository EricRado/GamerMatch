//
//  FindGamerViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FindGamerViewController: UIViewController {
    
    @IBOutlet var consoleBtnsArr: [UIButton]!
    @IBOutlet var gameBtnsArr: [UIButton]!
    @IBOutlet var roleBtnsArr: [UIButton]!
    
    @IBOutlet weak var middleText: UIImageView!
    @IBOutlet weak var bottomText: UIImageView!
    
    var isTapped: Bool = false
    
    // stores video games for all systems
    var videoGames = [VideoGame]()
    
    // stores video games based on selected system
    var gamesCurrentlyDisplayed = [VideoGame]()
    
    // stores video game roles based on selected game
    var videoGameRoles = [VideoGameRole]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoGames()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for btn in gameBtnsArr {
            btn.isHidden = true
        }
        for btn in roleBtnsArr {
            btn.isHidden = true
        }
        middleText.isHidden = true
        bottomText.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for btn in consoleBtnsArr {
            btn.isSelected = false
        }
        isTapped = false
    }
    
    func setupVideoGames() {
        videoGames.append(VideoGame(title: "halo5", notSelectedImage: UIImage(named: "halo5")!,
                selectedImage: UIImage(named: "selectedHalo5")!, gameTypes: ["xbox"]))
        videoGames.append(VideoGame(title: "leagueOfLegends", notSelectedImage: UIImage(named: "leagueOfLegends")!,
                selectedImage: UIImage(named: "selectedLeagueOfLegends")!, gameTypes: ["pc"]))
        videoGames.append(VideoGame(title: "fortnite", notSelectedImage: UIImage(named: "fortnite")!,
                selectedImage: UIImage(named: "selectedFortnite")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "overwatch", notSelectedImage: UIImage(named: "overwatch")!,
                selectedImage: UIImage(named: "selectedOverwatch")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "nba2k18", notSelectedImage: UIImage(named: "nba2k18")!,
                selectedImage: UIImage(named: "selectedNba2k18")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "battlefield1", notSelectedImage: UIImage(named: "battlefield1")!,
                selectedImage: UIImage(named: "selectedBattlefield1")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "uncharted4", notSelectedImage: UIImage(named: "uncharted4")!,
                selectedImage: UIImage(named: "selectedUncharted4")!, gameTypes: ["playstation"]))
        videoGames.append(VideoGame(title: "rocketLeague", notSelectedImage: UIImage(named: "rocketLeague")!,
                selectedImage: UIImage(named: "selectedRocketLeague")!, gameTypes: ["xbox", "playstation", "pc"]))
    }
    
    func showGameBtns(consoleChoice: String) {
        if !gamesCurrentlyDisplayed.isEmpty {
            gamesCurrentlyDisplayed.removeAll()
        }
        print("ShowGameBtns ... \(consoleChoice)")
        for videoGame in videoGames {
            if videoGame.gameTypes.contains(consoleChoice) {
                gamesCurrentlyDisplayed.append(videoGame)
            }
        }
        for (index,btn) in gameBtnsArr.enumerated(){
            btn.setImage(gamesCurrentlyDisplayed[index].notSelectedImage, for: .normal)
            btn.setImage(gamesCurrentlyDisplayed[index].selectedImage, for: .selected)
            btn.isHidden = false
        }
        print(gamesCurrentlyDisplayed)
    }
    
    func hideGameBtns() {
        for btn in gameBtnsArr {
            btn.isHidden = true
        }
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
        
        // if a console btn is selcted, dont allow other console btns to be selected
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
        let gameChoice = gamesCurrentlyDisplayed[sender.tag].title!
        print("\(gameChoice) was selected")
        sender.isSelected = true
        
        switch gameChoice {
        case "overwatch", "battlefield1", "nba2k18", "leagueOfLegends":
            bottomText.isHidden = false
            displayRoleBtns(gameChoice: gameChoice)
        default:
            print("Create an alert to start query search...")
            createAlert(btnTag: sender.tag)
            
        }
        
    }
    
    func createAlert(btnTag: Int) {
        let ac = UIAlertController(title: "Request", message: "Search for gamer...", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Search", style: .default){ action in
            print("Segue to new search result screen...")
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel){ action in
            self.gameBtnsArr[btnTag].isSelected = false
        })
        self.present(ac, animated: true, completion: nil)
    }
    
    func displayRoleBtns(gameChoice: String){
        switch gameChoice {
        case "overwatch":
            videoGameRoles.append(VideoGameRole(roleName: "offense", roleImg: UIImage(named: "offenseOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedOffenseOverwatchRole")!))
            videoGameRoles.append(VideoGameRole(roleName: "defense", roleImg: UIImage(named: "defenseOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedDefenseOverwatchRole")!))
            videoGameRoles.append(VideoGameRole(roleName: "support", roleImg: UIImage(named: "supportOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedSupportOverwatchRole")!))
            videoGameRoles.append(VideoGameRole(roleName: "tank", roleImg: UIImage(named: "tankOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedTankOverwatchRole")!))
            
        case "nba2k18":
            videoGameRoles.append(VideoGameRole(roleName: "point gaurd", roleImg: UIImage(named: "pgNba2k18")!, selectedRoleImg: UIImage(named: "selectedPgNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "shooting gaurd", roleImg: UIImage(named: "sgNba2k18")!, selectedRoleImg: UIImage(named: "selectedSgNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "small forward", roleImg: UIImage(named: "sfNba2k18")!, selectedRoleImg: UIImage(named: "selectedSfNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "power forward", roleImg: UIImage(named: "pfNba2k18")!, selectedRoleImg: UIImage(named: "selectedPfNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "center", roleImg: UIImage(named: "cNba2k18")!, selectedRoleImg: UIImage(named: "selectedCNba2k18")!))
        default:
            return
        }
        var counter = 0
        print(videoGameRoles)
        for role in videoGameRoles {
            print("role...")
            print(role)
            roleBtnsArr[counter].setImage(role.roleImg, for: .normal)
            roleBtnsArr[counter].setImage(role.selectedRoleImg, for: .selected)
            roleBtnsArr[counter].isHidden = false
            counter += 1
        }
    }
    
    @IBAction func roleBtnPressed(_ sender: UIButton){
        
    }

}
