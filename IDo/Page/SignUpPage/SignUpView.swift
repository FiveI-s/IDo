//
//  SignUpView.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/11/10.
//

import SnapKit
import UIKit

class SignUpView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addViews()
        autoLayout()
        setupHyperLink()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "(최소 8자, 소문자, 숫자, 특수문자 필요)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var passwordConfirmErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var eyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        
        return button
    }()
    
    private(set) lazy var confirmEyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        
        return button
    }()
    
    private(set) lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("〈 뒤로가기", for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.setTitleColor(UIColor(color: .contentPrimary), for: .normal)
        return button
    }()
    
    private(set) lazy var linkButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("중복확인", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(UIColor(color: .text2), for: .normal)
        
        return btn
    }()
    
    private(set) lazy var idLable: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        return label
    }()
    
    private(set) lazy var passwordLable: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        return label
    }()
    
    private(set) lazy var passwordConfirmLable: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 재확인"
        return label
    }()
    
    private(set) lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        
        return textField
    }()
    
    private(set) lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        return textField
    }()
    
    private(set) lazy var passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 재입력해주세요"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        return textField
    }()
    
    private(set) lazy var authenticationNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "인증번호"
        textField.font = .bodyFont(.large, weight: .regular)
        textField.textColor = UIColor(color: .textStrong)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private(set) lazy var emailAuthorizationButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("인증", for: .normal)
        btn.setTitleColor(UIColor(color: .white), for: .normal)
        btn.titleLabel?.font = UIFont.bodyFont(.large, weight: .regular)
        btn.backgroundColor = UIColor(color: .contentPrimary)
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    private(set) lazy var authenticationNumberButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("확인", for: .normal)
        btn.setTitleColor(UIColor(color: .white), for: .normal)
        btn.titleLabel?.font = UIFont.bodyFont(.large, weight: .regular)
        btn.backgroundColor = UIColor(color: .contentPrimary)
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    private(set) lazy var termsCheckButton: UIButton = {
        var button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "rectangle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.rectangle"), for: .selected)
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        return button
    }()
    
    private(set) lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "이용약관 동의"
        label.textColor = .darkGray
        label.font = UIFont.bodyFont(.small, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private(set) lazy var termsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [termsCheckButton, termsLabel])
        stackView.spacing = 12
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private(set) lazy var privacyPolicycheckButton: UIButton = {
        var button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "rectangle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.rectangle"), for: .selected)
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        return button
    }()
    
    private(set) lazy var privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보처리방침 동의"
        label.textColor = .darkGray
        label.font = UIFont.bodyFont(.small, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private(set) lazy var privacyPolicyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [privacyPolicycheckButton, privacyPolicyLabel])
        stackView.spacing = 12
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private(set) lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입하기", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()
    
    func addViews() {
        addSubview(emailTextField)
        addSubview(linkButton)
        addSubview(passwordTextField)
        addSubview(nextButton)
        addSubview(idLable)
        addSubview(passwordLable)
        addSubview(passwordConfirmLable)
        addSubview(passwordTextField)
        addSubview(passwordConfirmTextField)
        addSubview(emailAuthorizationButton)
        addSubview(authenticationNumberTextField)
        addSubview(authenticationNumberButton)
        addSubview(passwordErrorLabel)
        addSubview(passwordConfirmErrorLabel)
        addSubview(termsStackView)
        addSubview(privacyPolicyStackView)
    }
    
    func autoLayout() {
        let safeArea = safeAreaLayoutGuide

        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        
        passwordConfirmTextField.rightView = confirmEyeButton
        passwordConfirmTextField.rightViewMode = .always
        let contentHeight = 48
        
        idLable.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.leading.trailing.equalToSuperview().inset(Constant.margin4)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(idLable.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        
        linkButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField.snp.trailing).inset(5)
        }
        emailAuthorizationButton.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.right.equalToSuperview().inset(Constant.margin4)
            make.width.equalTo(60)
            make.height.equalTo(contentHeight)
            make.left.equalTo(emailTextField.snp.right).offset(Constant.margin2)
        }
        authenticationNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        
        authenticationNumberButton.snp.makeConstraints { make in
            make.centerY.equalTo(authenticationNumberTextField)
            make.right.equalToSuperview().inset(Constant.margin4)
            make.width.equalTo(60)
            make.height.equalTo(contentHeight)
            make.left.equalTo(authenticationNumberTextField.snp.right).offset(Constant.margin2)
        }
        
        passwordLable.snp.makeConstraints { make in
            make.top.equalTo(authenticationNumberButton.snp.bottom).offset(Constant.margin3)
            make.leading.trailing.equalToSuperview().inset(Constant.margin4)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Constant.margin1)
            make.leading.trailing.equalToSuperview().inset(Constant.margin4)
        }
        passwordConfirmLable.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin4)
        }
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmLable.snp.bottom).offset(Constant.margin2)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(contentHeight)
        }
        passwordConfirmErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(Constant.margin1)
            make.left.right.equalToSuperview().inset(Constant.margin4)
        }
        
        termsStackView.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmErrorLabel.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.right.equalToSuperview().inset(Constant.margin4)
        }
        termsCheckButton.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        privacyPolicyStackView.snp.makeConstraints { make in
            make.top.equalTo(termsStackView.snp.bottom).offset(Constant.margin2)
            make.left.equalToSuperview().inset(Constant.margin4)
            make.right.equalToSuperview().inset(Constant.margin4)
        }
        privacyPolicycheckButton.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeArea).inset(Constant.margin3)
            make.left.right.equalToSuperview().inset(Constant.margin3)
            make.height.equalTo(48)
        }
    }

    func setupHyperLink() {
        guard let termsText = termsLabel.text else { return }
        let termsAttributedString = NSMutableAttributedString(string: termsText)
        let termsRange = (termsText as NSString).range(of: "이용약관")
        let termsLinkAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://melon-drawer-23e.notion.site/43d5209ed002411998698f51554c074a?pvs=4")!, // 링크 URL
            .foregroundColor: UIColor.blue, // 링크 텍스트 색상
            .underlineStyle: NSUnderlineStyle.single.rawValue // 밑줄 스타일
        ]

        termsAttributedString.addAttributes(termsLinkAttributes, range: termsRange)

        // UILabel에 NSAttributedString 설정
        termsLabel.attributedText = termsAttributedString

        // UILabel의 텍스트 선택 가능하게 설정
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfUseTap)))
        
        guard let privacyPolicyText = privacyPolicyLabel.text else { return }
        let privacyPolicyAttributedString = NSMutableAttributedString(string: privacyPolicyText)
        let privacyPolicyRange = (privacyPolicyText as NSString).range(of: "개인정보처리방침")
        let privacyPolicyLinkAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://melon-drawer-23e.notion.site/43d5209ed002411998698f51554c074a?pvs=4")!, // 링크 URL
            .foregroundColor: UIColor.blue, // 링크 텍스트 색상
            .underlineStyle: NSUnderlineStyle.single.rawValue // 밑줄 스타일
        ]

        privacyPolicyAttributedString.addAttributes(privacyPolicyLinkAttributes, range: privacyPolicyRange)

        // UILabel에 NSAttributedString 설정
        privacyPolicyLabel.attributedText = privacyPolicyAttributedString

        // UILabel의 텍스트 선택 가능하게 설정
        privacyPolicyLabel.isUserInteractionEnabled = true
        privacyPolicyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTap)))
    }

    @objc func termsOfUseTap() {
        if let url = URL(string: "https://melon-drawer-23e.notion.site/43d5209ed002411998698f51554c074a?pvs=4") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func privacyPolicyLabelTap() {
        if let url = URL(string: "https://melon-drawer-23e.notion.site/08b7900683944a66956bc8be87ba833b?pvs=4") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
