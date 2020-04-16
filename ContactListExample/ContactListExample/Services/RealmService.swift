//
//  RealmService.swift
//  ContactListExample
//
//  Created by Vivatum on 15/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

final class RealmService {
    
    static let shared = RealmService()
    private init(){}

    
    // MARK: - Synchronize Contact Collection
    
    public func synchronizeCollection(_ incomingContacts: [Contact], _ closure: @escaping ((Result<String, ActionError>) -> Void)) {
        
        let existingCollection: Results<Contact>? = {
            do {
                let realm = try Realm()
                return realm.objects(Contact.self)
            }
            catch let error {
                DDLogError("Can't get exist Contact: \(error.localizedDescription)")
                return nil
            }
        }()
        
        guard let existingContacts = existingCollection, !existingContacts.isEmpty else {
            DDLogInfo("Contact Collection does not exist")
            self.addContactCollection(incomingContacts, closure)
            return
        }
        
        incomingContacts.forEach({ newContact in
            let predicate = NSPredicate(format: "\(JSONKey.email) == %@", newContact.email)
            if let existContact = existingContacts.filter(predicate).first {
                
                let newContactComparing = ContactComparing(contact: newContact)
                let existContactComparing = ContactComparing(contact: existContact)
                
                if existContactComparing != newContactComparing {
                    let existContactRef = ThreadSafeReference(to: existContact)
                    self.updateExistContact(existContactRef, newContactComparing)
                }
            }
            else {
                self.addNewContact(newContact)
            }
        })
        
        let successMessage = "Contacts Synchronize Finished"
        DDLogInfo(successMessage)
        closure(.success(successMessage))
    }
    
    private func addContactCollection(_ collection: [Contact], _ closure: @escaping ((Result<String, ActionError>) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(collection)
                        let successMessage = "Realm: Incoming Contacts collection saved"
                        DDLogInfo(successMessage)
                        closure(.success(successMessage))
                    }
                }
                catch let error {
                    let errorMessage = "Realm: Can't add Incoming Contacts collection: \(error.localizedDescription)"
                    DDLogError(errorMessage)
                    closure(.failure(.dataBase(errorMessage)))
                }
            }
        }
    }
    
    private func updateExistContact(_ existRef: ThreadSafeReference<Contact>, _ newData: ContactComparing) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    guard let _contact = realm.resolve(existRef) else {
                        DDLogError("Realm: Contact does not exist")
                        return
                    }
                    try realm.write {
                        
                        _contact.firstName = newData.firstName
                        _contact.lastName = newData.lastName
                        _contact.largePic = newData.largePic
                        _contact.thumbnailPic = newData.thumbnailPic
                        _contact.phone = newData.phone
                        _contact.cell = newData.cell
                        _contact.streetNumber = newData.streetNumber
                        _contact.streetName = newData.streetName
                        _contact.city = newData.city
                        _contact.state = newData.state
                        _contact.country = newData.country
                        _contact.postcode = newData.postcode

                        DDLogInfo("Realm: Existing Contact object updated")
                    }
                }
                catch let error {
                    DDLogError("Realm: Can't update exist Contact object: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func addNewContact(_ contact: Contact) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(contact)
                        DDLogInfo("Realm: New Contact object added")
                    }
                }
                catch let error {
                    DDLogError("Realm: Can't add New Contact object: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Update properties
    
    public func updateFavoritedStatus(_ ref: ThreadSafeReference<Contact>, _ isFavorited: Bool) {
        DDLogInfo("Update isFavorited status")
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    guard let _contact = realm.resolve(ref) else {
                        DDLogError("Realm: Contact does not exist")
                        return
                    }
                    try realm.write {
                        _contact.isFavorited = isFavorited
                        DDLogInfo("Realm: isFavorited status updated")
                    }
                }
                catch let error {
                    DDLogError("Realm: Can't update isFavorited status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
