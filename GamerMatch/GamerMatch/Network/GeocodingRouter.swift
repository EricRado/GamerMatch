//
//  GeocodingRouter.swift
//  GamerMatch
//
//  Created by Eric Rado on 5/8/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Alamofire

public enum GeocodingRouter: URLRequestConvertible {
    public enum Constants {
        static let baseURLPath = "https://maps.googleapis.com/maps/api/geocode/json"
        static let authenticationToken = "AIzaSyAUXP-io2FQ_39qNGnuwAfA6fIMz5D3DY0"
    }
    
    case geocoding(String)
    
    var parameters: [String: Any] {
        switch self {
        case .geocoding(let address):
            return ["key": Constants.authenticationToken, "address": address]
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURLPath.asURL()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
