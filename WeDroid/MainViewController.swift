//
//  MainViewController.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import UIKit

class MainViewController: UITabBarController {

    lazy var robotListViewController = RoboListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        robotListViewController.title = NSLocalizedString("机器人列表", comment: "")
        robotListViewController.tabBarItem.image = UIImage(named: "robot_item")
        self.viewControllers = [
            UINavigationController(rootViewController: robotListViewController)
        ]
    }


}

