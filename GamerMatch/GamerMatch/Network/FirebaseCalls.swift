//
//  FirebaseCalls.swift
//  GamerMatch
//
//  Created by Eric Rado on 6/10/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

class FirebaseCalls {
    let dbRef = Database.database().reference()
    
    static var firebaseCall = FirebaseCalls()
    
    private init () {
        
    }
    
    func searchForGamer(consoleChoice: String, gameChoice: String, roleChoice: String?) {
        print("consoleChoice: \(consoleChoice)   gameChoice: \(gameChoice)")
        print("newGameChoice string : \(gameChoice.removingWhitespaces())")
        var searchRef: DatabaseReference
        
        // check if search query message contains a role choice or not
        if let roleChoice = roleChoice {
            searchRef = dbRef.child("\(consoleChoice)/\(gameChoice.removingWhitespaces())/\(roleChoice)")
        }else {
            searchRef = dbRef.child("\(consoleChoice)/\(gameChoice.removingWhitespaces())")
        }
        
        // retrieve data based on the database reference created
        searchRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
}
