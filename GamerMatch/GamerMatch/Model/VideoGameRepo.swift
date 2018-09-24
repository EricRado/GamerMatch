//
//  VideoGameRepo.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/21/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

enum ConsoleType: String {
    case Xbox = "Xbox"
    case Playstation = "Playstation"
    case PC = "PC"
}

struct Console {
    let name: String
    var notSelectedImage: UIImage?
    var selectedImage: UIImage?
    
    init(name: String, notSelectedImage: UIImage?, selectedImage: UIImage?) {
        self.name = name
        self.notSelectedImage = notSelectedImage
        self.selectedImage = selectedImage
    }
}

class VideoGameRepo {
    static var shared = VideoGameRepo()
    
    private var consoles: [Console]?
    
    private var videoGames: [VideoGame]?
    
    private var overwatchRoles: [VideoGameRole]?
    private var nba2k18Roles: [VideoGameRole]?
    private var battlefieldRoles: [VideoGameRole]?
    private var lolRoles: [VideoGameRole]?
    
    private init() {
        consoles = [Console]()
        videoGames = [VideoGame]()
        overwatchRoles = [VideoGameRole]()
        nba2k18Roles = [VideoGameRole]()
        battlefieldRoles = [VideoGameRole]()
        lolRoles = [VideoGameRole]()
        
        setConsoles()
        setVideoGameRoles()
        populateRepo()
    }
    
    fileprivate func setConsoles() {
        consoles?.append(Console(name: "Xbox", notSelectedImage: UIImage(named: "xbox"), selectedImage: UIImage(named: "selectedXbox")))
        consoles?.append(Console(name: "Playstation", notSelectedImage: UIImage(named: "playstation"), selectedImage: UIImage(named: "selectedPlaystation")))
        consoles?.append(Console(name: "PC", notSelectedImage: UIImage(named: "pc"), selectedImage: UIImage(named: "selectedPC")))
    }
    
    fileprivate func setVideoGameRoles() {
        // setup role types for overwatch
        overwatchRoles?.append(VideoGameRole(roleName: "Offense", roleImg: UIImage(named: "offenseOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedOffenseOverwatchRole")!))
        overwatchRoles?.append(VideoGameRole(roleName: "Defense", roleImg: UIImage(named: "defenseOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedDefenseOverwatchRole")!))
        overwatchRoles?.append(VideoGameRole(roleName: "Support", roleImg: UIImage(named: "supportOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedSupportOverwatchRole")!))
        overwatchRoles?.append(VideoGameRole(roleName: "Tank", roleImg: UIImage(named: "tankOverwatchRole")!, selectedRoleImg: UIImage(named: "selectedTankOverwatchRole")!))
        
        // setup role types for nba2k18
        nba2k18Roles?.append(VideoGameRole(roleName: "Point Gaurd", roleImg: UIImage(named: "pgNba2k18")!, selectedRoleImg: UIImage(named: "selectedPgNba2k18")!))
        nba2k18Roles?.append(VideoGameRole(roleName: "Shooting Gaurd", roleImg: UIImage(named: "sgNba2k18")!, selectedRoleImg: UIImage(named: "selectedSgNba2k18")!))
        nba2k18Roles?.append(VideoGameRole(roleName: "Small Forward", roleImg: UIImage(named: "sfNba2k18")!, selectedRoleImg: UIImage(named: "selectedSfNba2k18")!))
        nba2k18Roles?.append(VideoGameRole(roleName: "Power Forward", roleImg: UIImage(named: "pfNba2k18")!, selectedRoleImg: UIImage(named: "selectedPfNba2k18")!))
        nba2k18Roles?.append(VideoGameRole(roleName: "Center", roleImg: UIImage(named: "cNba2k18")!, selectedRoleImg: UIImage(named: "selectedCNba2k18")!))
        
        // setup role types for battlefield
        battlefieldRoles?.append(VideoGameRole(roleName: "Recon", roleImg: UIImage(named: "reconBFRole")!, selectedRoleImg: UIImage(named: "selectedReconBFRole")!))
        battlefieldRoles?.append(VideoGameRole(roleName: "Engineer", roleImg: UIImage(named: "engineerBFRole")!, selectedRoleImg: UIImage(named: "selectedEngineerBFRole")!))
        battlefieldRoles?.append(VideoGameRole(roleName: "Support", roleImg: UIImage(named: "supportBFRole")!, selectedRoleImg: UIImage(named: "selectedSupportBFRole")!))
        battlefieldRoles?.append(VideoGameRole(roleName: "Assault", roleImg: UIImage(named: "assaultBFRole")!, selectedRoleImg: UIImage(named: "selectedAssaultBFRole")!))
        
        // setup role types for league of legends
        lolRoles?.append(VideoGameRole(roleName: "Ad Carry", roleImg: UIImage(named: "adCarryLOLRole")!, selectedRoleImg: UIImage(named: "selectedAdCarryLOLRole")!))
        lolRoles?.append(VideoGameRole(roleName: "Support", roleImg: UIImage(named: "supportLOLRole")!, selectedRoleImg: UIImage(named: "selectedSupportLOLRole")!))
        lolRoles?.append(VideoGameRole(roleName: "Jungler", roleImg: UIImage(named: "junglerLOLRole")!, selectedRoleImg: UIImage(named: "selectedJunglerLOLRole")!))
        lolRoles?.append(VideoGameRole(roleName: "Solo Mid", roleImg: UIImage(named: "soloMidLOLRole")!, selectedRoleImg: UIImage(named: "selectedSoloMidLOLRole")!))
        lolRoles?.append(VideoGameRole(roleName: "Solo Top", roleImg: UIImage(named: "soloTopLOLRole")!, selectedRoleImg: UIImage(named: "selectedSoloTopLOLRole")!))
    }
    
