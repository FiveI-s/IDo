//
//  SignUpViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/20.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SnapKit
import SwiftSMTP
import UIKit
//  회원가입 페이지
final class SignUpViewController: UIViewController {
    private let signUpView = SignUpView()

    private let fbUserDatabaseManager: FirebaseCreateUserManager = .init(refPath: ["Users"])
    
    var smtp: SMTP!
    var verificationCode: String?
    var isEmailChecked: Bool = false
    var isButtonClicked: Bool = false
    var isPrivacyPolicy: Bool = false
    
    override func loadView() {
        view = signUpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navigationSet()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func navigationSet() {
        let configuration = UIImage.SymbolConfiguration(weight: .semibold) // .bold 또는 원하는 굵기로 설정
        let image = UIImage(systemName: "chevron.backward", withConfiguration: configuration)
        
        let backButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(clickBackButton))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")
        
        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "회원가입")
        }
    }
}

private extension SignUpViewController {
    func setup() {
        view.backgroundColor = .white
        setupButton()
        setupKeyboardEvent()
        setupHyperLink()
        signUpView.emailTextField.delegate = self
        signUpView.authenticationNumberTextField.delegate = self
        signUpView.passwordTextField.delegate = self
        signUpView.passwordConfirmTextField.delegate = self
    }

    func setupButton() {
        signUpView.nextButton.addTarget(self, action: #selector(clickNextButton), for: .touchUpInside)
        signUpView.eyeButton.addTarget(self, action: #selector(eyeClickButton), for: .touchUpInside)
        signUpView.confirmEyeButton.addTarget(self, action: #selector(confirmEyeClickButton), for: .touchUpInside)
        signUpView.linkButton.addTarget(self, action: #selector(clickLinkButton), for: .touchUpInside)
        signUpView.emailAuthorizationButton.addTarget(self, action: #selector(addSMTPButton), for: .touchUpInside)
        signUpView.authenticationNumberButton.addTarget(self, action: #selector(addSMTPNumberButton), for: .touchUpInside)
        signUpView.termsCheckButton.addTarget(self, action: #selector(termsCheckButtonAction), for: .touchUpInside)
        signUpView.privacyPolicycheckButton.addTarget(self, action: #selector(privacyPolicycheckButtonAction), for: .touchUpInside)
        // 텍스트 필드 감지
        signUpView.emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
    }

    func setupHyperLink() {
        guard let termsText = signUpView.termsLabel.text else { return }
        let termsAttributedString = NSMutableAttributedString(string: termsText)
        let termsRange = (termsText as NSString).range(of: "이용약관")
        let termsLinkAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://melon-drawer-23e.notion.site/43d5209ed002411998698f51554c074a?pvs=4")!, // 링크 URL
            .foregroundColor: UIColor.blue, // 링크 텍스트 색상
            .underlineStyle: NSUnderlineStyle.single.rawValue // 밑줄 스타일
        ]

        termsAttributedString.addAttributes(termsLinkAttributes, range: termsRange)

        // UILabel에 NSAttributedString 설정
        signUpView.termsLabel.attributedText = termsAttributedString

        // UILabel의 텍스트 선택 가능하게 설정
        signUpView.termsLabel.isUserInteractionEnabled = true
        signUpView.termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfUseTap)))
        
        guard let privacyPolicyText = signUpView.privacyPolicyLabel.text else { return }
        let privacyPolicyAttributedString = NSMutableAttributedString(string: privacyPolicyText)
        let privacyPolicyRange = (privacyPolicyText as NSString).range(of: "개인정보처리방침")
        let privacyPolicyLinkAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://melon-drawer-23e.notion.site/43d5209ed002411998698f51554c074a?pvs=4")!, // 링크 URL
            .foregroundColor: UIColor.blue, // 링크 텍스트 색상
            .underlineStyle: NSUnderlineStyle.single.rawValue // 밑줄 스타일
        ]

        privacyPolicyAttributedString.addAttributes(privacyPolicyLinkAttributes, range: privacyPolicyRange)

        // UILabel에 NSAttributedString 설정
        signUpView.privacyPolicyLabel.attributedText = privacyPolicyAttributedString

        // UILabel의 텍스트 선택 가능하게 설정
        signUpView.privacyPolicyLabel.isUserInteractionEnabled = true
        signUpView.privacyPolicyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTap)))
    }
    
