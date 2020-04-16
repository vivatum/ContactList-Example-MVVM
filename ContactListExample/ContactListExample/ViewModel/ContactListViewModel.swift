//
//  ContactListViewModel.swift
//  ContactListExample
//
//  Created by Vivatum on 14/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack
import RealmSwift
import Contacts

final class ContactListViewModel {
    
    weak var dataSource: ContactDataSource?
    weak var service: ContactServiceProtocol?
    
    private var contactCollection: Results<Contact>?
    private var notificationToken: NotificationToken? = nil
    
    var selectFavorites = false {
        didSet {
            self.needToDisplayFavoritesOnly(selectFavorites)
        }
    }
    
   var selectedIndexPath: IndexPath? {
        didSet {
            self.getSelectedContactDetail(selectedIndexPath)
        }
    }
    
    var stopProgress: (() -> Void)?
    var showContactDetails: ((CNContact) -> Void)?
    var onErrorHandling: ((ActionError?) -> Void)?
    
    init(dataSource: ContactDataSource?, service: ContactServiceProtocol = ContactService.shared) {
        self.dataSource = dataSource
        self.service = service
        
        self.setupRealmCollection()
        self.setupRealmNotification()
    }
    
    
    public func updateContacts() {
        
        guard let contactService = self.service else {
            let errorMessage = "Missing Contact service"
            DDLogError(errorMessage)
            self.onErrorHandling?(.custom(errorMessage))
            return
        }
        
        contactService.updateLocalCollection { result in
            switch result {
            case .success(let message):
                self.stopProgress?()
                DDLogInfo("Waiting for Realm notification: \(message)")
            case .failure(let error):
                self.onErrorHandling?(error)
            }
        }
    }
    
    private func needToDisplayFavoritesOnly(_ status: Bool) {
        DDLogInfo("Need to Display Favorite only: \(status)")
        
        guard let contactService = self.service else {
            let errorMessage = "Missing Contact service"
            DDLogError(errorMessage)
            self.onErrorHandling?(.custom(errorMessage))
            return
        }
        
        self.dataSource?.data.value = contactService.getTableData(self.contactCollection, self.selectFavorites)
    }
    
    
    // MARK: - Contact Detail
    
    private func getSelectedContactDetail(_ selectedIndexPath: IndexPath?) {
        DDLogInfo("Start Get selected Contact")
        
        guard let indexPath = selectedIndexPath else {
            let errorMessage = "Can't get selected IndexPath"
            DDLogError(errorMessage)
            self.onErrorHandling?(.custom(errorMessage))
            return
        }
        
        guard let contactService = self.service else {
            let errorMessage = "Missing Contact service"
            DDLogError(errorMessage)
            self.onErrorHandling?(.custom(errorMessage))
            return
        }
        
        guard let tableData = self.dataSource?.data.value else {
            let errorMessage = "Can't get tableData"
            DDLogError(errorMessage)
            self.onErrorHandling?(.custom(errorMessage))
            return
        }
        
        contactService.getContactValue(by: indexPath, tableData) { result in
            switch result {
            case .success(let cdContact):
                self.showContactDetails?(cdContact)
            case .failure(let error):
                self.onErrorHandling?(error)
            }
        }
    }
    
    private func updateDetailsForActiveContact(for index: Int) {
        
        guard let updatedContact = self.contactCollection?[index] else {
            DDLogError("Can't get updated contact by index")
            return
        }
        
        guard let tableData = self.dataSource?.data.value else {
            let errorMessage = "Can't get tableData"
            DDLogError(errorMessage)
            self.onErrorHandling?(.custom(errorMessage))
            return
        }
        
        guard let updatedIndexPath = self.service?.getUpdatedIndexPath(updatedContact, tableData) else {
            let errorMessage = "Can't get updated indexPath"
            DDLogError(errorMessage)
            return
        }
                
        if updatedIndexPath == selectedIndexPath {
            self.getSelectedContactDetail(updatedIndexPath)
        }
    }
    
    
    // MARK: - Realm methods
    
    private func setupRealmCollection() {
        do {
            let realm = try Realm()
            self.contactCollection = realm.objects(Contact.self)
            DDLogInfo("Contact collection fetched: \(String(describing: self.contactCollection?.count))")
        }
        catch let error {
            DDLogError("Can't fetch Contact collection: \(error.localizedDescription)")
        }
    }
    
    private func setupRealmNotification() {
        notificationToken = contactCollection?.observe { (changes: RealmCollectionChange) in
            self.stopProgress?()
            if let tableData = self.service?.getTableData(self.contactCollection, self.selectFavorites) {
               self.dataSource?.data.value = tableData
            }
            
            if case .update(_ , _, _, let modifications) = changes {
                modifications.forEach({ self.updateDetailsForActiveContact(for: $0) })
            }
        }
    }
    

    // MARK: - Deinit
    
    deinit {
        self.notificationToken?.invalidate()
    }
}
