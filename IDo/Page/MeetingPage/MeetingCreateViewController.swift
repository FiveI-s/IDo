import FirebaseDatabase
import FirebaseStorage
import UIKit
import TOCropViewController
//import CropViewController

class MeetingCreateViewController: UIViewController {
    init(meetingsData: MeetingsData) {
        self.meetingsData = meetingsData
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 컴포넌트 생성

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let meetingsData: MeetingsData
    // contentmode 종류 봐보기
    var originalY: CGFloat?
    lazy var profileImageButton: MeetingProfileImageButton = {
        let button = MeetingProfileImageButton()
        button.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        return button
    }()
    
    let meetingNameTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.font = UIFont.bodyFont(.large, weight: .medium)
        textView.text = "모임 이름을 입력해주세요."
        textView.textColor = UIColor(color: .placeholder)
        textView.layer.cornerRadius = 5
        textView.resignFirstResponder()
        return textView
    }()
    
    // 이름 글자 수 표시 label
    let countMeetingNameLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/20)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()
    
    // 소개글을 작성하는 textView
    let meetingDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.font = UIFont.bodyFont(.medium, weight: .regular)
        textView.text = "모임에 대한 소개를 입력해주세요."
        textView.textColor = UIColor(color: .placeholder)
        textView.layer.cornerRadius = 5.0
        textView.resignFirstResponder()
        return textView
    }()
    
    // 소개글 글자 수 표시 label
    let countDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/300)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .regular)
        return label
    }()
    
    private let createFinishButton = FinishButton()

    @objc private func createMeeting() {
//            guard let name = meetingNameField.text, !name.isEmpty,
//        guard let name = meetingNameTextView.text, !name.isEmpty,
//              let description = meetingDescriptionTextView.text, !description.isEmpty else {
        createFinishButton.isEnabled = false

        if meetingNameTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || meetingNameTextView.textColor == UIColor(color: .placeholder) || meetingDescriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || meetingDescriptionTextView.textColor == UIColor(color: .placeholder) {
            AlertManager.showAlert(on: self, title: "알림", message: "모임의 이름과 설명은 필수 입력 항목입니다.")
            print("모임의 이름과 설명은 필수 입력 항목입니다.")
              
            createFinishButton.isEnabled = true
            return
        }

        if !profileImageButton.profileImageChanged {
            let alert = UIAlertController(title: "알림", message: "대표 사진은 필수입니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
              
            createFinishButton.isEnabled = true
            return
        }
          
        guard let myUserInfo = MyProfile.shared.myUserInfo else {
            print("현재 사용자 정보를 가져오지 못했습니다.")
              
            createFinishButton.isEnabled = true
            return
        }

        let currentUserSummary = myUserInfo.toUserSummary
        var imageData: Data? = nil
        var clubImage: UIImage? = nil
        if let image = profileImageButton.image(for: .normal) {
            imageData = image.jpegData(compressionQuality: 0.5) // 이미지 품질
        }

        let club = Club(id: UUID().uuidString, rootUser: currentUserSummary, title: meetingNameTextView.text, imageURL: nil, description: meetingDescriptionTextView.text, category: meetingsData.category, userList: [currentUserSummary], createDate: Date().dateToString)
          
//        meetingsData.addClub(club: club, imageData: imageData) { isSuccess in
//            if isSuccess {
//                let alert = UIAlertController(title: "완료", message: "모임을 개설했습니다!", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
//                    self.navigationController?.popViewController(animated: true)
//                }))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                let alert = UIAlertController(title: "실패", message: "모임을 개설하지 못했습니다.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
//                    self.navigationController?.popViewController(animated: true)
//                }))
//                self.createFinishButton.isEnabled = true
//            }
//        }
        if let image = profileImageButton.image(for: .normal) {
            clubImage = image
        }
        meetingsData.addClubImageResize(club: club, image: clubImage) { isSuccess in
            if isSuccess {
                let alert = UIAlertController(title: "완료", message: "모임을 개설했습니다!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "실패", message: "모임을 개설하지 못했습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.createFinishButton.isEnabled = true
            }
        }
    }

    private func setupCreateButton() {
        createFinishButton.addTarget(self, action: #selector(createMeeting), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupCreateButton()
        updateFinishButtonState()
        configureUI()
        setupScrollView()

        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "모임 생성하기")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
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
        let adjustmentHeight = keyboardHeight - (tabBarController?.tabBar.frame.size.height ?? 0)
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide).offset(-adjustmentHeight)
        }
        
        DispatchQueue.main.async {
            self.scrollView.layoutIfNeeded()
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom)
            if bottomOffset.y > 0 {
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - UI 설정 및 오토레이아웃

    private func configureUI() {
        // UI 설정
//        meetingNameField.delegate = self
//        containerView.addSubview(meetingNameField)
//        containerView.addSubview(placeholderLabel)
        view.backgroundColor = UIColor(color: .backgroundPrimary)
        view.addSubview(scrollView)
        
        meetingNameTextView.delegate = self
        meetingDescriptionTextView.delegate = self
        
        scrollView.addSubview(profileImageButton)
        scrollView.addSubview(meetingNameTextView)
        scrollView.addSubview(countMeetingNameLabel)
        scrollView.addSubview(createFinishButton)
        scrollView.addSubview(countDescriptionLabel)
        scrollView.addSubview(meetingDescriptionTextView)
        let safeArea = view.safeAreaLayoutGuide
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(safeArea)
        }
        
        let desiredAspectRatio: CGFloat = 2.0 / 3.0
        
        profileImageButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(Constant.margin3)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.equalTo(profileImageButton.snp.width).multipliedBy(desiredAspectRatio)
        }
                
        meetingNameTextView.snp.makeConstraints { make in
            make.top.equalTo(profileImageButton.snp.bottom).offset(Constant.margin3)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.equalTo(40)
        }
        
        countMeetingNameLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingNameTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(meetingNameTextView.snp.right)
        }
                
        meetingDescriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(countMeetingNameLabel.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.lessThanOrEqualTo(160)
            make.height.greaterThanOrEqualTo(100)
        }
        
        countDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingDescriptionTextView.snp.bottom).offset(Constant.margin1)
            make.right.equalTo(meetingDescriptionTextView.snp.right)
        }
        
        createFinishButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(countDescriptionLabel.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.equalTo(48)
            make.bottom.equalTo(scrollView).inset(Constant.margin3)
        }
    }
    
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
    
    func updateFinishButtonState() {
        // meetingNameField와 meetingDescriptionField가 모두 내용이 있을때만 활성화
        let istitleFieldEmpty = meetingNameTextView.text?.isEmpty ?? true
        let isDescriptionEmpty = meetingDescriptionTextView.text.isEmpty
        createFinishButton.isEnabled = !(istitleFieldEmpty || isDescriptionEmpty)
    }

    private func setupScrollView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTap))
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func scrollViewTap() {
        view.endEditing(true)
    }
}

