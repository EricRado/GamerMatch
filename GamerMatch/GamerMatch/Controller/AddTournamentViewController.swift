//
//  AddTournamentViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 5/8/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import CoreLocation

extension UIViewController {
    func printJSONPretty(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers){
            if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted){
                print(String(bytes: prettyPrintedData, encoding: String.Encoding.utf8) ?? "Nil" )
            }
        }
    }
}

class AddTournamentViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet var photoBtnArr: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        validateLocation("6761 Nw 193rd Lane, Hialeah, FL") { complete in
            if complete {
                print("Address was finished validating...")
            }else {
                print("Address was not validated...")
            }
        }
    }
    
    func parseLocation() -> String? {
        var location: String? = nil
        
        // check if user input a text into the location component text fields
        // else raise an error display through AlertViewController
        guard let address = addressTextField.text else {
            print("No address entered")
            return location
        }
        
        guard let city = cityTextField.text else {
            print("No city entered")
            return location
        }
        
        guard let state = stateTextField.text else {
            print("No state entered")
            return location
        }
        
        // will contain all the componenets of an address street, city , and state
        let locationComponents = [address, city, state]
        
        location = locationComponents.joined(separator: ",")
        
        print("This is the parsed location \(location!)")
        
        
        return location
    }
    
    func validateLocation(_ location: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(GeocodingRouter.geocoding(location))
            .responseJSON { response in
                guard response.result.isSuccess, let value = response.result.value else {
                    print("Error while validating address: \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                
                let status = JSON(value)["status"].stringValue
                let latitude = JSON(value)["results"][0]["geometry"]["location"]["lat"].stringValue
                let longitude = JSON(value)["results"][0]["geometry"]["location"]["lng"].stringValue
                
                if status == "OKAY" {
                    self.uploadCoordinates(latitude: latitude, longitude: longitude)
                }
                
                if let data = response.data {
                    self.printJSONPretty(data)
                }
                
                completion(true)
        }
    }
    
    func validateLocation2(_ location: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let placemarks = placemarks,
                let validLocation = placemarks.first?.location else{
                    print("No valid location found")
                    return
            }
            let latitude = validLocation.coordinate.latitude
            let longitude = validLocation.coordinate.longitude
            
            print("This location latitude: \(latitude) & longitude: \(longitude)")
        }
    }
    
    func uploadCoordinates(latitude: String, longitude: String) {
        
    }
    
    
    
    @IBAction func addTournamentPressed(_ sender: UIButton) {
        guard let address = parseLocation() else {return}
        
        validateLocation(address) { complete in
            if complete {
                print("Address was validated successfully")
            }else {
                print("Address is not valid")
            }
        }
        validateLocation2(address)
    }
    
    @IBAction func addPhotoPressed(_ sender: UIButton) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
