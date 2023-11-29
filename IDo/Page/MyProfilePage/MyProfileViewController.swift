//
//  MyProfileViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import FirebaseAuth
import SnapKit
import UIKit

class MyProfileViewController: UIViewController {
    private var firebaseManager: FBDatabaseManager<IDoUser>!
    private let scrollView: UIScrollView = UIScrollView()
    var userProfile: UserSummary?
    
    // 프로필
    var profileImage = UIButton()
    var profileName = UITextView()
    var choicePickerView = UIPickerView()
    var toolBar = UIToolbar()
    var selectedHobby = ""
    var choiceEnjoyTextField = UITextField()
    var hobbyList: [String] {
        return MyProfile.shared.myUserInfo?.hobbyList ?? []
    }

    let enjoyList = ["IT•개발", "사진•영상", "음악•악기", "게임•오락", "여행•맛집", "댄스•공연", "동물•식물", "낚시•캠핑", "운동•스포츠"]

    // 자기소개
    let selfInfo = UILabel()
    var selfInfoDetail = UITextView()
    var selfInfoInt = UILabel()
        
    // 내가쓴글
    let writeMe = UILabel()
    var writeMeList = ["헬린이 멤버 구합니다", "카본 낚시대 20만원선에서 추천 받아요"]
    var writeMeDate = ["yyyy-mm-dd", "yyyy-mm-dd"]
    var writeMeTableView = UITableView()
        
    // 로그아웃, 세로 구분선, 회원탈퇴
    var logout = UIButton()
    let line = UIView()
    var deleteID = UIButton()
        
    // 수정화면 false 고정
    var isEdit = false
        
    func makeProfileImage() {
        profileImage.imageView?.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = false
    }
        
    func makeProfileName() {
        profileName.text = ""
        profileName.textAlignment = .center
        profileName.textColor = UIColor(named: "ui-text-strong")
        profileName.font = UIFont.headFont(.xSmall, weight: .medium)
        profileName.layer.cornerRadius = 10
        profileName.isUserInteractionEnabled = false
    }
        
    func makeChoiceEnjoyTextField() {
        choiceEnjoyTextField.text = ""
        choiceEnjoyTextField.textColor = UIColor(color: .borderSelected)
        choiceEnjoyTextField.backgroundColor = UIColor(color: .contentBackground)
        choiceEnjoyTextField.font = UIFont.bodyFont(.small, weight: .medium)
        choiceEnjoyTextField.layer.cornerRadius = 10 // 원하는 값으로 설정
        choiceEnjoyTextField.layer.borderWidth = 5 // 원하는 두께로 설정
        // 원하는 테두리 색상으로 설정
        choiceEnjoyTextField.layer.borderColor = UIColor(color: .contentBackground).cgColor
        choiceEnjoyTextField.clipsToBounds = true
        choiceEnjoyTextField.textAlignment = .center
        choiceEnjoyTextField.isUserInteractionEnabled = false
        choiceEnjoyTextField.tintColor = .clear
    }
        
    func makeSelfInfo() {
        selfInfo.text = "자기소개"
        selfInfo.textColor = .black
        selfInfo.font = UIFont.bodyFont(.medium, weight: .medium)
    }
        
    func makeSelfInfoDetail() {
        selfInfoDetail.text = ""
        selfInfoDetail.font = UIFont.bodyFont(.medium, weight: .regular)
        selfInfoDetail.textColor = UIColor(named: "ui-text-strong")
        selfInfoDetail.backgroundColor = UIColor(color: .backgroundSecondary)
        selfInfoDetail.layer.cornerRadius = 10
        selfInfoDetail.textContainerInset = UIEdgeInsets(top: 9, left: 8, bottom: 0, right: 9)
        selfInfoDetail.isScrollEnabled = true
    }

    func makeselfInfoInt() {
        selfInfoInt.text = "(\(selfInfoDetail.text.count)/300)"
        selfInfoInt.textColor = UIColor(color: .placeholder)
        selfInfoInt.font = UIFont.bodyFont(.small, weight: .medium)
    }
        
    func makeWriteMe() {
        writeMe.text = "작성한 글"
        writeMe.textColor = .black
        writeMe.font = UIFont.bodyFont(.medium, weight: .medium)
    }
        
    func makeWriteMeTableView() {
        writeMeTableView.register(WriteMeTableViewCell.self, forCellReuseIdentifier: "Cell")
        writeMeTableView.dataSource = self
        writeMeTableView.delegate = self
    }
        
