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
    
    // store the user's selcted consoles
    private var selectedConsoles = [ConsoleType]()
    
    private var selectedVideoGame: VideoGameSelected?
    
    // store the user's selected video games
    private var selectedVideoGames = [String: VideoGameSelected]()
    
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
    @IBOutlet weak var bioTextView: UITextView!
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
            print("game already in dict")
            selectedVideoGame = game
            
        } else {
            print("game not in dict")
            selectedVideoGame = VideoGameSelected()
            selectedVideoGame?.selectedConsoles = Set<ConsoleType>()
            selectedVideoGame?.selectedRoles = [VideoGameRole]()
            selectedVideoGame?.videoGame = buttonTagToVideoGameDict[tag]
        }
    }
    
    @objc fileprivate func gameBtnPressed(sender: UIButton) {
        checkIfVideoGameWasAlreadySelected(tag: sender.tag)
        selectedVideoGameBtnTag = sender.tag
        
        // check if video game is only available for 1 console type
        if let consoles = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.gameTypes, consoles.count == 1 {
            print("game has only one console type")
            guard let title = selectedVideoGame?.videoGame?.title else { return }
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
    
    @objc fileprivate func submitBtnPressed(sender: UIButton) {
        if selectedConsoles.isEmpty {
            print("At least one console must be selected to move on")
            return
        }
        if selectedVideoGames.isEmpty {
            print("At least one game must be selected to move on")
            return
        }
        print("the selected games are ...")
        for game in selectedVideoGames {
            print(game.value.videoGame)
            print(game.value.selectedConsoles)
            print(game.value.selectedRoles)
        }
    }
    
    @objc fileprivate func confirmFromPopupPressed(sender: UIButton) {
        gameSelectedOptionsView.removeFromSuperview()
        print(selectedVideoGame)
        
        guard let title = selectedVideoGame?.videoGame?.title else { return }
        guard !(selectedVideoGame?.selectedConsoles?.isEmpty)! else { return }
        
        // if the selected video game does not have any roles
        // just store the selected console types
        guard ((selectedVideoGame?.videoGame?.roles) != nil) else {
            selectedVideoGames[title] = selectedVideoGame
            print(selectedVideoGames)
            gameBtns[selectedVideoGameBtnTag].isSelected = true
            return
        }
        
        if let roles = selectedVideoGame?.selectedRoles, !roles.isEmpty {
            print("selected roles is not empty")
            selectedVideoGames[title] = selectedVideoGame
            gameBtns[selectedVideoGameBtnTag].isSelected = true
        }
        
        print(selectedVideoGames)
    }
    
    @objc fileprivate func removeFromPopupPressed(sender: UIButton) {
        print("remove pressed")
        gameSelectedOptionsView.removeFromSuperview()
        guard let title = selectedVideoGame?.videoGame?.title else { return }
        selectedVideoGames.removeValue(forKey: title)
        gameBtns[selectedVideoGameBtnTag].isSelected = false
        
    }

}

// MARK: - Table View Delegate Helper Functions
extension GameAndConsoleSelectionViewController {
    fileprivate func insertConsoleTypeTableViewSelection(row: Int) {
        let consoleType: ConsoleType
        switch buttonTagToConsoleDict[row]?.name {
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
        let consoleType: ConsoleType
        switch buttonTagToConsoleDict[row]?.name {
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
        if section == 0 {
            return 3
        }
        
        return selectedVideoGame?.videoGame?.roles?.count ?? 0
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.section == 0 {
            guard let console = buttonTagToConsoleDict[indexPath.row] else { return cell }
            cell.textLabel?.text = console.name
            guard let consoles = selectedVideoGame?.selectedConsoles else { return cell }
            if consoles.contains(ConsoleType.init(rawValue: console.name)!) {
                cell.accessoryType = .checkmark
            }
        }
        
        if indexPath.section == 1 {
            guard let videoGame = buttonTagToVideoGameDict[selectedVideoGameBtnTag]
                else { return cell }
            guard let roles = videoGame.roles else { return cell }
    
            cell.textLabel?.text = roles[indexPath.row].roleName
            guard let selectedRoles = selectedVideoGames[videoGame.title!]?.selectedRoles
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






















