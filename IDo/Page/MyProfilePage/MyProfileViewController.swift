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
        profileImage.setImage(UIImage(named: "profile"), for: .normal)
        profileImage.imageView?.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
    }
        
    func makeProfileName() {
        profileName.text = "애라링"
        profileName.textAlignment = .center
        profileName.textColor = .black
        profileName.font = UIFont.headFont(.xSmall, weight: .medium)
        profileName.isUserInteractionEnabled = false
    }
        
    func makeChoiceEnjoyTextField() {
        choiceEnjoyTextField.text = ""
        choiceEnjoyTextField.textColor = UIColor(color: .borderSelected)
        choiceEnjoyTextField.backgroundColor = UIColor(color: .contentBackground)
        choiceEnjoyTextField.font = UIFont.bodyFont(.small, weight: .medium)
        choiceEnjoyTextField.layer.cornerRadius = 10 // 원하는 값으로 설정
        choiceEnjoyTextField.layer.borderWidth = 5 // 원하는 두께로 설정
        choiceEnjoyTextField.layer.borderColor = UIColor(color: .contentBackground).cgColor // 원하는 테두리 색상으로 설정
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
        selfInfoDetail.font = UIFont.bodyFont(.medium, weight: .regular)
        selfInfoDetail.text = ""
        selfInfoDetail.textColor = UIColor(named: "ui-text-strong")
        selfInfoDetail.backgroundColor = UIColor(color: .backgroundSecondary)
        selfInfoDetail.layer.cornerRadius = 10
        selfInfoDetail.textContainerInset = UIEdgeInsets(top: 9, left: 8, bottom: 0, right: 9)
        selfInfoDetail.isUserInteractionEnabled = false
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

    /// TextField 업데이트
    func updateTextFieldText() {
        let hobbiesString = hobbyList.joined(separator: ", ")
        choiceEnjoyTextField.text = hobbiesString
    }

    // 로딩되는 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        makeChoiceEnjoyTextField()
        updateTextFieldText()
        makeProfileImage()
        makeProfileName()
        makeSelfInfo()
        makeSelfInfoDetail()
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
        updateTextFieldText()
        profileName.resignFirstResponder()
        selfInfoDetail.resignFirstResponder()
    }
        
    func setLayout() {
        view.addSubview(profileImage)
        view.addSubview(profileName)
        view.addSubview(selfInfo)
        view.addSubview(selfInfoDetail)
        view.addSubview(writeMe)
        view.addSubview(writeMeTableView)
        view.addSubview(logout)
        view.addSubview(deleteID)
        view.addSubview(selfInfoInt)
        view.addSubview(line)
        view.addSubview(choiceEnjoyTextField)
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        profileName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(45)
        }
        choiceEnjoyTextField.snp.makeConstraints { make in
            make.top.equalTo(profileName.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(130)
            make.height.equalTo(35)
        }
        selfInfo.snp.makeConstraints { make in
            make.top.equalTo(choiceEnjoyTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        selfInfoDetail.snp.makeConstraints { make in
            make.top.equalTo(selfInfo.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(130)
        }
        selfInfoInt.snp.makeConstraints { make in
            make.top.equalTo(selfInfoDetail.snp.bottom).offset(5)
            make.trailing.equalTo(selfInfoDetail).offset(-5)
        }
        writeMe.snp.makeConstraints { make in
            make.top.equalTo(selfInfoInt.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        writeMeTableView.snp.makeConstraints { make in
            make.top.equalTo(writeMe.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(160)
        }
        logout.snp.makeConstraints { make in
            make.top.equalTo(writeMeTableView.snp.bottom).offset(15)
            make.leading.equalTo(writeMeTableView).offset(100)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        line.snp.makeConstraints { make in
            make.centerY.equalTo(logout)
            make.leading.equalTo(logout.snp.trailing).offset(5)
            make.width.equalTo(2)
            make.height.equalTo(18)
        }
        deleteID.snp.makeConstraints { make in
            make.centerY.equalTo(line)
            make.leading.equalTo(line.snp.trailing).offset(5)
            make.width.equalTo(70)
            make.height.equalTo(30)
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

// 네이게이션 바
private extension MyProfileViewController {
    func profileEditControllerSet() {
        // 네비게이션 LargeTitle 비활성화 및 title 입력
        navigationController?.navigationBar.prefersLargeTitles = false
    }
        
    func navigationBarButtonAction() {
        // 네비게이션 오른쪽 버튼 생성
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editVC))
        navigationItem.rightBarButtonItem = editButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
            
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = UIColor(color: .main)
        navigationItem.backBarButtonItem = backBarButtonItem
    }

    @objc func editVC() {
        // 기본 isEdit은 false. toggle(전등스위치개념) 사용하여 true(수정중인 상태)로 바꿔줌
        isEdit.toggle()
                
        // isEdit = true인 상태의 실행 코드
        if isEdit {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "checkmark.circle")
                    
            // 각각 텍스트뷰를 활성화 시킴
            profileName.isUserInteractionEnabled = true
            selfInfoDetail.isUserInteractionEnabled = true
            choiceEnjoyTextField.isUserInteractionEnabled = true
            writeMe.isHidden = true // "작성한글" title Label 숨기기
            writeMeTableView.isHidden = true // 작성한글 리스트 숨기기
            logout.isHidden = true
            line.isHidden = true
            deleteID.isHidden = true
            choiceEnjoyTextField.tintColor = .clear

            // isEdit = false인 상태의 실행 코드
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "square.and.pencil")
            profileName.isUserInteractionEnabled = false
            selfInfoDetail.isUserInteractionEnabled = false
            choiceEnjoyTextField.isUserInteractionEnabled = false

            writeMe.isHidden = false // 작성한글 title Label 나타내기
            writeMeTableView.isHidden = false // 작성한글 리스트 나타내기
            logout.isHidden = false
            line.isHidden = false
            deleteID.isHidden = false
            choiceEnjoyTextField.tintColor = .clear
        }
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
                
            let userDatabaseManager = FBDatabaseManager<IDoUser>(refPath: ["Users"])
            guard let user = MyProfile.shared.myUserInfo?.toIDoUser else { return }
                
            userDatabaseManager.deleteData(data: user) { [weak self] success in
                if success {
                    if let user = Auth.auth().currentUser {
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
                    } else {
                        print("로그인 정보가 존재하지 않습니다")
                    }
                }
            }
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
        MyProfile.shared.update(hobbyList: [selectedHobby])
    }
}

extension MyProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == choiceEnjoyTextField {}
        return true
    }
}
