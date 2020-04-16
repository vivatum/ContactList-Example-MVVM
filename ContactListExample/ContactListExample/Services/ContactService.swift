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
    
    static let shared = ContactService()
    private init(){}
    
    public func updateLocalCollection(_ completion: @escaping ((Result<String, ActionError>) -> Void)) {
        DDLogInfo("Start update local collection")
        
        DispatchQueue.global(qos: .background).async {
            RESTHelper.loadContactListData { result in
                switch result {
                case .success(let collection):
                    DDLogInfo("Load contact list Success")
                    
                    guard let contacts = collection else {
                        completion(.failure(.parser("Can't get parsed collection")))
                        return
                    }
                    
                    RealmService.shared.synchronizeCollection(contacts) { result in
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
    }
    
    
    // MARK: - Get TableViewData
    
    public func getTableData(_ contacts: Results<Contact>?, _ selectFavorited: Bool) -> TableViewData {
        
        var dataSource = [String : Results<Contact>]()
        
        guard var collection = contacts, !collection.isEmpty else {
            DDLogInfo("Contact collection is empty")
            return TableViewData(headers: [String](), content: dataSource)
        }
        
        if selectFavorited {
            let predicate = NSPredicate(format: "\(ContactKey.isFavoritedKey) == %d", true)
            collection = collection.filter(predicate)
        }
        
        guard let sectionHeaders = self.getHeaders(collection)?.sorted(by: <) else {
            DDLogInfo("Can't get Section Headers")
            return TableViewData(headers: [String](), content: dataSource)
        }
        
        sectionHeaders.forEach({ header in
            let predicate = NSPredicate(format: "\(ContactKey.lastNameKey) BEGINSWITH[cd] %@", header)
            dataSource[header] = collection.filter(predicate).sorted(by: ["lastName", "firstName"])
        })
        
        return TableViewData(headers: sectionHeaders, content: dataSource)
    }
    
    private func getHeaders(_ contacts: Results<Contact>) -> [String]? {
        guard let lastNames = contacts.value(forKey: ContactKey.lastNameKey) as? [String] else {
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
        
        let contactRef = ThreadSafeReference(to: selectedContact)
        self.getCNContact(for: contactRef) { result in
            switch result {
            case .success(let cnContact):
                completion(.success(cnContact))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getSelectedContact(by indexPath: IndexPath, _ tableData: TableViewData) -> Contact? {
        let header = tableData.headers[indexPath.section]
        let contactList = tableData.content[header]
        return contactList?[indexPath.row]
    }
    
    private func getCNContact(for contactRef: ThreadSafeReference<Contact>, handler: @escaping ((Result<CNContact, ActionError>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    guard let contact = realm.resolve(contactRef) else {
                        let errorMessage = "Realm: Contact does not exist"
                        DDLogError(errorMessage)
                        handler(.failure(.dataBase(errorMessage)))
                        return
                    }
                    
                    guard let cnContact = self.getCNContactValue(for: contact) else {
                        let errorMessage = "Can't get cnContact"
                        DDLogError(errorMessage)
                        handler(.failure(.custom(errorMessage)))
                        return
                    }
                    
                    DDLogInfo("cnContact object created")
                    handler(.success(cnContact))
                }
                catch let error {
                    let errorMessage = "Realm: Can't update exist Contact object: \(error.localizedDescription)"
                    DDLogError(errorMessage)
                    handler(.failure(.dataBase(errorMessage)))
                }
            }
        }
    }
    
    private func getCNContactValue(for item: Contact) -> CNContact? {
        
        let contact = CNMutableContact()
        var givenName = item.firstName
        
        if item.isFavorited {
            givenName = "\u{2B50}" + " " + item.firstName
        }
        
        contact.givenName = givenName
        contact.familyName = item.lastName
        contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: item.email as NSString)]
        
        let phoneNumber = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: item.phone))
        let cellNumber = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: item.cell))
        contact.phoneNumbers = [phoneNumber, cellNumber]
        
        let address = CNMutablePostalAddress()
        address.street = item.streetName + " " + String(item.streetNumber)
        address.city = item.city
        address.state = item.state
        address.postalCode = item.postcode
        address.country = item.country
        let home = CNLabeledValue<CNPostalAddress>(label:CNLabelHome, value:address)
        contact.postalAddresses = [home]

        self.getImageData(by: item.largePic) { imageData in
            contact.imageData = imageData
        }
        
        return contact.copy() as? CNContact
    }
    
    private func getImageData(by path: String, closure: @escaping (Data?) -> Void) {
        guard let url = URL(string: path) else {
            DDLogError("Can't URL from path")
            closure(nil)
            return
        }
        
        guard Network.isReachable else {
            DDLogError("Network unreachable!")
            DispatchQueue.main.async {
                AlertManager.showErrorAlert(ActionError.network("Can't load Contact image").alertContent)
            }
            closure(nil)
            return
        }
           
        do {
            let imageData = try Data(contentsOf: url)
            closure(imageData)
        }
        catch let error {
            DDLogError("Can't get contact image data: \(error.localizedDescription)")
            closure(nil)
            return
        }
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
