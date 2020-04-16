//
//  ContactComparing.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation

struct ContactComparing {
    
    let firstName: String
    let lastName: String
    
    let largePic: String
    let thumbnailPic: String
    
    let phone: String
    let cell: String
    
    let streetNumber: Int
    let streetName: String
    let city: String
    let state: String
    let country: String
    let postcode: String
    
    init(contact: Contact) {
        self.firstName = contact.firstName
        self.lastName = contact.lastName
        self.largePic = contact.largePic
        self.thumbnailPic = contact.thumbnailPic
        self.phone = contact.phone
        self.cell = contact.cell
        self.streetNumber = contact.streetNumber
        self.streetName = contact.streetName
        self.city = contact.city
        self.state = contact.state
        self.country = contact.country
        self.postcode = contact.postcode
    }
}

extension ContactComparing: Equatable {
    public static func == (left: ContactComparing, right: ContactComparing) -> Bool {
        return left.firstName == right.firstName &&
                left.lastName == right.lastName &&
                left.largePic == right.largePic &&
                left.thumbnailPic == right.thumbnailPic &&
                left.phone == right.phone &&
                left.cell == right.cell &&
                left.streetNumber == right.streetNumber &&
                left.streetName == right.streetName &&
                left.city == right.city &&
                left.state == right.state &&
                left.country == right.country &&
                left.postcode == right.postcode
    }
}
