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

extension FindGamerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    /* indicate that the dismiss transition is going to be interactive,
       but only if the user is panning */
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.shouldFinish ? interactor : nil
    }
}



class FindGamerViewController: UIViewController {
    
    private let findGamerResultsSegueId = "findGamerResultsSegue"
    private var searchRef: DatabaseReference?
    private var ids: [String]?
    
    // MARK: - IBOutlet Variables
    
    @IBOutlet var consoleBtnsArr: [UIButton]!
    @IBOutlet var gameBtnsArr: [UIButton]!
    @IBOutlet var roleBtnsArr: [UIButton]!
    @IBOutlet weak var middleText: UIImageView!
    @IBOutlet weak var bottomText: UIImageView!
    
    // MARK: - ViewController Variables
    
    var consoleIsTapped: Bool = false
    var gameWithRolesTapped: Bool = false
    
    // console name pressed
    var consoleName = ""
    
    // stores video games for all systems
    var videoGames = [VideoGame]()
    
    // stores video games based on selected system
    var gamesCurrentlyDisplayed = [VideoGame]()
    
    // stores video game roles based on selected game
    var videoGameRoles = [VideoGameRole]()
    
    // stores video game button pressed by user
    var selectedVideogameBtnPressed: UIButton?
    
    // stores console button pressed by user
    var selectedConsoleBtnPressed: UIButton?
    
    var interactor = Interactor()
    
