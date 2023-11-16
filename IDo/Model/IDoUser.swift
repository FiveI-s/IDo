//
//  User.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import Foundation

struct IDoUser: Codable, Identifier {
    let id: String
    var updateAt: String?
    var email: String?
    var profileImagePath: String?
    var nickName: String
    var description: String?
    var declarationCount: Int?
    var hobbyList: [String]?
    var myClubList: [Club]?
    var myNoticeBoardList: [NoticeBoard]?
    var myCommentList: [Comment]?

    var toMyUserInfo: MyUserInfo {
        return MyUserInfo(id: id, updateAt: updateAt, profileImagePath: profileImagePath, profileImage: [:], nickName: nickName, description: description, hobbyList: hobbyList, myClubList: myClubList, myNoticeBoardList: myNoticeBoardList, myCommentList: myCommentList)
    }
    var toUserSummary: UserSummary {
        return UserSummary(id: id, profileImagePath: profileImagePath, nickName: nickName, description: description, declarationCount: declarationCount, hobbyList: hobbyList)

    }
}
