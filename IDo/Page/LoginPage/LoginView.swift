//
//  LoginView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/16.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 카카오 로그인 버튼
    private(set) lazy var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        return button
    }()
}

private extension LoginView {
    
    // NoticeBoardView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor.white
    }
    
    // noticeBoardTableView를 SubView에 추가
    func addSubView() {
        addSubview(kakaoLoginButton)
    }
    
    // 오토레이아웃 설정
    func autoLayout() {
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(45)
        }
    }
}
