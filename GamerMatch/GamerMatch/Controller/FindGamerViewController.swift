//
//  FindGamerViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class FindGamerViewController: UIViewController {
    
    private let findGamerResultsSegueId = "findGamerResultsSegue"
    private lazy var dbRef = {
        return Database.database().reference()
    }()
    private var ids: [String]?
    
    // MARK: - IBOutlet Variables
    
    @IBOutlet var consoleBtnsArr: [UIButton]! {
        didSet {
            guard let consoles = VideoGameRepo.shared.getConsoles() else { return }
            for btn in consoleBtnsArr {
                let console = consoles[btn.tag]
                btn.setBackgroundImage(console.notSelectedImage, for: .normal)
                btn.setBackgroundImage(console.selectedImage, for: .selected)
                buttonTagToConsoleDict[btn.tag] = console
            }
        }
    }
    @IBOutlet var gameBtnsArr: [UIButton]!
    @IBOutlet var roleBtnsArr: [UIButton]!
    @IBOutlet weak var middleText: UIImageView!
    @IBOutlet weak var bottomText: UIImageView!
    
    // MARK: - ViewController Variables
    
    var consoleIsTapped: Bool = false
    var gameWithRolesTapped: Bool = false
    
    // console name pressed
    var consoleName = ""
    private var buttonTagToConsoleDict = [Int: Console]()
    
    // stores video games for all systems
    private lazy var videoGames: [String: VideoGame]? = {
        guard let arr = VideoGameRepo.shared.getVideoGames() else { return nil }
        var dict = [String: VideoGame]()
        for game in arr {
            dict[game.title!] = game
        }
        return dict
    }()
    
    // stores video games based on selected system
    var gamesCurrentlyDisplayed = [VideoGame]()
    
    // stores video game roles based on selected game
    var videoGameRoles = [VideoGameRole]()
    
    // stores video game button pressed by user
    var selectedVideogameBtnPressed: UIButton?
    
    // stores the tag of the console button pressed by user
    var selectedConsoleBtnPressed: UIButton?
    
    // MARK: - ViewController's Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide all of the UI elements except the console buttons and top text
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
        
        _ = gameBtnsArr.map { $0.isSelected = false }
        consoleIsTapped = false
    }
    
    // MARK: - Display Buttons Functions
    
    func displayGameBtns(consoleChoice: String) {
        if !gamesCurrentlyDisplayed.isEmpty {
            gamesCurrentlyDisplayed.removeAll()
        }
        guard let games = videoGames else { return }
        print("ShowGameBtns ... \(consoleChoice)")
        for (_, videoGame) in games {
            let consoles = videoGame.consoleTypes
            if consoles.contains(ConsoleType(rawValue: consoleChoice)!) {
                gamesCurrentlyDisplayed.append(videoGame)
            }
        }
        for (index,btn) in gameBtnsArr.enumerated(){
            btn.setImage(gamesCurrentlyDisplayed[index].notSelectedImage, for: .normal)
            btn.setImage(gamesCurrentlyDisplayed[index].selectedImage, for: .selected)
            btn.isHidden = false
        }
    }
    
    fileprivate func createGamerMatchDBPath(console: String, game: String, role: String?) -> String {
        let gameName = game.removingWhitespaces()
        var ref = "\(console)/\(gameName)/"
        
        if let role = role?.removingWhitespaces() {
            ref += role
        }
        
        return ref
    }

    func createAlert(gameBtnTag: Int, roleBtnTag: Int?) {
        var message = ""
        guard let gameName = gamesCurrentlyDisplayed[gameBtnTag].title
            else { return}
        var roleName: String?
        
        // setup search query message to display to the user
        if let roleBtnTag = roleBtnTag {
            roleName = self.videoGameRoles[roleBtnTag].roleName
            
            message = "Search for gamer who plays \(gameName) for \(consoleName.uppercased()) and plays \(roleName!) role"
        }else {
            message = "Search for gamer who plays \(gameName) for \(consoleName.uppercased())"
        }
        
        // setup alert view controller
        let ac = UIAlertController(title: "Request", message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Search", style: .default){ action in
            let path = self.createGamerMatchDBPath(console: self.consoleName,
                                                        game: gameName,
                                                        role: roleName)
            SVProgressHUD.show(withStatus: "Searching...")
            
            print("this is the search ref : \(path)")
            let ref = self.dbRef.child(path)
            FirebaseCalls.shared
                .getIdListFromNode(for: ref) { (ids, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.ids = ids
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: self.findGamerResultsSegueId,
                                      sender: nil)
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel){ action in
            self.gameBtnsArr[gameBtnTag].isSelected = false
        })
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func displayRoleBtns(){
        if !videoGameRoles.isEmpty {
            videoGameRoles.removeAll()
        }
        
        guard let index = selectedVideogameBtnPressed?.tag else { return }
        guard let title = gamesCurrentlyDisplayed[index].title else { return }
        guard let roles = videoGames?[title]?.roles else { return }
        videoGameRoles = roles
        
        // set the images for the role buttons collection
        var counter = 0
        for role in videoGameRoles {
            roleBtnsArr[counter].setImage(role.roleImg, for: .normal)
            roleBtnsArr[counter].setImage(role.selectedRoleImg, for: .selected)
            roleBtnsArr[counter].isHidden = false
            counter += 1
        }
    }
    
    // MARK: - IBAction Functions
    
    @IBAction func consoleBtnPressed(_ sender: UIButton) {
        
        // if the same console choice is pressed again reset the questionaire
        if sender.isSelected {
            sender.isSelected = false
            consoleIsTapped = false
            middleText.isHidden = true
            gameBtnsArr.hideButtons()
            bottomText.isHidden = true
            return
        }
        
        // if a console btn is selcted, dont allow other console btns to be selected
        if selectedConsoleBtnPressed?.tag != sender.tag {
            selectedConsoleBtnPressed?.isSelected = false
            if gameWithRolesTapped {
                bottomText.isHidden = true
                roleBtnsArr.hideButtons()
                selectedVideogameBtnPressed?.isSelected = false
            }
        }
        
        consoleIsTapped = true
        sender.isSelected = true
        
        // show text for game choice question
        middleText.isHidden = false
        
        selectedConsoleBtnPressed = sender
        
        // show games based on console image pressed
        guard let name = buttonTagToConsoleDict[(selectedConsoleBtnPressed?.tag)!]?.name
            else { return }
        consoleName = name
        displayGameBtns(consoleChoice: consoleName)
        
    }
    
    @IBAction func gameBtnPressed(_ sender: UIButton) {
        if gameWithRolesTapped {
            bottomText.isHidden = true
            roleBtnsArr.hideButtons()
            selectedVideogameBtnPressed?.isSelected = false
        }
        
        selectedVideogameBtnPressed = sender
        sender.isSelected = true
        
        if gamesCurrentlyDisplayed[sender.tag].roles != nil {
            bottomText.isHidden = false
            displayRoleBtns()
            gameWithRolesTapped = true
        } else {
            print("Create an alert to start query search...")
            createAlert(gameBtnTag: sender.tag, roleBtnTag: nil)
        }
        
    }
    
    @IBAction func roleBtnPressed(_ sender: UIButton){
        createAlert(gameBtnTag: (selectedVideogameBtnPressed?.tag)!, roleBtnTag: sender.tag)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination
            as? FindGamerResultsViewController {
            destinationViewController.resultIds = ids
        }
    }
}