    func makeLogout() {
        logout.setTitle("로그아웃", for: .normal)
        logout.titleLabel?.font = UIFont.bodyFont(.small, weight: .medium)
        logout.setTitleColor(.lightGray, for: .normal)
        logout.backgroundColor = .none
        logout.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    func makeLine() {
        line.backgroundColor = UIColor.lightGray
    }
        
    func makeDeleteID() {
        deleteID.setTitle("회원탈퇴", for: .normal)
        deleteID.setTitleColor(.lightGray, for: .normal)
        deleteID.titleLabel?.font = UIFont.bodyFont(.small, weight: .medium)
        deleteID.backgroundColor = .none
        deleteID.addTarget(self, action: #selector(deleteIDButtonTapped), for: .touchUpInside)
    }

    func updateButtonTitle() {
        let hobbiesString = hobbyList.joined(separator: ", ")
        choiceEnjoyTextField.text = hobbiesString
    }
    
    func updateSelfInfoIntLabel() {
        let textCount = selfInfoDetail.text.count
        selfInfoInt.text = "(\(textCount)/300)"
    }

    // 로딩되는 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        makeChoiceEnjoyTextField()
        updateButtonTitle()
        makeProfileImage()
        makeProfileName()
        makeSelfInfo()
        makeSelfInfoDetail()
        updateSelfInfoIntLabel()
        makeWriteMe()
        makeWriteMeTableView()
        makeLogout()
        makeDeleteID()
        makeLine()
        makeselfInfoInt()
        setLayout()
        profileEditControllerSet()
        navigationBarButtonAction()
        buttonAction()
        setupPickerView()
        setupScrollView()
        navigationController?.delegate = self
        profileName.delegate = self
        choicePickerView.delegate = self
        choicePickerView.dataSource = self
        selfInfoDetail.delegate = self
        choiceEnjoyTextField.delegate = self

        isEdit = false
    }
        
    // 로드가 된 뒤에 보여지는 뷰
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonTitle()
        profileName.resignFirstResponder()
        selfInfoDetail.resignFirstResponder()
        getProfile()
        updateSelfInfoIntLabel()
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
    }
    
