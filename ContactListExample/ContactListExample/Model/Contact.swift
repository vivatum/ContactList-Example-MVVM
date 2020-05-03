//
//  Contact.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

final class Contact: Object, Decodable {
    
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
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case picture
        case email
        case phone
        case cell
        case location
        case city
        case state
        case country
        case postcode
    }
    
    enum NameKeys: String, CodingKey {
        case first
        case last
    }
    
    enum PictureKeys: String, CodingKey {
        case large
        case thumbnail
    }
    
    enum LocationKeys: String, CodingKey {
        case street
        case city
        case state
        case country
        case postcode
    }
    
    enum StreetKeys: String, CodingKey {
        case number
        case name
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        email = try values.decode(String.self, forKey: .email)
        phone = try values.decode(String.self, forKey: .phone)
        cell = try values.decode(String.self, forKey: .cell)
        
        let name = try values.nestedContainer(keyedBy: NameKeys.self, forKey: .name)
        firstName = try name.decode(String.self, forKey: .first)
        lastName = try name.decode(String.self, forKey: .last)
        
        let picture = try values.nestedContainer(keyedBy: PictureKeys.self, forKey: .picture)
        largePic = try picture.decode(String.self, forKey: .large)
        thumbnailPic = try picture.decode(String.self, forKey: .thumbnail)
        
        let location = try values.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        city = try location.decode(String.self, forKey: .city)
        state = try location.decode(String.self, forKey: .state)
        country = try location.decode(String.self, forKey: .country)
        
        do {
            postcode = try location.decode(String.self, forKey: .postcode)
        } catch DecodingError.typeMismatch {
            do {
                if let postCodeInt = try? location.decode(Int.self, forKey: .postcode) {
                    postcode = String(postCodeInt)
                }
                else {
                    postcode = "Error post code"
                    DDLogError("Encoded POST CODE not of an expected type")
                }
            }
        }
        
        let street = try location.nestedContainer(keyedBy: StreetKeys.self, forKey: .street)
        streetNumber = try street.decode(Int.self, forKey: .number)
        streetName = try street.decode(String.self, forKey: .name)
    }
}

struct ContactDataStore: Decodable {
    var results: [Contact]
}
