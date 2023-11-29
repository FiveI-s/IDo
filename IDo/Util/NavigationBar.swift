//
//  NavigationBar.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/11/05.
//

import UIKit

final class NavigationBar {
    
    static func setNavigationBackButton(for navigationItem: UINavigationItem, title: String) {
        let backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    static func setNavigationTitle(for navigationItem: UINavigationItem, in navigationBar: UINavigationBar, title: String) {
        navigationItem.title = title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.bodyFont(.medium, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        navigationBar.titleTextAttributes = titleAttributes
    }
    
    static func setNavigationCategoryTitle(for navigationItem: UINavigationItem) {
        let titleLabel = UILabel()
        titleLabel.text = TemporaryManager.shared.categoryData ?? ""
        titleLabel.font = UIFont.bodyFont(.medium, weight: .regular)
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
    }
}