    // MARK: - 사용자 정보 불러오기
    private func getProfile() {
        if let profile = userProfile {
            profileName.text = profile.nickName
            selfInfoDetail.text = profile.description
        }
        else {
            guard let myProfile = MyProfile.shared.myUserInfo else { return }
            profileName.text = myProfile.nickName
            if let hobby = myProfile.hobbyList?.first {
                choiceEnjoyTextField.text = hobby
            }
            if let description = myProfile.description {
                selfInfoDetail.text = description
            }
            if let profileMediumImageData = myProfile.profileImage[ImageSize.medium.rawValue],
               let profileMediumImage = UIImage(data: profileMediumImageData) {
                profileImage.setImage(profileMediumImage, for: .normal)
                return
            }
            guard let imagePath = myProfile.profileImagePath else {
                self.profileImage.setImage(UIImage(named: "profile"), for: .normal)
                return
            }
            MyProfile.shared.loadImage(defaultPath: imagePath, paths: [.medium]) {
                if let imageData = MyProfile.shared.myUserInfo?.profileImage[ImageSize.medium.rawValue],
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.profileImage.setImage(image, for: .normal)
                    }
                }
            }
        }
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
        let adjustmentHeight = keyboardHeight - (self.tabBarController?.tabBar.frame.size.height ?? 0)
        
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide).offset(-adjustmentHeight)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupScrollView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTap))
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func scrollViewTap() {
        view.endEditing(true)
    }
        
    func setLayout() {
        view.backgroundColor = UIColor(color: .backgroundPrimary)
        view.addSubview(scrollView)
        scrollView.addSubview(profileImage)
        scrollView.addSubview(profileName)
        scrollView.addSubview(selfInfo)
        scrollView.addSubview(selfInfoDetail)
//        view.addSubview(writeMe)
//        view.addSubview(writeMeTableView)
        scrollView.addSubview(logout)
        scrollView.addSubview(deleteID)
        scrollView.addSubview(selfInfoInt)
        scrollView.addSubview(line)
        scrollView.addSubview(choiceEnjoyTextField)
        
        let safeArea = view.safeAreaLayoutGuide
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(Constant.margin3)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        profileName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.height.equalTo(45)
        }
        choiceEnjoyTextField.snp.makeConstraints { make in
            make.top.equalTo(profileName.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(130)
            make.height.equalTo(35)
        }
        selfInfo.snp.makeConstraints { make in
            make.top.equalTo(choiceEnjoyTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        selfInfoDetail.snp.makeConstraints { make in
            make.top.equalTo(selfInfo.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        selfInfoInt.snp.makeConstraints { make in
            make.top.equalTo(selfInfoDetail.snp.bottom).offset(5)
            make.trailing.equalTo(selfInfoDetail).offset(-5)
        }
//        writeMe.snp.makeConstraints { make in
//            make.top.equalTo(selfInfoInt.snp.bottom).offset(5)
//            make.leading.trailing.equalToSuperview().inset(20)
//        }
//        writeMeTableView.snp.makeConstraints { make in
//            make.top.equalTo(writeMe.snp.bottom).offset(0)
//            make.leading.trailing.equalToSuperview().inset(20)
//            make.height.equalTo(140)
//        }
        logout.snp.makeConstraints { make in
            make.right.equalTo(line).offset(-Constant.margin2)
            make.width.equalTo(70)
            make.bottom.equalTo(scrollView).inset(Constant.margin3)
        }
        line.snp.makeConstraints { make in
            make.centerY.equalTo(logout)
            make.centerX.equalTo(scrollView)
            make.width.equalTo(1)
            make.height.equalTo(12)
        }
        deleteID.snp.makeConstraints { make in
            make.centerY.equalTo(line)
            make.leading.equalTo(line.snp.trailing).offset(Constant.margin2)
            make.width.equalTo(70)
            make.bottom.equalTo(scrollView).inset(Constant.margin3)
        }
    }
               
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// 자기소개 300자 제한 및 Label로 입력 글자수 표시
extension MyProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 입력 글자 수 표시
        if textView == selfInfoDetail {
            let textCount = selfInfoDetail.text.count
            selfInfoInt.text = "(\(textCount)/300)"
                
            if textCount == 0 {
                selfInfoInt.textColor = UIColor(color: .placeholder)
            } else {
                selfInfoInt.textColor = UIColor.black
            }
        }
    }

    // 자기소개 글 300자 제한 표시
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
            
        let chagedText = currentText.replacingCharacters(in: stringRange, with: text)
            
        if textView == profileName {
            return chagedText.count <= 6
        }
        
        if textView === selfInfoDetail {
            return chagedText.count <= 300
        }
        return true
    }

    // 피커뷰 셋팅
    func setupPickerView() {
        choicePickerView.delegate = self
        choicePickerView.dataSource = self
            
        // TextField 입력 방식을 PickerView로 변경
        choiceEnjoyTextField.inputView = choicePickerView

        // Toolbar 설정
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        // 완료 버튼 추가
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(onPickDone))
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        toolBar.setItems([doneButton, btnCancel], animated: false)
        toolBar.isUserInteractionEnabled = true
            
        // Button에 PickerView와 Toolbar 설정
        choiceEnjoyTextField.inputView = choicePickerView
        choiceEnjoyTextField.inputAccessoryView = toolBar
    }
}

// 테이블뷰 설정
extension MyProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return writeMeList.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!
            WriteMeTableViewCell
        if tableView == writeMeTableView {
            cell.write.text = writeMeList[indexPath.row]
            cell.write2.text = writeMeDate[indexPath.row]
        }
        cell.writeImageView.image = UIImage(systemName: "photo")
        return cell
    }
}

// MARK: - 네비게이션 바
private extension MyProfileViewController {
    func profileEditControllerSet() {
        // 네비게이션 LargeTitle 비활성화 및 title 입력
        navigationController?.navigationBar.prefersLargeTitles = false
    }
        
    func navigationBarButtonAction() {
        // 네비게이션 오른쪽 버튼 생성
        let editButton = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(editVC))
        let blockListButton = UIBarButtonItem(title: "차단 목록", style: .plain, target: self, action: #selector(moveBlockList))
        blockListButton.tintColor = UIColor(color: .negative)
        navigationItem.rightBarButtonItems = [editButton, blockListButton]
        navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(profileUpdateCancle))
        hiddenLeftButton()
            
