//
//  NoticeBoard.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation

struct NoticeBoard: Codable, Identifier {
    let id: String
    var rootUser: UserSummary
    let createDate: String
    let clubID: String
    var title: String
    var content: String
    var imageList: [NoticeBoardImagePath]?
    var commentCount: String
}
