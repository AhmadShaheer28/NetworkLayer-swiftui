//
//  Requestable.swift
//
//  Created by Ahmad Shaheer on 21/08/2023.
//

import Foundation
import Combine

public protocol Requestable {
    var requestTimeOut: Float { get }
    
    func request<T: Codable>(_ req: NetworkRequest) -> AnyPublisher<T, NetworkError>
}