    fileprivate func populateRepo() {
        videoGames?.append(VideoGame(title: "Halo 5", notSelectedImage: UIImage(named: "halo5")!, selectedImage: UIImage(named: "selectedHalo5")!, gameTypes: [.Xbox], roles: nil))
        videoGames?.append(VideoGame(title: "League Of Legends", notSelectedImage:
            UIImage(named: "leagueOfLegends")!, selectedImage:
            UIImage(named: "selectedLeagueOfLegends")!, gameTypes: [.PC], roles: lolRoles))
        videoGames?.append(VideoGame(title: "Fortnite", notSelectedImage: UIImage(named: "fortnite")!, selectedImage: UIImage(named: "selectedFortnite")!,
            gameTypes: [.Xbox, .Playstation, .PC], roles: nil))
        videoGames?.append(VideoGame(title: "Overwatch", notSelectedImage: UIImage(named: "overwatch")!, selectedImage: UIImage(named: "selectedOverwatch")!, gameTypes: [.Xbox, .Playstation, .PC], roles: overwatchRoles))
        videoGames?.append(VideoGame(title: "Nba 2k18", notSelectedImage: UIImage(named: "nba2k18")!,
            selectedImage: UIImage(named: "selectedNba2k18")!, gameTypes: [.Xbox, .Playstation, .PC], roles: nba2k18Roles))
        videoGames?.append(VideoGame(title: "Battlefield 1", notSelectedImage: UIImage(named: "battlefield1")!, selectedImage: UIImage(named: "selectedBattlefield1")!, gameTypes: [.Xbox, .Playstation, .PC], roles: battlefieldRoles))
        videoGames?.append(VideoGame(title: "Uncharted 4", notSelectedImage: UIImage(named: "uncharted4")!, selectedImage: UIImage(named: "selectedUncharted4")!, gameTypes: [.Playstation], roles: nil))
        videoGames?.append(VideoGame(title: "Rocket League", notSelectedImage: UIImage(named: "rocketLeague")!, selectedImage: UIImage(named: "selectedRocketLeague")!, gameTypes: [.Xbox, .Playstation, .PC], roles: nil))
    }
    
    func getConsoles() -> [Console]? {
        return consoles
    }
    
    func getVideoGames() -> [VideoGame]? {
        return videoGames
    }
}
