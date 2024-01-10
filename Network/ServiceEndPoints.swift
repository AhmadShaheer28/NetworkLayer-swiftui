//
//  MovieServiceEndPoint.swift
//
//  Created by Ahmad Shaheer on 22/08/2023.
//

import Foundation


typealias Headers = [String: String]

enum ServiceEndPoints {
    case fetchMovies

    
    var httpMethod: HTTPMethod {
        switch self {
        case .fetchMovies:
            return .GET
        }
    }
    
    var environment: PLEnvironment {
        return .staging
    }
    
    func createRequest(params: [String: String] = [:], kHeaders: Headers = [:], body: Encodable? = nil) -> NetworkRequest {
        var headers: Headers = kHeaders
        headers["Content-Type"] = "application/json"
        
        var url = getURL(from: environment)
        if !params.isEmpty { url = appendParams(url: url, params: params) }
        
        return NetworkRequest(url: url, headers: headers, reqBody: body, httpMethod: httpMethod)
    }
    
    
    // Appends query params to url
    func appendParams(url: String, params: [String: String]) -> String {
        var component = URLComponents(string: url)
        component?.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        
        return component?.url?.absoluteString ?? url
    }
    
    // Gets complete url according to required environment baseUrl
    func getURL(from environment: PLEnvironment) -> String {
        let baseUrl = environment.serviceBaseUrl
        
        switch self {
        case .fetchMovies:
            return "\(baseUrl)/movie/popular"
        }
    }
}
