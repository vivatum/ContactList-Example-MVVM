//
//  NoDataMessage.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation

enum NoDataMessage: String {
    case noDataFetched = "We couldn't fetch any Data now. \nTry again later please."
    case noFavorites = "No favorites contacts found."
    case noSelected = "No Contact selected."
    case noMessage = ""
}
