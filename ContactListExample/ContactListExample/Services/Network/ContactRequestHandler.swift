//
//  ContactRequestHandler.swift
//  ContactListExample
//
//  Created by Vivatum on 25/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack

class ContactRequestHandler {
    
    func parseContactData(_ contactData: Data, completion: @escaping (Result<[Contact], ActionError>) -> Void) {
        
        let decoder = JSONDecoder()
        DispatchQueue.global(qos: .background).async(execute: {
            do {
                let contactDataStore = try decoder.decode(ContactDataStore.self, from: contactData)
                completion(.success(contactDataStore.results))
                DDLogInfo("Contact data parsed successfully")
            } catch {
                let errorMessage = "Can't parse Contact List: \(error.localizedDescription)"
                DDLogError(errorMessage)
                completion(.failure(.parser(errorMessage)))
            }
        })
    }
}
