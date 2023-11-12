//
//  SingUpProfileViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/23.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SnapKit
import UIKit
 // 회원가입 프로필 페이지
class SignUpProfileViewController: UIViewController {
    private let email: String
    private let password: String
    private let selectedCategorys: [String]
    private var user: IDoUser?
    private let fbUserDatabaseManager: FirebaseCreateUserManager = .init(refPath: ["Users"])
    private let imagePickerViewController: UIImagePickerController = .init()

    private var aboutUs: String = ""
    private var nickName: String = ""

    // MARK: - 컴포넌트 생성

    private let profileImageView: UIImageView = .init(image: UIImage(systemName: "camera.circle.fill"))

    private var scrollView: UIScrollView = .init()
//    private var containerView: UIView = UIView()
    // 닉네임 입력 TextView
    private(set) lazy var nickNameTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundPrimary)
        textView.font = UIFont.bodyFont(.large, weight: .medium)
        textView.text = "닉네임을 입력해주세요"
        textView.textColor = UIColor(color: .placeholder)
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 1.0
        textView.resignFirstResponder()
        return textView
    }()

    // 닉네임 글자 수 표시 label
    private(set) lazy var nickNameCountLabel: UILabel = {
        var label = UILabel()
        label.text = "(0/6)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()

    // 자기소개 입력 TextView
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundPrimary)
        textView.font = UIFont.bodyFont(.medium, weight: .regular)
        textView.text = "자기소개를 입력해주세요"
        textView.textColor = UIColor(color: .placeholder)
        // textView.textAlignment = .left
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 1.0
        textView.resignFirstResponder()
        return textView
    }()

    // 자기소개 글자 수 표시 label
    private(set) lazy var descriptionCountLabel: UILabel = {
        var label = UILabel()
        label.text = "(0/300)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()

    private let bottomView: UIView = .init()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(color: .white), for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        return button
    }()

    init(email: String, password: String, selectedCategorys: [String]) {
        self.email = email
        self.password = password
        self.selectedCategorys = selectedCategorys
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // 백 버튼 아이템 생성 및 설정
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")

        // 타이틀 생성 및 설정
        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "프로필 생성")
        }

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nickNameTextView.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height

        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide).offset(-keyboardHeight)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

private extension SignUpProfileViewController {
    // MARK: - UI 및 오토레이아웃 관련

    func setup() {
        addViews()
        setupAutoLayout()
        setupTextField()
        setupImagePicker()
        setupImageView()
        setupButton()
        setupScrollView()
    }

    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(nickNameTextView)
        scrollView.addSubview(nickNameCountLabel)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(descriptionCountLabel)
        scrollView.addSubview(signUpButton)
    }

    func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalTo(scrollView).inset(Constant.margin3)
            make.centerX.equalTo(safeArea)
        }
        nickNameTextView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Constant.margin3)
            make.height.equalTo(40)
            make.left.right.equalTo(scrollView.frameLayoutGuide).inset(Constant.margin4)
        }

        nickNameCountLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(scrollView.frameLayoutGuide).inset(Constant.margin4)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(nickNameCountLabel.snp.bottom).offset(Constant.margin4)
            make.left.right.equalTo(scrollView.frameLayoutGuide).inset(Constant.margin4)
            make.height.equalTo(200)
        }
        descriptionCountLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(scrollView.frameLayoutGuide).inset(Constant.margin4)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Constant.margin3)
        }
        signUpButton.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.bottom.equalTo(scrollView).inset(Constant.margin3)
            make.height.equalTo(48)
        }
    }

    // MARK: - 컴포넌트 세팅 관련

    func setupTextField() {
        nickNameTextView.delegate = self
        descriptionTextView.delegate = self
    }

    func setupImageView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImagePick))
        profileImageView.addGestureRecognizer(gesture)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layoutIfNeeded()
        profileImageView.tintColor = UIColor(color: .contentBackground)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.layer.masksToBounds = true
    }

    @objc func profileImagePick() {
        present(imagePickerViewController, animated: true)
    }

    func setupImagePicker() {
        imagePickerViewController.sourceType = .photoLibrary
        imagePickerViewController.delegate = self
    }

    func setupButton() {
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }

    func setupScrollView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTap))
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGesture)
    }

    @objc func signUp() {
        signUpButton.isEnabled = false

        guard !nickNameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, nickNameTextView.textColor == UIColor.black else {
            AlertManager.showAlert(on: self, title: "알림", message: "닉네임을 입력해주세요.")
            return
        }
        guard !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, descriptionTextView.textColor == UIColor.black else {
            AlertManager.showAlert(on: self, title: "알림", message: "자기소개를 입력해주세요.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            guard let self = self else { return }

            self.signUpButton.isEnabled = true

            if error != nil {
                AlertManager.showAlert(on: self, title: "알림", message: "로그인에 실패하였습니다.")
                return
            }
            guard let authDataResult = authDataResult else { return }
            let uid = authDataResult.user.uid
            let user = IDoUser(id: uid, updateAt: Date().toString(), email: email, nickName: nickNameTextView.text, description: descriptionTextView.text, hobbyList: self.selectedCategorys)

            self.fbUserDatabaseManager.model = user
            self.fbUserDatabaseManager.appendData(data: user)
            self.fbUserDatabaseManager.addImage(uid: uid, image: profileImageView.image)
            self.firebaseLogin()
        }
    }

    func firebaseLogin() {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if let error {
                print("Login Error: \(error.localizedDescription)")
                return
            }
            guard let authData else { return }
            let uid = authData.user.uid
            MyProfile.shared.getUserProfile(uid: uid) { isSuccess in
                guard isSuccess else {
                    print("사용자 정보를 가져오지 못했습니다.")
                    return
                }
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(TabBarController(), animated: true)
            }
        }
    }

    @objc func scrollViewTap() {
        view.endEditing(true)
    }
}

