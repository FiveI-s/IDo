//
//  TabBarController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarSetting()
        self.viewControllerSetting()
    }

    private func tabBarSetting() {
        self.tabBar.backgroundColor = .white
        self.modalPresentationStyle = .fullScreen
        self.tabBar.unselectedItemTintColor = .systemGray
        self.tabBar.tintColor = UIColor(color: .main)
    }

    private func viewControllerSetting() {
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: CategoryViewController())
        let vc3 = UINavigationController(rootViewController: NoticeViewController())
        let vc4 = UINavigationController(rootViewController: NoticeBoardViewController())

        vc1.title = "홈"
        vc2.title = "카테고리"
        vc3.title = "알림"
        vc4.title = "마이프로필"

        self.setViewControllers([vc1, vc2, vc3, vc4], animated: false)

        guard let items = self.tabBar.items else { return }

        let images = ["house", "list.bullet.rectangle", "bell", "person"]

        for index in 0..<items.count {
            items[index].image = UIImage(systemName: images[index])
        }

        // 선택된 아이템의 이미지와 색상 설정
        if let items = self.tabBar.items {
            for index in 0..<items.count {
                let selectedImageName = images[index] + ".fill"
                items[index].selectedImage = UIImage(systemName: selectedImageName)
            }
        }
    }
}
