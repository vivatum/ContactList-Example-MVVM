//
//  AlertManager.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit
import CocoaLumberjack

public struct AlertManager {
    
    static func showErrorAlert(_ alert: AlertMessage, action: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alertAction -> Void in
            action?()
        }))
        
        guard let topViewController = UIApplication.topViewController() else {
            DDLogError("Can't get topViewController")
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = topViewController.view
        }
        
        DispatchQueue.main.async {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

