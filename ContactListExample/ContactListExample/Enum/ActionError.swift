//
//  ActionError.swift
//  ContactListExample
//
//  Created by Vivatum on 14/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import Foundation

enum ActionError: Error {
    
    case network(_ message: String)
    case backend(_ message: String)
    case parser(_ message: String)
    case dataBase(_ message: String)
    case custom(_ message: String)
    
    var alertContent: AlertMessage {
        var titleText = ""
        var messageText = ""
        
        switch self {
        case .network:
            titleText = "Network Error"
            messageText = "Check Internet connection please."
        case .backend, .parser, .dataBase, .custom:
            titleText = "Fetching Data Error"
            messageText = "Please try again later."
        }
        
        return AlertMessage(title: titleText, message: messageText)
    }
}
