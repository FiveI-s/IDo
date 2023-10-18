//
//  NoticeBoardView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class NoticeBoardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TableView 만들기
    private(set) lazy var noticeBoardTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NoticeBoardTableViewCell.self, forCellReuseIdentifier: NoticeBoardTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        
        // 왼쪽 공백 없애기
        tableView.separatorInset.left = 0
        return tableView
    }()
}

private extension NoticeBoardView {
    
    // NoticeBoardView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor.white
    }
    
    // noticeBoardTableView를 SubView에 추가
    func addSubView() {
        addSubview(noticeBoardTableView)
    }
    
    // 오토레이아웃 설정
    func autoLayout() {
        noticeBoardTableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.bottom.equalTo(snp.bottom)
        }
    }
}
