import FirebaseDatabase
import FirebaseStorage
import UIKit
import TOCropViewController


class MeetingManageViewController: UIViewController {
    var meetingTitle: String?
    var meetingImageURL: String?
    var ref: DatabaseReference?
    let storage = Storage.storage()
    lazy var storageRef = storage.reference()
    private var meetingsData: MeetingsData
    private var club: Club
    private var clubImage: UIImage?
    var updateHandler: ((Club, Data) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureUI()
        setupScrollView()
        meetingNameTextView.text = club.title
        meetingNameTextView.textColor = UIColor.black
        countMeetingNameLabel.text = "(\(meetingNameTextView.text.count)/20)"
        countMeetingNameLabel.textColor = UIColor.black
        
        meetingDescriptionTextView.text = club.description
        meetingDescriptionTextView.textColor = UIColor.black
        countDescriptionLabel.text = "(\(meetingDescriptionTextView.text.count)/300)"
        countDescriptionLabel.textColor = UIColor.black
        
        if let clubImage {
            profileImageButton.setImage(clubImage, for: .normal)
        } else {
            if let imagePath = club.imageURL {
                FBURLCache.shared.downloadURL(storagePath: imagePath) { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.profileImageButton.setImage(image, for: .normal)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        ref = Database.database().reference()
        manageFinishButton.addTarget(self, action: #selector(manageFinishButtonTapped), for: .touchUpInside)
        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "모임 수정하기")
        }
//        placeholderLabel.isHidden = !meetingDescriptionField.text.isEmpty
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
    
    init(club: Club, clubImage: UIImage?) {
        self.club = club
        self.clubImage = clubImage
        self.meetingsData = MeetingsData(category: club.category)
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
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    var profileImageButton: MeetingProfileImageButton = {
        let button = MeetingProfileImageButton()
        button.addTarget(MeetingManageViewController.self, action: #selector(profileImageTapped), for: .touchUpInside)
        return button
    }()
    
//    let meetingNameField: UITextField = {
//        let textField = UITextField()
//        textField.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
//        textField.borderStyle = .roundedRect
//        textField.backgroundColor = UIColor(named: "BackgroundSecondary")
//        textField.placeholder = "모임 이름을 설정하세요."
//        return textField
//    }()
    
    // 이름을 작성하는 textView
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
    
//    let placeholderLabel: UILabel = {
//        let label = UILabel()
//        label.text = "모임에 대한 소개를 해주세요."
//        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
//        label.textColor = UIColor.placeholderText
//        return label
//    }()
    
    // 수정 버튼
    private let manageFinishButton = FinishButton(title: "수정 완료")
    
    // MARK: - 키보드 관련

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
    
    // MARK: - UI 및 오토레이아웃 설정

    private func configureUI() {
        // UI 설정
        view.backgroundColor = UIColor(color: .backgroundPrimary)
        view.addSubview(scrollView)
        meetingNameTextView.delegate = self
        meetingDescriptionTextView.delegate = self
        scrollView.addSubview(profileImageButton)
        scrollView.addSubview(meetingNameTextView)
        scrollView.addSubview(countMeetingNameLabel)
        scrollView.addSubview(meetingDescriptionTextView)
        scrollView.addSubview(countDescriptionLabel)
        scrollView.addSubview(manageFinishButton)

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
            make.top.equalTo(scrollView).offset(Constant.margin3)
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
        
        manageFinishButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(countDescriptionLabel.snp.bottom).offset(Constant.margin4)
            make.centerX.equalTo(scrollView)
            make.left.right.equalTo(scrollView).inset(Constant.margin4)
            make.height.equalTo(48)
            make.bottom.equalTo(scrollView).inset(Constant.margin3)
        }
    }
    
    private func setupScrollView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollTap))
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func scrollTap() {
        view.endEditing(true)
    }
    
    // MARK: - 버튼 클릭 관련

    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
    
    @objc func manageFinishButtonTapped() {
        manageFinishButton.isEnabled = false

        guard let name = meetingNameTextView.text, !name.isEmpty,
              let description = meetingDescriptionTextView.text, let meetingImage = profileImageButton.imageView?.image
        else {
            manageFinishButton.isEnabled = true

            return
        }
        
        guard let imageData = meetingImage.jpegData(compressionQuality: 0.5) else {
            manageFinishButton.isEnabled = true

            return
        }
        
//        saveMeetingToFirebase(name: name, description: description, imageData: imageData)
        saveResizeImageMeetingToFirebase(name: name, description: description, clubImage: meetingImage, imageData: imageData)
    }
    
    private func saveResizeImageMeetingToFirebase(name: String, description: String, clubImage: UIImage, imageData: Data) {
        club.title = name
        club.description = description
        meetingsData.updateClubResize(club: club, clubImage: clubImage) { isSuccess in
            if isSuccess {
                print("데이터 수정 성공")
                
                let alert = UIAlertController(title: "완료", message: "모임 정보가 수정되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                var clubList = MyProfile.shared.myUserInfo?.myClubList ?? []
                if let clubIndex = MyProfile.shared.myUserInfo?.myClubList?.firstIndex(where: {$0.id == self.club.id}) {
                    clubList[clubIndex] = self.club
                    MyProfile.shared.update(myClubList: clubList)
                }
                
                self.updateHandler?(self.club, imageData)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.manageFinishButton.isEnabled = true

                print("데아터 수정 실패")
            }
        }
    }
    
//    private func saveMeetingToFirebase(name: String, description: String, imageData: Data) {
//        club.title = name
//        club.description = description
//        meetingsData.updateClub(club: club, imagaData: imageData) { isSuccess in
//            if isSuccess {
//                print("데이터 수정 성공")
//
//                let alert = UIAlertController(title: "완료", message: "모임 정보가 수정되었습니다.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
//                    self.navigationController?.popViewController(animated: true)
//                }))
//                var clubList = MyProfile.shared.myUserInfo?.myClubList ?? []
//                if let clubIndex = MyProfile.shared.myUserInfo?.myClubList?.firstIndex(where: {$0.id == self.club.id}) {
//                    clubList[clubIndex] = self.club
//                    MyProfile.shared.update(myClubList: clubList)
//                }
//
//                self.updateHandler?(self.club, imageData)
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                self.manageFinishButton.isEnabled = true
//
//                print("데아터 수정 실패")
//            }
//        }
//    }
}

// MARK: - 이미지 편집 관련

extension MeetingManageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension MeetingManageViewController: TOCropViewControllerDelegate {
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

// MARK: - TextView 관련

extension MeetingManageViewController: UITextViewDelegate {
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
            manageFinishButton.isEnabled = true
        } else {
            manageFinishButton.isEnabled = false
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
//        placeholderLabel.isHidden = !textView.text.isEmpty
//        countDescriptionField.text = "\(textView.text.count)/300"
//
//        if textView.text.count > 300 {
//            shakeAnimation(for: countDescriptionField)
//            countDescriptionField.textColor = .red
//        } else {
//            countDescriptionField.textColor = .black
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
