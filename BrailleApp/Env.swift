//
//  Environment.swift
//  BrailleApp
//
//  Created by adrian on 9/1/2026.
//

import Foundation

enum Env {
    enum Keys {
        enum Plist {
            static let apiBaseURL = "API_BASE_URL"
            static let apiPredictEndpoint = "API_PREDICT_ENDPOINT"
            static let apiTimeout = "API_TIMEOUT"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let apiBaseURL: String = {
        guard let urlString = infoDictionary[Keys.Plist.apiBaseURL] as? String else {
            fatalError("API Base URL not set in plist")
        }
        return urlString
    }()
   
    static let apiPredictEndpoint: String = {
        guard let endpoint = infoDictionary[Keys.Plist.apiPredictEndpoint] as? String else {
            return "/predict"
        }
        return endpoint
    }()
    
    static var apiURL: String {
        return apiBaseURL + apiPredictEndpoint
    }
    
    static let apiTimeout: TimeInterval = {
        guard let timeoutString = infoDictionary[Keys.Plist.apiTimeout] as? String,
              let timeout = TimeInterval(timeoutString) else {
            return 30.0
        }
        return timeout
    }()
}
