//
//  ContactFetchService.swift
//  ContactListExample
//
//  Created by Vivatum on 25/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack

protocol ContactFetchServiceProtocol: class {
    func fetchContacts(_ completion: @escaping ((Result<[Contact], ActionError>) -> Void))
}

final class ContactFetchService: ContactRequestHandler, ContactFetchServiceProtocol {
    
    static let shared = ContactFetchService()
    private override init() {}
    
    let endpoint = "https://api.randomuser.me/?results=500&seed=vivatum2020"
    var task: URLSessionTask?
    
    func fetchContacts(_ completion: @escaping ((Result<[Contact], ActionError>) -> Void)) {
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.network("Wrong url format")))
            return
        }
        
        guard Network.isReachable else {
            let errorMessage = "Can't load Data: Network unreachable!"
            DDLogError(errorMessage)
            return completion(.failure(.network(errorMessage)))
        }
        
        self.cancelFetchContacts()
        
        task = RequestService().loadData(url: url) { result in
            switch result {
            case .success(let data):
                self.parseContactData(data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelFetchContacts() {
        guard let currentTask = task else { return }
        currentTask.cancel()
        task = nil
    }
}