    @objc func clickNextButton() {
        signUpView.nextButton.isEnabled = false
        defer {
            signUpView.nextButton.isEnabled = true
        }

        if let errorMessage = errorProcessing() {
            showAlertDialog(title: "경고", message: errorMessage)
            signUpView.nextButton.isEnabled = true
            return
        }
        
        Auth.auth().createUser(withEmail: signUpView.emailTextField.text!, password: signUpView.passwordTextField.text!) { [weak self] authDataResult, error in
            if let error = error {
                self?.signUpView.nextButton.isEnabled = true
                let nsError = error as NSError
                let errorCode = AuthErrorCode(_nsError: nsError)
                print(errorCode)
                switch errorCode.code {
                case .emailAlreadyInUse:
                    self?.showAlertDialog(title: "경고", message: "이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.")
                    self?.signUpView.emailAuthorizationButton.isEnabled = true
                    self?.signUpView.emailTextField.isEnabled = true
                    self?.signUpView.linkButton.isEnabled = true
                    self?.signUpView.emailAuthorizationButton.setTitleColor(UIColor(color: .white), for: .normal)
                    self?.signUpView.emailAuthorizationButton.backgroundColor = UIColor(color: .contentPrimary)
                    return
                case .weakPassword:
                    self?.showAlertDialog(title: "경고", message: "안정성이 낮은 비밀번호입니다.")
                case .invalidEmail:
                    self?.showAlertDialog(title: "경고", message: "이메일 주소의 형식이 잘못되었습니다.")
                default:
                    self?.showAlertDialog(title: "오류", message: error.localizedDescription)
                    return
                }
            } else {
                guard let authDataResult = authDataResult else { return }
                let uid = authDataResult.user.uid
                let user = IDoUser(id: uid, updateAt: Date().toString(), email: self?.signUpView.emailTextField.text!, nickName: "", description: nil, hobbyList: nil)
                self?.fbUserDatabaseManager.model = user
                self?.fbUserDatabaseManager.appendData(data: user)
                self?.navigateToCategorySelection()
            }
        }
    }

    private func errorProcessing() -> String? {
        guard let email = signUpView.emailTextField.text, !email.isEmpty else {
            return "이메일 또는 비밀번호를 입력하세요."
        }
        
        guard let password = signUpView.passwordTextField.text, !password.isEmpty, password.isValidPassword() else {
            return "비밀번호가 안전하지 않습니다."
        }
        
        guard let confirmPassword = signUpView.passwordConfirmTextField.text, !confirmPassword.isEmpty, password == confirmPassword else {
            return "비밀번호 재확인을 입력하세요."
        }
        
        guard signUpView.termsCheckButton.isSelected else {
            return "이용약관에 동의해주세요."
        }
        
        guard signUpView.privacyPolicycheckButton.isSelected else {
            return "개인정보처리방침에 동의해주세요."
        }
        
        if signUpView.authenticationNumberButton.title(for: .normal) != "완료",
           signUpView.authenticationNumberTextField.text?.isEmpty != false
        {
            return "인증번호를 입력하거나 확인해주세요."
        }
        
        return nil
    }