        // 백 버튼 아이템 생성 및 설정
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")
    }
    
    // 취소 버튼을 숨기고 문구를 표시
    private func hiddenLeftButton() {
        navigationItem.leftBarButtonItem = nil
        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "")
        }
        showLeftLabel()
    }
    
    // 취소 버튼을 보이고, 타이틀에 프로필 편집 문구를 표시
    private func unHiddenLeftButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(profileUpdateCancle))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(color: .negative)
        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "프로필 편집")
        }
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    // 취소 버튼을 눌렀을 때
    @objc func profileUpdateCancle() {
        isEdit.toggle()
        
        guard let myProfile = MyProfile.shared.myUserInfo else {
            print("사용자 정보가 없습니다.")
            return
        }
        
        hiddenLeftButton()
        
        navigationItem.rightBarButtonItems?.first?.title = "수정"
        
        profileName.isUserInteractionEnabled = false
        profileName.backgroundColor = .clear
        profileName.text = myProfile.nickName
        
        selfInfoDetail.isUserInteractionEnabled = false
        selfInfoDetail.text = myProfile.description
        
        selfInfoInt.text = "(\(myProfile.description?.count ?? 0)/300)"
        selfInfoInt.textColor = UIColor(color: .placeholder)
        
        choiceEnjoyTextField.isUserInteractionEnabled = false
        choiceEnjoyTextField.text = myProfile.hobbyList?.first
        
        // 작성한글 title Label 나타내기
        writeMe.isHidden = false
        
        // 작성한글 리스트 나타내기
        writeMeTableView.isHidden = false
        logout.isHidden = false
        line.isHidden = false
        deleteID.isHidden = false
        profileImage.isUserInteractionEnabled = false
        
        if let data = myProfile.profileImage[ImageSize.medium.rawValue],
           let image = UIImage(data: data) {
            profileImage.setImage(image, for: .normal)
        } else {
            profileImage.setImage(UIImage(named: "profile"), for: .normal)
        }
        
        choiceEnjoyTextField.tintColor = .clear
    }
    
    @objc func moveBlockList() {
        let vc = BlockListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 수정 버튼을 눌렀을 때
    @objc func editVC() {
        // 기본 isEdit은 false. toggle(전등스위치개념) 사용하여 true(수정중인 상태)로 바꿔줌
        isEdit.toggle()
                
        // isEdit = true인 상태의 실행 코드
        if isEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(editVC))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
            
            unHiddenLeftButton()
            
            // 각각 텍스트뷰를 활성화 시킴
            profileName.isUserInteractionEnabled = true
            profileName.backgroundColor = UIColor(color: .backgroundSecondary)
            selfInfoDetail.isUserInteractionEnabled = true
            selfInfoInt.textColor = UIColor(color: .textStrong)
            choiceEnjoyTextField.isUserInteractionEnabled = true
            
            writeMe.isHidden = true // "작성한글" title Label 숨기기
            writeMeTableView.isHidden = true // 작성한글 리스트 숨기기
            logout.isHidden = true
            line.isHidden = true
            deleteID.isHidden = true
            profileImage.isUserInteractionEnabled = true
            choiceEnjoyTextField.tintColor = .clear
            
            
            // isEdit = false인 상태의 실행 코드
        } else {
            if profileName.text.count == 0 {
                AlertManager.showAlert(on: self, title: "알림", message: "닉네임을 입력하세요.")
                isEdit = true
            }
            else {
                navigationItem.rightBarButtonItems?.first?.title = "수정"
                hiddenLeftButton()
                
                profileName.isUserInteractionEnabled = false
                profileName.backgroundColor = .clear
                selfInfoDetail.isUserInteractionEnabled = false
                selfInfoInt.textColor = UIColor(color: .placeholder)
                choiceEnjoyTextField.isUserInteractionEnabled = false
                
                writeMe.isHidden = false // 작성한글 title Label 나타내기
                writeMeTableView.isHidden = false // 작성한글 리스트 나타내기
                logout.isHidden = false
                line.isHidden = false
                deleteID.isHidden = false
                profileImage.isUserInteractionEnabled = false
                choiceEnjoyTextField.tintColor = .clear
                guard let hobby = choiceEnjoyTextField.text else {
                    print("관심사가 업습니다.")
                    return
                }
                MyProfile.shared.update(nickName: profileName.text, updateProfileImage: profileImage.image(for: .normal), description: selfInfoDetail.text, hobbyList: [hobby])
            }
        }
    }
    
    private func showLeftLabel() {
        let label = UILabel()
        label.text = "i들아 모여라" // 원하는 문구로 대체
        label.font = UIFont.headFont(.xSmall , weight: .bold)
        label.textColor = UIColor(color: .borderSelected)
        let containerView = UIView()
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7) // 또는 적절한 값을 사용
            make.top.bottom.trailing.equalToSuperview()
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
}

// 프로필이미지 버튼 눌렀을때 Action
extension MyProfileViewController: UINavigationControllerDelegate {}

private extension MyProfileViewController {
    func buttonAction() {
        profileImage.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
    }
        
    @objc func addPicture() {
        let imagePicker1 = UIImagePickerController()
        imagePicker1.delegate = self
        imagePicker1.sourceType = .photoLibrary
        present(imagePicker1, animated: true, completion: nil)
    }
}

