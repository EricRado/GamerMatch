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

extension TournamentViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker Id ...")
        print(marker.markerId)
        createAlert(title: marker.title!, id: marker.markerId)
        return true
    }
    
}

struct AssociatedKeys {
    static var toggleState: UInt8 = 0
}

extension GMSMarker {
    var markerId: String {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.toggleState) as? String else {
                return ""
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.toggleState, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class TournamentViewController: UIViewController {
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 13.0
    
    let dbRef = Database.database().reference()
    var tournamentsDict = [String: Tournament]()

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
        mapView.delegate = self
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
                    self.tournamentsDict[tournament.id!] = tournament
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
            marker.markerId = id
            marker.map = mapView
        }
        
    }
    
    func createAlert(title: String, id: String) {
        let ac = UIAlertController(title: title, message: "HELLOOOO", preferredStyle: .alert)
        
        // when more info is pressed leads to another screen, displays all of the tournament info
        ac.addAction(UIAlertAction(title: "More Info", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
    }

}