    private func navigateToCategorySelection() {
        let email = signUpView.emailTextField.text!
        let password = signUpView.passwordTextField.text!
        let categoryVC = CategorySelectViewController(email: email, password: password)
        navigationController?.pushViewController(categoryVC, animated: true)
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func smtpNumberCode(completion: @escaping (Bool) -> Void) {
        guard let userInputCode = signUpView.authenticationNumberTextField.text else {
            completion(false)
            return
        }
        if let savedCode = UserDefaults.standard.string(forKey: "emailVerificationCode"), savedCode == userInputCode {
            isEmailChecked = true
            signUpView.emailTextField.isEnabled = false
            completion(true)
        } else {
            signUpView.emailAuthorizationButton.isEnabled = true
            signUpView.authenticationNumberTextField.text = ""
            showAlertDialog(title: "경고", message: "인증번호가 일치하지 않습니다.")
            completion(false)
        }
    }

    func verifyButtonPressed(_ sender: UIButton) {
        smtpNumberCode { _ in
            print("success")
        }
    }
    
    func setupKeyboardEvent() {}
    
    @objc func keyboardWillShow(_ sender: Notification) {
        // keyboardFrame: 현재 동작하고 있는 이벤트에서 키보드의 frame을 받아옴
        // currentTextField: 현재 응답을 받고있는 UITextField를 알아냅니다.
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentResponder as? UITextField else { return }
        
        // Y축으로 키보드의 상단 위치
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        // 현재 선택한 텍스트 필드의 Frame 값
        let convertedTextFieldFrame = view.convert(currentTextField.frame,
                                                   from: currentTextField.superview)
        // Y축으로 현재 텍스트 필드의 하단 위치
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        // Y축으로 텍스트필드 하단 위치가 키보드 상단 위치보다 클 때 (즉, 텍스트필드가 키보드에 가려질 때가 되겠죠!)
        if textFieldBottomY > keyboardTopY {
            let textFieldTopY = convertedTextFieldFrame.origin.y
            // 노가다를 통해서 모든 기종에 적절한 크기를 설정함.
            let newFrame = textFieldTopY - keyboardTopY / 1.6
            view.frame.origin.y -= newFrame
        }
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }

    @objc func addSMTPButton() {
        guard isButtonClicked else {
            showAlertDialog(title: "경고", message: "중복확인 버튼을 눌러주세요.")
            return
        }
        guard let emailText = signUpView.emailTextField.text,
              !emailText.isEmpty,
              isValidEmail(emailText)
        else {
            showAlertDialog(title: "알림", message: "이메일 형식이 잘못되었거나 이메일이 비어있습니다.")
            return
        }
            
        // 이메일이 변경되었는지 확인해요.
        if !isEmailChecked {
            // 이메일이 변경되었다면, 중복확인을 다시 하도록 사용자에게 알려요.
            showAlertDialog(title: "알림", message: "이메일이 변경되었습니다. 중복확인을 다시 해주세요.")
            return
        }
        
        let smtp = SMTP(hostname: "smtp.naver.com", email: "ido345849@naver.com", password: "UX5W8Y7VUHLW")
        
        let drLight = Mail.User(name: "iDo", email: "ido345849@naver.com")
        let megaman = Mail.User(name: "사용자", email: signUpView.emailTextField.text!)
        
        let code = "\(Int.random(in: 100000 ... 999999))"
        print("code: \(code)")
        
        let mail = Mail(from: drLight, to: [megaman], subject: "IDo 이메일 코드", text: "인증 번호 \(code) \n" + "IDo 앱으로 돌아가 인증 번호를 입력해주세요.")
        
        DispatchQueue.global().async {
            smtp.send(mail) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("전송 실패: \(error)")
                        self?.showAlertDialog(title: "오류", message: "인증 번호를 보내는데 실패했습니다.")
                    } else {
                        print("전송 성공!")
                        UserDefaults.standard.set(code, forKey: "emailVerificationCode")
                        self?.showAlertDialog(title: "성공", message: "인증 번호가 이메일로 발송되었습니다.")
                    }
                }
            }
        }
    }

    @objc func emailTextFieldDidChange(_ textField: UITextField) {
        // 중복확인 버튼을 활성화해요.
        signUpView.linkButton.isEnabled = true
        // 인증 상태를 재설정해요.
        isEmailChecked = false
    }

    @objc func addSMTPNumberButton() {
        guard let email = signUpView.emailTextField.text, !email.isEmpty else {
            showAlertDialog(title: "경고", message: "이메일을 입력해주세요.")
            return
        }
        
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] signInMethods, error in
            if let error = error {
                print("Error checking for email existence: \(error)")
                self?.showAlertDialog(title: "오류", message: "이메일 확인 중 오류가 발생했습니다.")
                self?.signUpView.emailTextField.isEnabled = true
                self?.signUpView.linkButton.isEnabled = true
                return
            }
                
            if let signInMethods = signInMethods, !signInMethods.isEmpty {
                self?.showAlertDialog(title: "경고", message: "이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.")
                self?.signUpView.emailTextField.isEnabled = true
                self?.signUpView.linkButton.isEnabled = false
            } else {
                self?.smtpNumberCode { success in
                    if success {
                        self?.signUpView.emailTextField.isEnabled = false
                        self?.isEmailChecked = true
                        self?.signUpView.linkButton.isEnabled = false

                        self?.showAlertDialog(title: "인증", message: "인증이 성공적으로 처리되었습니다")
                            
                        self?.signUpView.authenticationNumberButton.setTitle("완료", for: .normal)
                        self?.signUpView.authenticationNumberButton.isEnabled = false
                        self?.signUpView.authenticationNumberButton.setTitleColor(UIColor(color: .borderSelected), for: .normal)
                        self?.signUpView.authenticationNumberButton.backgroundColor = UIColor(color: .contentBackground)
                        self?.signUpView.emailAuthorizationButton.isEnabled = false
                        self?.signUpView.emailAuthorizationButton.setTitleColor(.darkGray, for: .normal)
                        self?.signUpView.emailAuthorizationButton.backgroundColor = UIColor(color: .placeholder)
                    } else {
                        self?.showAlertDialog(title: "경고", message: "인증번호가 일치하지 않습니다.")
                        self?.signUpView.emailTextField.isEnabled = true
                        self?.isEmailChecked = false
                        self?.signUpView.linkButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    @objc func eyeClickButton() {
        signUpView.passwordTextField.isSecureTextEntry.toggle()
        signUpView.eyeButton.isSelected.toggle()
    }
    
    @objc func confirmEyeClickButton() {
        signUpView.passwordConfirmTextField.isSecureTextEntry.toggle()
        signUpView.confirmEyeButton.isSelected.toggle()
    }
    
    @objc func clickBackButton() {
        dismiss(animated: true)
    }
    
    @objc func clickLinkButton() {
        isButtonClicked = true
        print("중복 확인 버튼이 클릭되었습니다")
        guard let email = signUpView.emailTextField.text, !email.isEmpty else {
            showAlertDialog(title: "경고", message: "이메일을 입력해주세요.")
            return
        }
        
        guard isValidEmail(email) else {
            showAlertDialog(title: "경고", message: "올바른 이메일 형식을 입력해주세요.")
            return
        }

        print("중복확인: \(email)")
        let firebaseManager: FBDatabaseManager<IDoUser> = FBDatabaseManager(refPath: ["Users"])
        firebaseManager.readDatas(completion: { result in
            switch result {
            case .success(let users):
                let emailList = users.compactMap { $0.email }
                if emailList.contains(email) {
                    self.showAlertDialog(title: "경고", message: "현재 사용 중인 아이디입니다.")
                } else {
                    self.isEmailChecked = true
                    self.showAlertDialog(title: "알림", message: "사용 가능한 아이디입니다.")
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.showAlertDialog(title: "오류", message: "중복 확인 중 오류가 발생했습니다.")
            }
        })
    }
    
    @objc func termsCheckButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    @objc func privacyPolicycheckButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.(com|co\\.kr|net)"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
        if NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self) {
            return true
        } else {
            if count < 8 {
                print("비밀번호는 최소 8자 이상이어야 합니다.")
            }
            return false
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        
        if textField == signUpView.passwordTextField {
            // passwordTextField의 유효성 검사
            signUpView.passwordErrorLabel.isHidden = currentText.isValidPassword()
            validatePasswordConfirm()
        } else if textField == signUpView.passwordConfirmTextField {
            validatePasswordConfirm()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    private func validatePasswordConfirm() {
        let passwordText = signUpView.passwordTextField.text ?? ""
        let passwordConfirmText = signUpView.passwordConfirmTextField.text ?? ""

        if passwordText == passwordConfirmText {
            signUpView.passwordConfirmErrorLabel.isHidden = false
            signUpView.passwordConfirmErrorLabel.textColor = .green
            signUpView.passwordConfirmErrorLabel.text = "비밀번호가 일치합니다."
        } else if !passwordConfirmText.isEmpty {
            signUpView.passwordConfirmErrorLabel.textColor = .red
            signUpView.passwordConfirmErrorLabel.isHidden = false
            signUpView.passwordConfirmErrorLabel.text = "비밀번호가 일치하지 않습니다."
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension UIResponder {
    private enum Static {
        weak static var responder: UIResponder?
    }
    
    static var currentResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}
