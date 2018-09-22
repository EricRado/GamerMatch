//
//  VideoGameRepo.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/21/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

class VideoGameRepo {
    static var shared = VideoGameRepo()
    
    private var videoGames: [VideoGame]?
    
    private init() {}
    
    fileprivate func populateRepo() {
        videoGames?.append(VideoGame(title: "halo5", notSelectedImage: UIImage(named: "halo5")!, selectedImage: UIImage(named: "selectedHalo5")!, gameTypes: ["xbox"]))
        videoGames?.append(VideoGame(title: "league Of Legends", notSelectedImage: UIImage(named: "leagueOfLegends")!,
                                    selectedImage: UIImage(named: "selectedLeagueOfLegends")!, gameTypes: ["pc"]))
        videoGames?.append(VideoGame(title: "fortnite", notSelectedImage: UIImage(named: "fortnite")!,
                                    selectedImage: UIImage(named: "selectedFortnite")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames?.append(VideoGame(title: "overwatch", notSelectedImage: UIImage(named: "overwatch")!,
                                    selectedImage: UIImage(named: "selectedOverwatch")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames?.append(VideoGame(title: "nba 2k18", notSelectedImage: UIImage(named: "nba2k18")!,
                                    selectedImage: UIImage(named: "selectedNba2k18")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames?.append(VideoGame(title: "battlefield 1", notSelectedImage: UIImage(named: "battlefield1")!,
                                    selectedImage: UIImage(named: "selectedBattlefield1")!, gameTypes: ["xbox", "playstation", "pc"]))
        videoGames?.append(VideoGame(title: "uncharted 4", notSelectedImage: UIImage(named: "uncharted4")!,
                                    selectedImage: UIImage(named: "selectedUncharted4")!, gameTypes: ["playstation"]))
        videoGames?.append(VideoGame(title: "rocket League", notSelectedImage: UIImage(named: "rocketLeague")!,
                                    selectedImage: UIImage(named: "selectedRocketLeague")!, gameTypes: ["xbox", "playstation", "pc"]))
    }
    
    func getRepo() -> [VideoGame]? {
        return videoGames
    }
}
