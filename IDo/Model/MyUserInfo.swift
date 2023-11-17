//
//  MyUserInfo.swift
//  IDo
//
//  Created by 김도현 on 2023/10/26.
//

import UIKit

struct MyUserInfo: Codable {
    let id: String
    var updateAt: String?
    var profileImagePath: String?
    var profileImage: [String: Data]
    var nickName: String
    var declarationCount: Int?
    var description: String?
    var hobbyList: [String]?
    var myClubList: [Club]?
    var myNoticeBoardList: [NoticeBoard]?
    var myCommentList: [Comment]?
    var blockList: [UserSummary]?

    var toIDoUser: IDoUser {
        return IDoUser(id: id, updateAt: updateAt, profileImagePath: profileImagePath, nickName: nickName, description: description, hobbyList: hobbyList, myClubList: myClubList, myNoticeBoardList: myNoticeBoardList, myCommentList: myCommentList, blockList: blockList)
    }
    
    var toUserSummary: UserSummary {
        return UserSummary(id: id, profileImagePath: profileImagePath, nickName: nickName, description: description, declarationCount: declarationCount, hobbyList: hobbyList)
    }
}