// MARK: - 이미지 편집 관련


extension MeetingCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let cropViewController = TOCropViewController(croppingStyle: .default, image: selectedImage)
                       cropViewController.delegate = self
                       cropViewController.customAspectRatio = CGSize(width: 3, height: 2) // 비율 3:2
                       cropViewController.aspectRatioLockEnabled = true // 비율 선택 잠금
                       cropViewController.resetAspectRatioEnabled = false // 비율 리셋 막음
                       cropViewController.aspectRatioPickerButtonHidden = true // 비율 변경 토글 히든

            picker.dismiss(animated: true) {
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
    }
}

extension MeetingCreateViewController: TOCropViewControllerDelegate {
     func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        // 편집된 이미지 버튼에 할당
        profileImageButton.setImage(image, for: .normal)
        profileImageButton.profileImageChanged = true
        
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil) // 취소했을때
    }
}


//extension MeetingCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
////                let roundedImage = selectedImage.resizedAndRoundedImage()
//            profileImageButton.setImage(selectedImage, for: .normal)
//            profileImageButton.profileImageChanged = true
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//}

// MARK: - 텍스트 뷰 관련

extension MeetingCreateViewController: UITextViewDelegate {
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
        if textView == meetingNameTextView {
            if meetingNameTextView.textColor == UIColor(color: .placeholder) {
                meetingNameTextView.text = nil
                meetingNameTextView.textColor = UIColor.black
            }
        }
        
