//
//  UIViewExtension.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit

extension UIView {
    
    final func roundCorners(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    final func makeRoundView() {
        roundCorners(self.frame.height / 2)
    }
    
}
