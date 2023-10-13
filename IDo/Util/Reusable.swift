//
//  IdentiferAbel.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

protocol Reusable {
    static var identifier: String { get }
}

extension Reusable {
    static var identifier: String { "\(self)" }
}
