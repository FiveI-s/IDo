//
//  Club.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation

struct Club: Codable {
    let id: String
    var rootUser: User
    var title: String
    var image: Data
    var description: String
    var category: [Category]
    var noticeBoardList: [NoticeBoard]
    var userList: [User]
}
