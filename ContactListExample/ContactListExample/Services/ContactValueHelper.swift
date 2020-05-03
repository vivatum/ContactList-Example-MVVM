//
//  ContactValueHelper.swift
//  ContactListExample
//
//  Created by Vivatum on 03/05/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Contacts

protocol ContactValueProtocol {
    func getCNContact(_ contact: Contact, closure: @escaping (CNContact?) -> Void)
}

struct ContactValueHelper: ContactValueProtocol {
    
    func getCNContact(_ contact: Contact, closure: @escaping (CNContact?) -> Void) {
        
        guard let url = URL(string: contact.largePic) else {
            DDLogError("Wrong contact.largePic url format")
            return
        }
        
        ImageLoader.shared.getImageData(url) { result in
            var iconData: Data? = nil
            switch result {
            case .success(let data):
                iconData = data
            case .failure(let error):
                DDLogError("Can't get Contact Icon Data: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                closure(self.createCNContact(for: contact, iconData: iconData))
            }
        }
    }
    
    private func createCNContact(for item: Contact, iconData: Data?) -> CNContact? {
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
        
        contact.imageData = iconData
        return contact.copy() as? CNContact
    }
}
