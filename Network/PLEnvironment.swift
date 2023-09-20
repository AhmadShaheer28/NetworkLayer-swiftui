//
//  Environment.swift
//
//  Created by Ahmad Shaheer on 22/08/2023.
//

import Foundation


public enum PLEnvironment: String, CaseIterable {
    case staging
    case production
}

extension PLEnvironment {
    var serviceBaseUrl: String {
        switch self {
        case .staging:
            return "https://api.themoviedb.org/3"
        case .production:
            return "https://api.themoviedb.org/3"
        }
    }
}
