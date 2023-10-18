//
//  UserSummary.swift
//  IDo
//
//  Created by 김도현 on 2023/10/18.
//

import Foundation

struct UserSummary: Codable {
    let id: String
    var profileImage: Data?
    var nickName: String
    var description: String?
}
