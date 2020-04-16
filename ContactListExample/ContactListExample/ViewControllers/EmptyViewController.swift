//
//  EmptyViewController.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit

final class EmptyViewController: UIViewController {

    @IBOutlet weak var noDataView: NoDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.noDataView.message = .noSelected
        
    }

}