// 프로필이미지 버튼 누른 후 변경된 이미지 저장 및 갤러리 dismiss
extension MyProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImage.setImage(image, for: .normal)
        }
            
        picker.dismiss(animated: true, completion: nil)
    }
        
    @objc func logoutButtonTapped() {
        let alertController = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
            
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
            
        // 로그아웃 버튼 추가
        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
                
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                print("로그아웃 성공")
                if let navigationController = self.navigationController {
                    navigationController.popToRootViewController(animated: true)
                    let loginViewController = LoginViewController()
                    loginViewController.hidesBottomBarWhenPushed = true
                    loginViewController.modalPresentationStyle = .fullScreen
                    self.present(loginViewController, animated: true, completion: nil)
                }
            } catch let signOutError as NSError {
                print("로그아웃 오류: %@", signOutError)
            }
        }
        alertController.addAction(logoutAction)
            
        // 알림창 표시
        present(alertController, animated: true, completion: nil)
    }
        
    @objc func deleteIDButtonTapped() {
        let alertController = UIAlertController(title: "회원탈퇴", message: "회원 탈퇴를 진행하시겠습니까?", preferredStyle: .alert)
            
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
            
        // 로그아웃 버튼 추가
        let deleteIDAction = UIAlertAction(title: "회원탈퇴", style: .destructive) { [weak self] _ in
            self?.showPasswordAlert()
        }
        alertController.addAction(deleteIDAction)
            
        // 알림창 표시
        present(alertController, animated: true, completion: nil)
    }

    @objc func onPickDone() {
        choiceEnjoyTextField.resignFirstResponder() /// 피커뷰 내림
    }

    @objc func onPickCancel() {
        choiceEnjoyTextField.resignFirstResponder() /// 피커뷰 내림
    }

    @objc func choiceEnjoyButtonTapped(_ sender: UIButton) {
        sender.becomeFirstResponder() // PickerView를 활성화
        let pickerContainer = UIView()
        pickerContainer.addSubview(choicePickerView)
        pickerContainer.addSubview(toolBar)
        view.addSubview(pickerContainer)
        sender.becomeFirstResponder()
    }
    
    func showPasswordAlert() {
        // AlertController 생성
        let alertController = UIAlertController(title: "알림", message: "비밀번호를 입력해주세요.", preferredStyle: .alert)
        
        // 비밀번호 입력 필드 추가
        alertController.addTextField { textField in
            textField.placeholder = "비밀번호"
            textField.isSecureTextEntry = true // 비밀번호 입력 필드로 설정
        }
        
        // 확인 버튼 액션
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let passwordField = alertController.textFields?.first else { return }
            // 여기에서 사용자가 입력한 비밀번호 처리
            guard let password = passwordField.text else { return }
            let userDatabaseManager = FBDatabaseManager<IDoUser>(refPath: ["Users"])
            guard let user = MyProfile.shared.myUserInfo?.toIDoUser else { return }
            MyProfile.shared.deleteAllUserData() { success in
                if success {
                    userDatabaseManager.deleteData(data: user) { [weak self] success in
                        if success {
                            if let user = Auth.auth().currentUser, let email = user.email {
                                let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
                                
                                user.reauthenticate(with: credential, completion: { (result, error) in
                                    if let error = error {
                                        // 재인증 오류 처리
                                        print(error.localizedDescription)
                                    } else {
                                        // 재인증이 성공적으로 완료되었다면 작업 진행
                                        user.delete { [self] error in
                                            if let error = error {
                                                print("Firebase Error : ", error)
                                            } else {
                                                
                                                print("회원탈퇴 성공!")
                                                DispatchQueue.main.async {
                                                    if let navigationController = self?.navigationController {
                                                        navigationController.popToRootViewController(animated: true)
                                                        let loginViewController = LoginViewController()
                                                        loginViewController.hidesBottomBarWhenPushed = true
                                                        loginViewController.modalPresentationStyle = .fullScreen
                                                        self?.present(loginViewController, animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                })
                                
                            } else {
                                print("로그인 정보가 존재하지 않습니다")
                            }
                        }
                    }
                }
            }
            print("입력된 비밀번호: \(String(describing: password))")
        }
        
        // 취소 버튼 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 버튼을 AlertController에 추가
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        // AlertController 표시
        present(alertController, animated: true, completion: nil)
    }
}

extension MyProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enjoyList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return enjoyList[row]
    }

    // PickerView에서 선택한 값으로 버튼 제목을 업데이트
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedHobby = enjoyList[row]
        choiceEnjoyTextField.text = selectedHobby
    }
}

extension MyProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == choiceEnjoyTextField {}
        return true
    }
}
