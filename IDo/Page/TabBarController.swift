//
//  TabBarController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import FirebaseAuth

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
        
        // TabBar 상단에 1픽셀 높이의 구분선을 추가
        let tabBarSeparator = CALayer()
        tabBarSeparator.backgroundColor = UIColor(color: .placeholder).cgColor // 구분선 색상 설정
        tabBarSeparator.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: 1.0 / UIScreen.main.scale) // 1픽셀 높이의 선
        self.tabBar.layer.addSublayer(tabBarSeparator)
        
        // 기본 탭바 상단 섀도우 제거
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
    }

    private func viewControllerSetting() {
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: CategoryViewController())
//        let vc3 = UINavigationController(rootViewController: NoticeViewController())
        let vc4 = UINavigationController(rootViewController: MyProfileViewController())

        vc1.title = "홈"
        vc2.title = "카테고리"
//        vc3.title = "알림"
        vc4.title = "마이프로필"

//        self.setViewControllers([vc1, vc2, vc3, vc4], animated: false)
        self.setViewControllers([vc1, vc2, vc4], animated: false)

        guard let items = self.tabBar.items else { return }

//        let images = ["house", "list.bullet.rectangle", "bell", "person"]
        let images = ["house", "list.bullet.rectangle", "person"]

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