        // 내용 textView
        if textView == meetingDescriptionTextView {
            if meetingDescriptionTextView.textColor == UIColor(color: .placeholder) {
                meetingDescriptionTextView.text = nil
                meetingDescriptionTextView.textColor = UIColor.black
            }
        }
    }
    
    // 입력 시 호출
    func textViewDidChange(_ textView: UITextView) {
        if textView == meetingNameTextView {
            let textCount = textView.text.count
            countMeetingNameLabel.text = "(\(textCount)/20)"
            
            if textCount == 0 {
                countMeetingNameLabel.textColor = UIColor(color: .placeholder)
            } else {
                countMeetingNameLabel.textColor = UIColor.black
            }
        }
        
        if textView == meetingDescriptionTextView {
            let textCount = textView.text.count
            countDescriptionLabel.text = "(\(textCount)/300)"
            
            if textCount == 0 {
                countDescriptionLabel.textColor = UIColor(color: .placeholder)
            } else {
                countDescriptionLabel.textColor = UIColor.black
            }
        }
        
        if !meetingNameTextView.text.isEmpty, meetingNameTextView.textColor == UIColor.black, meetingDescriptionTextView.textColor == UIColor.black,!meetingDescriptionTextView.text.isEmpty {
            createFinishButton.isEnabled = true
        } else {
            createFinishButton.isEnabled = false
        }
    }
    
    // 입력 종료 시 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        if meetingNameTextView.text.isEmpty {
            meetingNameTextView.text = "모임 이름을 입력해주세요."
            meetingNameTextView.textColor = UIColor(color: .placeholder)
        }
        
        if meetingDescriptionTextView.text.isEmpty {
            meetingDescriptionTextView.text = "모임에 대한 소개를 입력해주세요."
            meetingDescriptionTextView.textColor = UIColor(color: .placeholder)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == meetingNameTextView {
            if changedText.count > 20 {
                countMeetingNameLabel.textColor = UIColor.red
                shakeAnimation(for: countMeetingNameLabel)
                return false
            }
            return true
        }
        
        if textView == meetingDescriptionTextView {
            if changedText.count > 300 {
                countDescriptionLabel.textColor = UIColor.red
                shakeAnimation(for: countDescriptionLabel)
                return false
            }
            return true
        }
        return true
    }
    
//    func textViewDidChange(_ textView: UITextView) {
    ////        placeholderLabel.isHidden = !textView.text.isEmpty
//        countDescriptionTextView.text = "\(textView.text.count)/300"
//        updateFinishButtonState()
//
//        if textView.text.count > 300 {
//            shakeAnimation(for: countDescriptionTextView)
//            countDescriptionTextView.textColor = .red
//        } else {
//            countDescriptionTextView.textColor = .black
//        }
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let currentText = textView.text ?? ""
//        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
//
//        if prospectiveText.count > 301 {
//            return false
//        }
//        return true
//    }
}

extension MeetingCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == meetingNameTextView else {
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            updateFinishButtonState()
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        countMeetingNameLabel.text = "\(prospectiveText.count)/20"
        
        if prospectiveText.count > 20 {
            shakeAnimation(for: countMeetingNameLabel)
            countMeetingNameLabel.textColor = .red
            return false
        } else {
            countMeetingNameLabel.textColor = .black
        }
        
        return true
    }
}

// 키보드 올라왔을 때 화면 터치시 키보드 내리는 로직을 uiviewcontroller 에 대해 익스텐션으로 추가해서
// self.hideKeyboardWhenTappedAround() 만 추가하면 모든 뷰컨트롤러에서 적용

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
