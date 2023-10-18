//
//  ViewState.swift
//  IDo
//
//  Created by 김도현 on 2023/10/17.
//

enum ViewState {
    typealias isConnectedToInternet = Bool
    case loading
    case loaded
    case error(isConnectedToInternet)
}
