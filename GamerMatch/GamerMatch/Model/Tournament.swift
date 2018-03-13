//
//  Tournament.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/13/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

class Tournament {
    var id: String?
    var hostId: String?
    var name: String?
    var details: String?
    var latitude: String?
    var longitude: String?
    var address: String?
    var city: String?
    var state: String?
    
    init(id: String, hostId: String, name: String, details: String, latitude: String?, longitude: String, address: String, city: String, state: String) {
        self.id = id
        self.hostId = hostId
        self.name = name
        self.details = details
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.state = state
    }
    
    init?(snapshot: DataSnapshot){
        print("RUNNING SNAPSHOT INIT")
        print(snapshot)
        guard let dict = snapshot.value as? [String: String] else {return nil}
        
        guard let id = dict["id"] else {return nil}
        guard let hostId = dict["hostId"] else {return nil}
        guard let name = dict["name"] else {return nil}
        guard let details = dict["details"] else {return nil}
        guard let latitude = dict["latitude"] else {return nil}
        guard let longitude = dict["longitude"] else {return nil}
        guard let address = dict["address"] else {return nil}
        guard let city = dict["city"] else {return nil}
        guard let state = dict["state"] else {return nil}
        
        self.id = id
        self.hostId = hostId
        self.name = name
        self.details = details
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.state = state
        
    }
    
    func toAnyObject() -> [AnyHashable: Any] {
        return ["id": id!, "hostId": hostId!, "name": name!, "details": details!, "latitude": latitude!, "longitude": longitude!, "address": address!, "city": city!, "state": state!] as [AnyHashable: Any]
    }
    
    
    
}
