//
//  Contact.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import RealmSwift
import Contacts
import CocoaLumberjack

final class Contact: Object {
    
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    
    @objc dynamic var largePic = ""
    @objc dynamic var thumbnailPic = ""
    
    @objc dynamic var email = ""
    @objc dynamic var phone = ""
    @objc dynamic var cell = ""
    
    @objc dynamic var streetNumber = 0
    @objc dynamic var streetName = ""
    @objc dynamic var city = ""
    @objc dynamic var state = ""
    @objc dynamic var country = ""
    @objc dynamic var postcode = ""
    
    @objc dynamic var isFavorited: Bool = false
}
