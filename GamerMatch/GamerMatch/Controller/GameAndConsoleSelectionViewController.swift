//
//  GameAndConsoleSelectionViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/21/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class GameAndConsoleSelectionViewController: UIViewController {
    
    // MARK: - Instance variables
    
    private let cellId = "cellId"
    
    // store the user's selcted consoles
    private var selectedConsoles = [ConsoleType]()
    
    private var selectedVideoGame: VideoGameSelected?
    private var selectedVideoGameConsoles: [ConsoleType]?
    private var selectedVideoGameRoles: [VideoGameRole]?
    
    // store the user's selected video games
    private var selectedVideoGames = [VideoGameSelected]()
    
    private var buttonTagToConsoleDict = [Int: Console]()
    private var buttonTagToVideoGameDict = [Int: VideoGame]()
    private var selectedVideoGameBtnTag = 0
    
    // MARK: - IBOutlet variables
    
    @IBOutlet var gameSelectedOptionsView: UIView! {
        didSet {
            gameSelectedOptionsView.layer.cornerRadius = 5
        }
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedVideoGameConsoles = [ConsoleType]()
        selectedVideoGameRoles = [VideoGameRole]()
        selectedVideoGames = [VideoGameSelected]()
    }
    
    @objc fileprivate func consoleBtnPressed(sender: UIButton) {
        let console = buttonTagToConsoleDict[sender.tag]
        
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
    
    @objc fileprivate func gameBtnPressed(sender: UIButton) {
        print("game btn pressed with tag: \(sender.tag)")
        print("game pressed : \(buttonTagToVideoGameDict[sender.tag]!)")
        selectedVideoGame = VideoGameSelected()
        selectedVideoGame?.videoGame = buttonTagToVideoGameDict[sender.tag]
        selectedVideoGameBtnTag = sender.tag
        tableView.reloadData()
        view.addSubview(gameSelectedOptionsView)
        gameSelectedOptionsView.center = view.center
    }
    
    @objc fileprivate func submitBtnPressed(sender: UIButton) {
        if selectedConsoles.isEmpty {
            print("At least one console must be selected to move on")
            return
        }
    }
    
    @objc fileprivate func confirmFromPopupPressed(sender: UIButton) {
        gameSelectedOptionsView.removeFromSuperview()
        print(selectedVideoGame)
        if let consoles = selectedVideoGameConsoles, !consoles.isEmpty {
            selectedVideoGame?.selectedConsoles = consoles
        } else {
            selectedVideoGame = nil
            return
        }
        guard ((selectedVideoGame?.selectedRoles) != nil) else {
            selectedVideoGames.append(selectedVideoGame!)
            print(selectedVideoGames)
            selectedVideoGame = nil
            gameBtns[selectedVideoGameBtnTag].isSelected = true
            return
        }
        
        if let roles = selectedVideoGameRoles, !roles.isEmpty {
            selectedVideoGame?.selectedRoles = roles
            selectedVideoGames.append(selectedVideoGame!)
            selectedVideoGame = nil
            gameBtns[selectedVideoGameBtnTag].isSelected = true
        } else { return }
        
        print(selectedVideoGames)
    }

}

// MARK: - TableView Delegate

extension GameAndConsoleSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if indexPath.section == 0 {
            switch buttonTagToConsoleDict[indexPath.row]?.name {
            case ConsoleType.Xbox.rawValue:
                selectedVideoGameConsoles?.append(ConsoleType.Xbox)
            case ConsoleType.Playstation.rawValue:
                selectedVideoGameConsoles?.append(ConsoleType.Playstation)
            case ConsoleType.PC.rawValue:
                selectedVideoGameConsoles?.append(ConsoleType.PC)
            default:
                return
            }
        } else {
            guard let role = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles?[indexPath.row] else { return }
            selectedVideoGameRoles?.append(role)
        }
        
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
        guard let roles = buttonTagToVideoGameDict[selectedVideoGameBtnTag]?.roles else {
            return 3
        }
        if section == 1 {
            return roles.count
        }
        
        return 3
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        guard let videoGame = buttonTagToVideoGameDict[selectedVideoGameBtnTag]
            else { return cell }
        
        let result = selectedVideoGames.filter {$0.videoGame?.title == videoGame.title}
        
        if let previousSelection = result.first {
            print(previousSelection)
            
        }
        
        if indexPath.section == 0 {
            cell.textLabel?.text = buttonTagToConsoleDict[indexPath.row]?.name
        }
        
        if indexPath.section == 1 {
            guard let roles = videoGame.roles
                else { return cell }
            cell.textLabel?.text = roles[indexPath.row].roleName
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






