    // MARK: - ViewController's Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoGames()

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
        consoleIsTapped = false
    }
    
    // MARK: - Display Buttons Functions
    
    func setupVideoGames() {
        videoGames.append(VideoGame(title: "halo 5", notSelectedImage: UIImage(named: "halo5")!,
                selectedImage: UIImage(named: "selectedHalo5")!, gameTypes: ["xbox"]))
        videoGames.append(VideoGame(title: "league Of Legends", notSelectedImage: UIImage(named: "leagueOfLegends")!,
                selectedImage: UIImage(named: "selectedLeagueOfLegends")!, gameTypes: ["pc"]))
        videoGames.append(VideoGame(title: "fortnite", notSelectedImage: UIImage(named: "fortnite")!,
                selectedImage: UIImage(named: "selectedFortnite")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "overwatch", notSelectedImage: UIImage(named: "overwatch")!,
                selectedImage: UIImage(named: "selectedOverwatch")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "nba 2k18", notSelectedImage: UIImage(named: "nba2k18")!,
                selectedImage: UIImage(named: "selectedNba2k18")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "battlefield 1", notSelectedImage: UIImage(named: "battlefield1")!,
                selectedImage: UIImage(named: "selectedBattlefield1")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames.append(VideoGame(title: "uncharted 4", notSelectedImage: UIImage(named: "uncharted4")!,
                selectedImage: UIImage(named: "selectedUncharted4")!, gameTypes: ["playstation"]))
        videoGames.append(VideoGame(title: "rocket League", notSelectedImage: UIImage(named: "rocketLeague")!,
                selectedImage: UIImage(named: "selectedRocketLeague")!, gameTypes: ["xbox", "playstation", "pc"]))
    }
    
    func displayGameBtns(consoleChoice: String) {
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
    
    fileprivate func createGamerMatchDBRef(console: String, game: String, role: String?) -> DatabaseReference {
        
        let ref = Database.database().reference().child(console).child(game.removingWhitespaces())
        
        if let role = role {
            ref.child(role.removingWhitespaces())
        }
        
        return ref
    }

    func createAlert(gameBtnTag: Int, roleBtnTag: Int?) {
        var message = ""
        let gameName = gamesCurrentlyDisplayed[gameBtnTag].title?.capitalizingFirstLetter()
        var roleName: String?
        
        // setup search query message to display to the user
        if let roleBtnTag = roleBtnTag {
            roleName = self.videoGameRoles[roleBtnTag].roleName?.capitalizingFirstLetter()
            
            message = "Search for gamer who plays \(gameName!.uppercased()) for \(consoleName.uppercased()) and plays \(roleName!.uppercased()) role"
        }else {
            message = "Search for gamer who plays \(gameName!.uppercased()) for \(consoleName.uppercased())"
        }
        
        // setup alert view controller
        let ac = UIAlertController(title: "Request", message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Search", style: .default){ action in
            if let gameName = gameName {
                self.searchRef = self.createGamerMatchDBRef(console: self.consoleName,
                                                     game: gameName,
                                                     role: roleName)
                print("This is the created reference : \(self.searchRef)")
                SVProgressHUD.show(withStatus: "Searching...")
                
                FirebaseCalls.shared
                    .searchForGamer(searchRef: self.searchRef) { (ids, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        self.ids = ids
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: self.findGamerResultsSegueId, sender: nil)
                }
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel){ action in
            self.gameBtnsArr[gameBtnTag].isSelected = false
        })
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func displayRoleBtns(gameChoice: String){
        if !videoGameRoles.isEmpty {
            videoGameRoles.removeAll()
        }
        switch gameChoice {
        case "overwatch":
            videoGameRoles.append(VideoGameRole(roleName: "offense", roleImg: UIImage(named: "offenseOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedOffenseOverwatchRole")!))
            videoGameRoles.append(VideoGameRole(roleName: "defense", roleImg: UIImage(named: "defenseOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedDefenseOverwatchRole")!))
            videoGameRoles.append(VideoGameRole(roleName: "support", roleImg: UIImage(named: "supportOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedSupportOverwatchRole")!))
            videoGameRoles.append(VideoGameRole(roleName: "tank", roleImg: UIImage(named: "tankOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedTankOverwatchRole")!))
            
            
        case "nba 2k18":
            videoGameRoles.append(VideoGameRole(roleName: "point gaurd", roleImg: UIImage(named: "pgNba2k18")!, selectedRoleImg: UIImage(named: "selectedPgNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "shooting gaurd", roleImg: UIImage(named: "sgNba2k18")!, selectedRoleImg: UIImage(named: "selectedSgNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "small forward", roleImg: UIImage(named: "sfNba2k18")!, selectedRoleImg: UIImage(named: "selectedSfNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "power forward", roleImg: UIImage(named: "pfNba2k18")!, selectedRoleImg: UIImage(named: "selectedPfNba2k18")!))
            videoGameRoles.append(VideoGameRole(roleName: "center", roleImg: UIImage(named: "cNba2k18")!, selectedRoleImg: UIImage(named: "selectedCNba2k18")!))
        default:
            return
        }
        
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
        if sender.tag == 0 {
            print("Xbox was pressed...")
            consoleName = "Xbox"
            displayGameBtns(consoleChoice: "xbox")
        }else if sender.tag == 1 {
            print("Playstation was pressed...")
            consoleName = "Playstation"
            displayGameBtns(consoleChoice: "playstation")
        }else {
            print("PC was pressed...")
            consoleName = "PC"
            displayGameBtns(consoleChoice: "pc")
        }
        
    }
    
    @IBAction func gameBtnPressed(_ sender: UIButton) {
        if gameWithRolesTapped {
            bottomText.isHidden = true
            roleBtnsArr.hideButtons()
            selectedVideogameBtnPressed?.isSelected = false
        }
        
        let gameChoice = gamesCurrentlyDisplayed[sender.tag].title!
        selectedVideogameBtnPressed = sender
        print("\(gameChoice) was selected")
        sender.isSelected = true
        
        switch gameChoice {
        case "overwatch", "battlefield 1", "nba 2k18", "league Of Legends":
            bottomText.isHidden = false
            displayRoleBtns(gameChoice: gameChoice)
            gameWithRolesTapped = true
        default:
            print("Create an alert to start query search...")
            createAlert(gameBtnTag: sender.tag, roleBtnTag: nil)
        }
        
    }
    
    @IBAction func roleBtnPressed(_ sender: UIButton){
        createAlert(gameBtnTag: (selectedVideogameBtnPressed?.tag)!, roleBtnTag: sender.tag)
    }
    
    @IBAction func openMenu(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor) {
            self.performSegue(withIdentifier: "openMenu", sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SideMenuViewController {
            destinationViewController.transitioningDelegate = self
            
            // pass the interactor object forward
            destinationViewController.interactor = interactor
        } else if let destinationViewController = segue.destination as? FindGamerResultsViewController {
            destinationViewController.gamerMatchRef = searchRef
            destinationViewController.resultIds = ids
        }
    }
    

}












