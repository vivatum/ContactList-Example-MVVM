//
//  NoDataView.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit
import CocoaLumberjack


final class NoDataView: UIView {

    @IBOutlet var noDataView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let emptyDataMessage = "We couldn't fetch any Data now. \nTry again later please."
    
    public var message: NoDataMessage = .noMessage {
        didSet {
            self.titleLabel.text = message.rawValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        loadViewFromNib()
    }
    
    private final func loadViewFromNib() {
        Bundle.main.loadNibNamed("NoDataView", owner: self, options: nil)
        addSubview(noDataView)
        noDataView.frame = self.bounds
        noDataView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        noDataView.backgroundColor = .white
        self.titleLabel.text = self.emptyDataMessage
    }


}
