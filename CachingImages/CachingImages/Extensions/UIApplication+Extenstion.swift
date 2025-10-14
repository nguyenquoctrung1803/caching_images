//
//  UIApplication+Extenstion.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import UIKit

extension UIApplication {
    class func setRootViewController() -> UINavigationController {
        
        //Here can set logic already login or sign in/sign up
        return setListImagesAsRootViewController()
    }
    
    class func setListImagesAsRootViewController() -> UINavigationController {
        let viewController = (listImagesStoryBoard.instantiateViewController(withIdentifier: listImagesViewController) as? ListImagesViewController)!
        let mainNavigationController = MainNavigationController(rootViewController: viewController)
        return mainNavigationController
    }
    
}
