    //
//  User.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation
 
struct User: Codable {
    let id: String
    var profileImage: Data?
    var nickName: String
    var description: String?
    var hobbyList: [Category]
    var createClubList: [Club]
    var myNoticeBoardList: [NoticeBoard]
    var myCommentList: [Comment]
}
