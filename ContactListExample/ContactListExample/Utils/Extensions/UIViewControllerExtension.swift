//
//  UIViewControllerExtension.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit

extension UIViewController {
    
    final func addAsChild(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    final func removeAllChild() {
        self.children.forEach {
            $0.removeAsChild()
        }
    }

    final func removeAsChild() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
