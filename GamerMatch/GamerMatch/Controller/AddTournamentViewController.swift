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

class AddTournamentViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet var photoBtnArr: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        validateAddress(address: "6761 Nw 193rd Lane, Hialeah, FL") { complete in
            if complete {
                print("Address was finished validating...")
            }else {
                print("Address was not validated...")
            }
        }
    }
    
    func validateAddress(address: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(GeocodingRouter.geocoding(address))
            .responseJSON { response in
                guard response.result.isSuccess, let value = response.result.value else {
                    print("Error while validating address: \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                
                let status = JSON(value)["status"].stringValue
                let latitude = JSON(value)["results"][0]["geometry"]["location"]["lat"].stringValue
                let longitude = JSON(value)["results"][0]["geometry"]["location"]["lng"].stringValue
                print("This is latitude \(latitude)")
                print("This is longitude \(longitude)")
                print("This is the status \(status)")
                
                if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers){
                    if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted){
                        print(String(bytes: prettyPrintedData, encoding: String.Encoding.utf8) ?? "Nil" )
                    }
                }
                
                completion(true)
        }
    }
    
    func uploadCoordinates(latitude: String, longitude: String) {
        
    }
    
    
    
    @IBAction func addTournamentPressed(_ sender: UIButton) {
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