// MARK: - 텍스트 뷰 관련

extension SignUpProfileViewController: UITextViewDelegate {
    func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-2, 2, -2, 2, -2, 2] // 애니메이션 값 조정
        view.layer.add(animation, forKey: "shake")
    }

    // 초기 호출
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 이름 textView
        if textView == nickNameTextView {
            if nickNameTextView.textColor == UIColor(color: .placeholder) {
                nickNameTextView.text = nil
                nickNameTextView.textColor = UIColor.black
            }
        }

        // 내용 textView
        if textView == descriptionTextView {
            if descriptionTextView.textColor == UIColor(color: .placeholder) {
                descriptionTextView.text = nil
                descriptionTextView.textColor = UIColor.black
            }
        }
    }

    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        if textView == nickNameTextView {
            let textCount = textView.text.count
            nickNameCountLabel.text = "(\(textCount)/6)"

            if textCount == 0 {
                nickNameCountLabel.textColor = UIColor(color: .placeholder)
            } else {
                nickNameCountLabel.textColor = UIColor.black
            }
        }

        if textView == descriptionTextView {
            let textCount = textView.text.count
            descriptionCountLabel.text = "(\(textCount)/300)"

            if textCount == 0 {
                descriptionCountLabel.textColor = UIColor(color: .placeholder)
            } else {
                descriptionCountLabel.textColor = UIColor.black
            }
        }
    }

    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        if nickNameTextView.text.isEmpty {
            nickNameTextView.text = "닉네임을 입력해주세요."
            nickNameTextView.textColor = UIColor(color: .placeholder)
        }

        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "자기소개를 입력해주세요."
            descriptionTextView.textColor = UIColor(color: .placeholder)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let changedText = currentText.replacingCharacters(in: stringRange, with: text)

        if textView == nickNameTextView {
            if text == "\n" {
                descriptionTextView.becomeFirstResponder()
                return false
            }
            if changedText.count > 6 {
                nickNameCountLabel.textColor = UIColor.red
                shakeAnimation(for: nickNameCountLabel)
                return false
            }
            return true
        }

        if textView == descriptionTextView {
            if changedText.count > 300 {
                descriptionCountLabel.textColor = UIColor.red
                shakeAnimation(for: descriptionCountLabel)
                return false
            }
            return true
        }
        return true
    }
}

// MARK: - 이미지 피커 관련

extension SignUpProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.editedImage] as? UIImage {
                self.profileImageView.image = image
            } else if let image = info[.originalImage] as? UIImage {
                self.profileImageView.image = image
            }
        }
    }
}

extension SignUpProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        nickName = text
    }
}
