//
//  GameAndConsoleSelectionViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/21/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class GameAndConsoleSelectionViewController: UIViewController {
    
    // MARK: - Instance variables
    
    private let cellId = "cellId"
    private let segueId = "registrationDashboardSegue"
    private let databaseRef: DatabaseReference = {
        return Database.database().reference()
    }()
    
    // store the user's selcted consoles
    private var selectedConsoles = [ConsoleType]()
    
    // store the user's current tapped video game selection
    private var selectedVideoGame: VideoGameSelected?
    
    // store the user's selected video games after selecting console
    // and role type
    private var selectedVideoGames = [String: VideoGameSelected]()
    private var selectedVideoGameStringRefs = [String]()
    
    private var buttonTagToConsoleDict = [Int: Console]()
    private var buttonTagToVideoGameDict = [Int: VideoGame]()
    private var selectedVideoGameBtnTag = 0
    
    // MARK: - IBOutlet variables
    
    @IBOutlet var gameSelectedOptionsView: UIView! {
        didSet {
            gameSelectedOptionsView.layer.cornerRadius = 5
        }
    }
    
    // fetch the consoles available from the repo and map them with
    // a dictionary to a UIButton tag property as the key
    @IBOutlet var consoleBtns: [UIButton]! {
        didSet {
            guard let consoles = VideoGameRepo.shared.getConsoles() else { return }
            for btn in consoleBtns {
                let console = consoles[btn.tag]
                btn.addTarget(
                    self,
                    action: #selector(consoleBtnPressed(sender:)),
                    for: .touchUpInside)
                btn.setBackgroundImage(console.notSelectedImage, for: .normal)
                btn.setBackgroundImage(console.selectedImage, for: .selected)
                buttonTagToConsoleDict[btn.tag] = console
            }
        }
    }
    
    // fetch the video games available from the repo and map them
    // with a dictionary to a UIButton tag property as the key
    @IBOutlet var gameBtns: [UIButton]! {
        didSet {
            guard let games = VideoGameRepo.shared.getVideoGames() else { return }
            for btn in gameBtns {
                let videoGame = games[btn.tag]
                btn.addTarget(
                    self,
                    action: #selector(gameBtnPressed(sender:)),
                    for: .touchUpInside)
                btn.setBackgroundImage(videoGame.notSelectedImage, for: .normal)
                btn.setBackgroundImage(videoGame.selectedImage, for: .selected)
                buttonTagToVideoGameDict[btn.tag] = videoGame

            }
        }
    }
    
    @IBOutlet weak var bioTextView: UITextView! {
        didSet {
            bioTextView.layer.cornerRadius = 10
            bioTextView.text = ""
        }
    }
    
    @IBOutlet weak var submitBtn: UIButton! {
        didSet {
            submitBtn.addTarget(
                self,
                action: #selector(submitBtnPressed(sender:)),
                for: .touchUpInside)
        }
    }
    
    // displays consoles and role types available for the selected video game
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.allowsMultipleSelection = true
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var confirmPopupBtn: UIButton! {
        didSet {
            confirmPopupBtn.addTarget(
                self,
                action: #selector(confirmFromPopupPressed(sender:)),
                for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var removePopupBtn: UIButton! {
        didSet {
            removePopupBtn.addTarget(
                self,
                action: #selector(removeFromPopupPressed(sender:)),
                for: .touchUpInside)
            removePopupBtn.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedVideoGames = [String: VideoGameSelected]()
    }
    
    @objc fileprivate func consoleBtnPressed(sender: UIButton) {
        let console = buttonTagToConsoleDict[sender.tag]
        
        // check if button was previously pressed and if so
        // remove the selected console from user's selection
        if sender.isSelected {
            let result = selectedConsoles.filter { $0.rawValue != console?.name }
            selectedConsoles = result
            sender.isSelected = false
            return
        }
        
        switch console?.name {
        case ConsoleType.Xbox.rawValue:
            selectedConsoles.append(.Xbox)
        case ConsoleType.Playstation.rawValue:
            selectedConsoles.append(.Playstation)
        case ConsoleType.PC.rawValue:
            selectedConsoles.append(.PC)
        default:
            return
        }
        
        sender.isSelected = true
    }
    
    fileprivate func setupPopupView() {
        tableView.reloadData()
        gameSelectedOptionsView.frame = CGRect(x: view.center.x, y: view.center.y,
                                               width: 250.0, height: 250.0)
        if !(selectedVideoGame?.selectedConsoles?.isEmpty)! {
            confirmPopupBtn.setTitle("Update", for: .normal)
            removePopupBtn.isHidden = false
        } else {
            removePopupBtn.isHidden = true
        }
        view.addSubview(gameSelectedOptionsView)
        gameSelectedOptionsView.center = view.center
    }
    
    @objc fileprivate func dismissPopup(sender: UITapGestureRecognizer) {
        gameSelectedOptionsView.removeFromSuperview()
    }
    
    fileprivate func checkIfVideoGameWasAlreadySelected(tag: Int) {
        guard let title = buttonTagToVideoGameDict[tag]?.title else { return }
        if let game = selectedVideoGames[title] {
            selectedVideoGame = game
            
        } else {
            selectedVideoGame = VideoGameSelected()
            selectedVideoGame?.selectedConsoles = Set<ConsoleType>()
            selectedVideoGame?.selectedRoles = [VideoGameRole]()
            selectedVideoGame?.name = buttonTagToVideoGameDict[tag]?.title
        }
    }
    
    @objc fileprivate func gameBtnPressed(sender: UIButton) {
        checkIfVideoGameWasAlreadySelected(tag: sender.tag)
        selectedVideoGameBtnTag = sender.tag
        
        guard let consoles = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.consoleTypes
            else { return }
        
        // check if video game is only available for 1 console type and has no role types
        if consoles.count == 1 &&
            buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles == nil {
            guard let title = selectedVideoGame?.name else { return }
            if sender.isSelected {
                selectedVideoGames.removeValue(forKey: title)
                sender.isSelected = false
                return
            }
            selectedVideoGame?.selectedConsoles?.insert(consoles.first!)
            selectedVideoGames[title] = selectedVideoGame
            sender.isSelected = true
            return
        }
        
        setupPopupView()
    }
    
    fileprivate func parseVideoGameSelectionToDatabaseReference(videoGameName: String, consoleTypes: Set<ConsoleType>, roles: [VideoGameRole]?) -> [String] {
        var refs = [String]()
        
        for console in consoleTypes {
            let game = videoGameName.removingWhitespaces()
            if let roles = roles, !roles.isEmpty {
                for role in roles {
                    guard let role = role.roleName?.removingWhitespaces() else { continue }
                    let ref = "\(console.rawValue)/\(game)/\(role)/"
                    refs.append(ref)
                }
            } else {
                let ref = "\(console.rawValue)/\(game)/"
                refs.append(ref)
            }
        }
        
        return refs
    }
    
    // save data retrieved to Firebase and transition to dashboard
    @objc fileprivate func submitBtnPressed(sender: UIButton) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userIdDict = [userId: "true"]
        
        if selectedConsoles.isEmpty {
            print("At least one console must be selected to move on")
            return
        }
        if selectedVideoGames.isEmpty {
            print("At least one game must be selected to move on")
            return
        }
        
        // parse the selected video games to database references
        for game in selectedVideoGames {
            guard let name = game.value.name else { return }
            let refs = parseVideoGameSelectionToDatabaseReference(videoGameName: name, consoleTypes: game.value.selectedConsoles!, roles: game.value.selectedRoles)
            selectedVideoGameStringRefs.append(contentsOf: refs)
        }
        
        // save data to database
        print("all the refs")
        for ref in selectedVideoGameStringRefs {
            let gameRef = databaseRef.child(ref)
            FirebaseCalls.shared
                .updateReferenceWithDictionary(ref: gameRef, values: userIdDict)
        }
        
        // transition to user's dashboard
        
    }
    
    @objc fileprivate func confirmFromPopupPressed(sender: UIButton) {
        gameSelectedOptionsView.removeFromSuperview()
        
        guard let title = selectedVideoGame?.name else { return }
        guard !(selectedVideoGame?.selectedConsoles?.isEmpty)! else { return }
        
        // if the selected video game does not have any roles
        // just store the selected console types
        guard ((buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles) != nil) else {
            selectedVideoGames[title] = selectedVideoGame
            gameBtns[selectedVideoGameBtnTag].isSelected = true
            return
        }
        
        // if the selected video game does have roles check if
        // user selected any roles from table view
        if let roles = selectedVideoGame?.selectedRoles, !roles.isEmpty {
            selectedVideoGames[title] = selectedVideoGame
            gameBtns[selectedVideoGameBtnTag].isSelected = true
        }
    }
    
    @objc fileprivate func removeFromPopupPressed(sender: UIButton) {
        gameSelectedOptionsView.removeFromSuperview()
        
        guard let title = selectedVideoGame?.name else { return }
        selectedVideoGames.removeValue(forKey: title)
        gameBtns[selectedVideoGameBtnTag].isSelected = false
    }

}

// MARK: - Table View Delegate Helper Functions
extension GameAndConsoleSelectionViewController {
    fileprivate func insertConsoleTypeTableViewSelection(row: Int) {
        guard let availableConsoles = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.consoleTypes
            else { return }
        let consoleType: ConsoleType
        switch availableConsoles[row].rawValue {
        case ConsoleType.Xbox.rawValue:
            consoleType = .Xbox
        case ConsoleType.Playstation.rawValue:
            consoleType = .Playstation
        case ConsoleType.PC.rawValue:
            consoleType = .PC
        default:
            return
        }
        selectedVideoGame?.selectedConsoles?.insert(consoleType)
    }
    
    fileprivate func removeConsoleTypeTableViewSelection(row: Int) {
        guard let availableConsoles = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.consoleTypes
            else { return }
        let consoleType: ConsoleType
        switch availableConsoles[row].rawValue {
        case ConsoleType.Xbox.rawValue:
            consoleType = .Xbox
        case ConsoleType.Playstation.rawValue:
            consoleType = .Playstation
        case ConsoleType.PC.rawValue:
            consoleType = .PC
        default:
            return
        }
        selectedVideoGame?.selectedConsoles?.remove(consoleType)
    }
    
    fileprivate func insertRoleTypeTableViewSelection(row: Int) {
        guard let role = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles?[row] else { return }
        selectedVideoGame?.selectedRoles?.append(role)
    }
    
    fileprivate func removeRoleTypeTableViewSelection(row: Int) {
        guard let role = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles?[row] else { return }
        let results = selectedVideoGame?.selectedRoles?.filter { $0.roleName != role.roleName }
        selectedVideoGame?.selectedRoles = results
    }
}

// MARK: - TableView Delegate

extension GameAndConsoleSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.accessoryType == .checkmark {
            if indexPath.section == 0 {
                removeConsoleTypeTableViewSelection(row: indexPath.row)
            } else {
                removeRoleTypeTableViewSelection(row: indexPath.row)
            }
            
            tableView.deselectRow(at: indexPath, animated: false)
            cell?.accessoryType = .none
            return
        }
        
        if indexPath.section == 0 {
            insertConsoleTypeTableViewSelection(row: indexPath.row)
        } else {
            insertRoleTypeTableViewSelection(row: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        cell?.accessoryType = .checkmark
    }
}

// MARK: - TableView Datasource

extension GameAndConsoleSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard ((buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles) != nil)
            else { return 1 }
    
        return 2
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        guard let videoGame = buttonTagToVideoGameDict[selectedVideoGameBtnTag]
            else { return 0 }
        
        // video game is only available for 1 console type
        if section == 0 && videoGame.consoleTypes.count == 1 {
            return 1
        }
        if section == 0 {
            return 3
        }
        
        return videoGame.roles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let videoGame = buttonTagToVideoGameDict[selectedVideoGameBtnTag]
            else { return cell }
        
        if indexPath.section == 0 {
            let console = videoGame.consoleTypes[indexPath.row]
            cell.textLabel?.text = console.rawValue
            
            // set checkmarks for consoles that were previously selected
            guard let consoles = selectedVideoGame?.selectedConsoles else { return cell }
            if consoles.contains(console) {
                cell.accessoryType = .checkmark
            }
        }
        
        if indexPath.section == 1 {
            guard let roles = videoGame.roles else { return cell }
            cell.textLabel?.text = roles[indexPath.row].roleName
            
            // set checkmarks for roles that were previously selected
            guard let selectedRoles = selectedVideoGame?.selectedRoles
                else { return cell }
            let results = selectedRoles
                .filter { $0.roleName == roles[indexPath.row].roleName}
            if results.first != nil { cell.accessoryType = .checkmark }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Console Choices" }
        if buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles != nil {
            return "Role Choices"
        }
        return ""
    }
    
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}






















