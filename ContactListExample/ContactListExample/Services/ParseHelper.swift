//
//  ParserHelper.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SwiftyJSON

public typealias JSONStandard = Dictionary<String, Any>

struct ParseHelper {
    
    static func parseContactList(_ data: Any) -> [Contact]? {
        
        guard let contactDataArray = JSON(data).arrayObject as? [JSONStandard] else {
            DDLogError("Can't get contact Data Array")
            return nil
        }
        
        return contactDataArray.compactMap({parseContact($0)})
    }
    
    static func parseContact(_ contactData: JSONStandard) -> Contact? {
        
        // name
        
        guard let nameDict = JSON(contactData)[JSONKey.name].dictionaryObject else {
            DDLogError("Can't get nameDict")
            return nil
        }
        
        guard let firstName = nameDict[JSONKey.first] as? String else {
            DDLogError("Can't get firstName")
            return nil
        }
        
        guard let lastName = nameDict[JSONKey.last] as? String else {
            DDLogError("Can't get lastName")
            return nil
        }
        
        // pic
        
        guard let picDict = JSON(contactData)[JSONKey.picture].dictionaryObject else {
            DDLogError("Can't get picDict")
            return nil
        }
        
        guard let largePic = picDict[JSONKey.large] as? String else {
            DDLogError("Can't get largePic")
            return nil
        }
        
        guard let thumbnailPic = picDict[JSONKey.thumbnail] as? String else {
            DDLogError("Can't get thumbnailPic")
            return nil
        }
        
        // location
        
        guard let locationDict = JSON(contactData)[JSONKey.location].dictionaryObject else {
            DDLogError("Can't get picDict")
            return nil
        }
        
        guard let streetDict = JSON(locationDict)[JSONKey.street].dictionaryObject else {
            DDLogError("Can't get streetDict")
            return nil
        }
        
        guard let streetNumber = streetDict[JSONKey.streetNumber] as? Int else {
            DDLogError("Can't get streetNumber")
            return nil
        }
        
        guard let streetName = streetDict[JSONKey.streetName] as? String else {
            DDLogError("Can't get streetName")
            return nil
        }
        
        guard let city = locationDict[JSONKey.city] as? String else {
            DDLogError("Can't get city")
            return nil
        }
        
        guard let state = locationDict[JSONKey.state] as? String else {
            DDLogError("Can't get state")
            return nil
        }
        
        guard let country = locationDict[JSONKey.country] as? String else {
            DDLogError("Can't get country")
            return nil
        }
        
        var postcode = ""
        
        if let postcodeString = locationDict[JSONKey.postcode] as? String {
            postcode = postcodeString
        }
        else if let postcodeInt = locationDict[JSONKey.postcode] as? Int {
            postcode = String(postcodeInt)
        }
        
        
        // email, phones...
        
        guard let email = contactData[JSONKey.email] as? String else {
            DDLogError("Can't get email")
            return nil
        }
        
        guard let phone = contactData[JSONKey.phone] as? String else {
            DDLogError("Can't get phone")
            return nil
        }
        
        guard let cell = contactData[JSONKey.cell] as? String else {
            DDLogError("Can't get cell")
            return nil
        }
        
        let contact = Contact()
        contact.firstName = firstName
        contact.lastName = lastName
        contact.largePic = largePic
        contact.thumbnailPic = thumbnailPic
        contact.email = email
        contact.phone = phone
        contact.cell = cell
        contact.streetNumber = streetNumber
        contact.streetName = streetName
        contact.city = city
        contact.state = state
        contact.country = country
        contact.postcode = postcode
        contact.isFavorited = false
        
        return contact
    }
}
