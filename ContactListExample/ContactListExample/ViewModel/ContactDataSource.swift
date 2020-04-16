//
//  ContactDataSource.swift
//  ContactListExample
//
//  Created by Vivatum on 14/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit
import RealmSwift

final class ContactDataSource: NSObject, UITableViewDataSource {

    public var data: Dynamic<TableViewData> = Dynamic(TableViewData(headers: [String](), content: [String : Results<Contact>]()))
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.value.headers.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.value.headers[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value.content[data.value.headers[section]]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let currentCell = cell as? ContactTableViewCell {
            if let content = data.value.content[data.value.headers[indexPath.section]] {
                currentCell.contactData = content[indexPath.row]
            }
        }
        return cell
    }
    
}
