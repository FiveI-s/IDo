//
//  UserSummary.swift
//  IDo
//
//  Created by 김도현 on 2023/10/18.
//

import Foundation

struct UserSummary: Codable, Identifier {
    let id: String
    var profileImagePath: String?
    var nickName: String
    var description: String?
    var declarationCount: Int?
    var hobbyList: [String]?
}
