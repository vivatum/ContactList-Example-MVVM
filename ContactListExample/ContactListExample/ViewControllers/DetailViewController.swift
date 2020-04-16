//
//  DetailViewController.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit
import ContactsUI
import CocoaLumberjack

final class DetailViewController: UIViewController {
    
    private lazy var emptyController: EmptyViewController? = {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "EmptyViewController") as? EmptyViewController
    }()
    
    public var selectedContact: CNContact? {
        didSet {
            self.updateChildViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateChildViewController()
    }
    
    private final func updateChildViewController() {
        
        guard let contact = self.selectedContact else {
            DDLogError("Can't get selected contact")
            if let emptyVC = self.emptyController {
                self.addAsChild(emptyVC, frame: self.view.bounds)
            }
            return
        }
        
        self.removeAllChild()
        let contactVC = self.getContactViewController(for: contact)
        let navContactVC = UINavigationController(rootViewController: contactVC)
        self.addAsChild(navContactVC, frame: self.view.bounds)
    }
    
    private final func getContactViewController(for contact: CNContact) -> CNContactViewController {
        let contactViewController = CNContactViewController(forUnknownContact: contact)
        contactViewController.hidesBottomBarWhenPushed = true
        contactViewController.allowsEditing = false
        contactViewController.allowsActions = false
        contactViewController.view.backgroundColor = .white
        return contactViewController
    }
    
}
