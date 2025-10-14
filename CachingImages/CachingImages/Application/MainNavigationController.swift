//
//  MainNavigationController.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import UIKit

class MainNavigationController: UINavigationController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
        self.navigationBar.isHidden = true
    }
    
    // MARK: - Orientation Control
    // Delegate orientation control to the top view controller
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    
    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
