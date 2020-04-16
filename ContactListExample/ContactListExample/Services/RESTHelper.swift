//
//  RESTService.swift
//  ContactListExample
//
//  Created by Vivatum on 15/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Alamofire
import SwiftyJSON

struct RESTHelper {

    static func loadContactListData(resultHandler: @escaping ((Result<[Contact]?, ActionError>) -> Void)) {
        
        let endpoint = "https://api.randomuser.me/?results=500&seed=vivatum2020"
        
        guard Network.isReachable else {
            let errorMessage = "Can't load Data: Network unreachable!"
            DDLogError(errorMessage)
            return resultHandler(.failure(.network(errorMessage)))
        }
        
        AF.request(endpoint, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success(let data):
                    
                    guard let contactDataArray = JSON(data)[JSONKey.results].arrayObject else {
                        let errorMessage = "Can't parse Contact response data"
                        DDLogError(errorMessage)
                        return resultHandler(.failure(.parser(errorMessage)))
                    }
                    
                    guard let contactList = ParseHelper.parseContactList(contactDataArray) else {
                        let errorMessage = "Can't parse Contact List"
                        DDLogError(errorMessage)
                        return resultHandler(.failure(.parser(errorMessage)))
                    }
                    
                    return resultHandler(.success(contactList))
                    
                case .failure(let error):
                    let errorMessage = "Can't get Contact response Data: \(error.localizedDescription)"
                    DDLogError(errorMessage)
                    return resultHandler(.failure(.parser(errorMessage)))
                }
        }
    }
    
}

