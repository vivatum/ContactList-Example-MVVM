//
//  TableViewData.swift
//  ContactListExample
//
//  Created by Vivatum on 14/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation
import RealmSwift

struct TableViewData {
    let headers: [String]
    let content: [String : Results<Contact>]
}
