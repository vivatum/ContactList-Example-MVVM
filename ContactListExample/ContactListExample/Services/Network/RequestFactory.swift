//
//  RequestFactory.swift
//  ContactListExample
//
//  Created by Vivatum on 24/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation

final class RequestFactory {
    
    enum Method: String {
        case GET
        case POST
        case PUT
        case DELETE
        case PATCH
    }
    
    static func request(method: Method, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
