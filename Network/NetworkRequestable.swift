//
//  NetworkRequestable.swift
//
//  Created by Ahmad Shaheer on 21/08/2023.
//

import Foundation
import Combine

public class NetworkRequestable: Requestable {
    
    public var requestTimeOut: Float = 30
    
    public func request<T>(_ req: NetworkRequest) -> AnyPublisher<T, NetworkError>
    where T: Decodable, T: Encodable {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = TimeInterval(req.requestTimeOut ?? requestTimeOut)
        
        guard let url = URL(string: req.url) else {
            return AnyPublisher(
                Fail<T, NetworkError>(error: NetworkError.badURL("Invalid Url"))
            )
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: req.buildURLRequest(with: url))
            .tryMap { (output) in
                // throw an error if response is nil
                guard let response = output.response as? HTTPURLResponse else {
                    throw NetworkError.serverError(code: 500, error: "Server error")
                }
                
                if !(200..<300).contains(response.statusCode) {
                    let apiError = try JSONDecoder().decode(ErrorResponse.self, from: output.data)
                    throw NetworkError.badRequest(code: apiError.code, error: apiError.message)
                }
                
                print("json => ", String(data: output.data, encoding: .utf8) ?? "json in nil")
                
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                // return error if json decoding fails
                if let error = error as? DecodingError {
                    var errorToReport = error.localizedDescription
                    switch error {
                    case .dataCorrupted(let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) - (\(details))"
                    case .keyNotFound(let key, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
                    case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
                    @unknown default:
                        break
                    }
                    return NetworkError.invalidJSON(String(describing: errorToReport))
                } else {
                    return error as? NetworkError ?? NetworkError.unknown(code: 0, error: "unknown error")
                }
            }
            .eraseToAnyPublisher()
    }
    
}
