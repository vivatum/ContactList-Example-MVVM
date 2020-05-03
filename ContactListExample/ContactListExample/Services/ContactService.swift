//
//  ContactService.swift
//  ContactListExample
//
//  Created by Vivatum on 14/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack
import RealmSwift
import Contacts

protocol ContactServiceProtocol: class {
    func updateLocalCollection(_ completion: @escaping ((Result<String, ActionError>) -> Void))
    func getTableData(_ contacts: Results<Contact>?, _ selectFavorited: Bool) -> TableViewData
    func getContactValue(by indexPath: IndexPath, _ tableData: TableViewData, _ completion: @escaping ((Result<CNContact, ActionError>) -> Void))
    func getUpdatedIndexPath(_ updatedContact: Contact, _ tableData: TableViewData) -> IndexPath?
}

final class ContactService: ContactServiceProtocol {
    
    static let shared = ContactService(cnHelper: ContactValueHelper())
    private var cnContactHelper: ContactValueProtocol?
    
    private init(cnHelper: ContactValueProtocol){
        self.cnContactHelper = cnHelper
    }
    
    
    public func updateLocalCollection(_ completion: @escaping ((Result<String, ActionError>) -> Void)) {
        DDLogInfo("Start update local collection")
        
        ContactFetchService.shared.fetchContacts { result in
            switch result {
            case .success(let collection):
                DDLogInfo("Load contact list Success")
                
                RealmService.shared.synchronizeCollection(collection) { result in
                    switch result {
                    case .success(let message):
                        DDLogInfo("Local Contact collection synchronized")
                        completion(.success(message))
                    case .failure(let error):
                        DDLogError("Can't synchronize Contact collection: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                DDLogError("Can't load Contact list: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Get TableViewData
    
    public func getTableData(_ contacts: Results<Contact>?, _ selectFavorited: Bool) -> TableViewData {
        
        var dataSource = [String : Results<Contact>]()
        
        guard var collection = contacts, !collection.isEmpty else {
            DDLogInfo("Contact collection is empty")
            return TableViewData(headers: [String](), content: dataSource)
        }
        
        if selectFavorited {
            let predicate = NSPredicate(format: "\(ContactKey.isFavoritedKey.rawValue) == %d", true)
            collection = collection.filter(predicate)
        }
        
        guard let sectionHeaders = self.getHeaders(collection)?.sorted(by: <) else {
            DDLogInfo("Can't get Section Headers")
            return TableViewData(headers: [String](), content: dataSource)
        }
        
        sectionHeaders.forEach({ header in
            let predicate = NSPredicate(format: "\(ContactKey.lastNameKey.rawValue) BEGINSWITH[cd] %@", header)
            dataSource[header] = collection.filter(predicate).sorted(by: ["lastName", "firstName"])
        })
        
        return TableViewData(headers: sectionHeaders, content: dataSource)
    }
    
    private func getHeaders(_ contacts: Results<Contact>) -> [String]? {
        guard let lastNames = contacts.value(forKey: ContactKey.lastNameKey.rawValue) as? [String] else {
            DDLogError("Can't get lastName collection")
            return nil
        }
        
        let charSet = Set(lastNames.map({ String($0.prefix(1)) }))
        return Array(charSet).sorted(by: <)
    }
    
    
    // MARK: - Get Contact by IndexPath
    
    public func getContactValue(by indexPath: IndexPath, _ tableData: TableViewData, _ completion: @escaping ((Result<CNContact, ActionError>) -> Void)) {
        
        guard let selectedContact = self.getSelectedContact(by: indexPath, tableData) else {
            let errorMessage = "Can't get Selected Contact"
            DDLogError(errorMessage)
            completion(.failure(.custom(errorMessage)))
            return
        }
        
        guard let cnHelper = self.cnContactHelper else {
            let errorMessage = "Missing cnContactHelper"
            DDLogError(errorMessage)
            completion(.failure(.custom(errorMessage)))
            return
        }
    
        cnHelper.getCNContact(selectedContact) { cnContact in
            if let value = cnContact {
                DispatchQueue.main.async {
                    completion(.success(value))
                }
            }
            else {
                let errorMessage = "Can't get CNContact value"
                DDLogError(errorMessage)
                completion(.failure(.custom(errorMessage)))
            }
        }
    }
    
    private func getSelectedContact(by indexPath: IndexPath, _ tableData: TableViewData) -> Contact? {
        let header = tableData.headers[indexPath.section]
        let contactList = tableData.content[header]
        return contactList?[indexPath.row]
    }
    
    
    // MARK: - Get Updated IndexPath
    
    public func getUpdatedIndexPath(_ updatedContact: Contact, _ tableData: TableViewData) -> IndexPath? {
        
        let header = String(updatedContact.lastName.prefix(1))
        
        guard let sectionIndex = tableData.headers.firstIndex(of: header) else {
            DDLogError("Can't get Section Index")
            return nil
        }
        
        guard let indexInSection = tableData.content[header]?.firstIndex(where: { $0.email == updatedContact.email }) else {
            DDLogError("Can't get Index in section")
            return nil
        }
        
        return IndexPath(row: indexInSection, section: sectionIndex)
    }
}
