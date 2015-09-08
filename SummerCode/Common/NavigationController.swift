//
//  NavigationController.swift
//  SummerCode
//
//  Created by daniel.martinez on 8/9/15.
//  Copyright (c) 2015 com.igz. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationBar.tintColor = UIColor.whiteColor()
    }
    
}