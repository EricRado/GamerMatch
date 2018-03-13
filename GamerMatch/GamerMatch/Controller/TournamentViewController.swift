//
//  TournamentViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/11/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

extension TournamentViewController: CLLocationManagerDelegate {
    
    // handle incoming location events
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        print("location : \(location)")
        
        // create a GMSCamaraPosition that tells the map to display
        // coordinate current location at zoom level 6
        let camara = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camara
        }else {
            mapView.animate(to: camara)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error : \(error)")
    }
}

class TournamentViewController: UIViewController {
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 13.0
    
    let dbRef = Database.database().reference()
    var tournaments = [Tournament]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTournaments()
        
        // setup location manager and its properties
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 3200
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        // add the GMSMapView to the view controller's view
        mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        mapView.isMyLocationEnabled = true
        
        view.addSubview(mapView)
        
        
    }
    
    func getTournaments(){
        let tournamentRef = dbRef.child("Tournaments")
        tournamentRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if !child.exists() {
                    print("Child is empty...")
                    return
                }
                print(child)
                if let tournament = Tournament(snapshot: child) {
                    self.tournaments.append(tournament)
                    self.addTournamentToMap(latitude: tournament.latitude!,
                        longitude: tournament.longitude!, name: tournament.name!,
                        id: tournament.id!)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func addTournamentToMap(latitude: String, longitude: String, name: String, id: String) {
        let marker: GMSMarker
        if let latitude = Double(latitude), let longitude = Double(longitude){
            marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude,
                            longitude: longitude))
            marker.title = name
            marker.snippet = id
            marker.map = mapView
        }
        
        
    }

}
