//
//  NoticeBoardEmptyView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/14.
//

import UIKit
import SnapKit

class NoticeBoardEmptyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 게시판이 없을 때
    private(set) lazy var emptyMessageStackView = EmptyMessageStackView()
    
}

private extension NoticeBoardEmptyView {
    
    // NoticeBoardEmptyView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor.white
        emptyMessageStackView.setImage(image: UIImage(systemName: "list.bullet.clipboard.fill"))
        emptyMessageStackView.titleLabel.text = "게시판이 존재하지 않습니다."
        emptyMessageStackView.descriptionLabel.text = "게시글 작성을 통해 사람들과 내용을 공유하세요"
    }
    
    // NoticeBoardEmptyView를 SubView에 추가
    func addSubView() {
        addSubview(emptyMessageStackView)
    }
    
    // 오토레이아웃 설정
    func autoLayout() {
        emptyMessageStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
               make.left.right.equalToSuperview().inset(Constant.margin3)
        }
    }
}
