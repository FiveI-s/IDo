import UIKit

class MeetingManageViewController: UIViewController {
    
    let profileImageButton: MeetingProfileImageButton = {
        let button = MeetingProfileImageButton()
        button.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        return button
    }()
    
    let imageSetLabel: UILabel = {
        let label = UILabel()
        label.text = "대표 사진"
        label.font = UIFont(name: "SF Pro", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    let meetingNameField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(named: "BackgroundSecondary")
        textField.placeholder = "모임 이름을 설정하세요."
        return textField
    }()
    
    
    
    let meetingDescriptionField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.backgroundColor = UIColor(named: "BackgroundSecondary")
        textView.textAlignment = .left
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.2
        textView.clipsToBounds = true
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 12)
        return textView
    }()

    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "모임에 대한 소개를 해주세요."
        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.placeholderText
        return label
    }()
    
    private let manageFinishButton = FinishButton(title: "수정 완료")

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        // UI 설정
        view.addSubview(profileImageButton)
        view.addSubview(imageSetLabel)
        view.addSubview(meetingNameField)
        view.addSubview(manageFinishButton)
        view.addSubview(meetingDescriptionField)
        view.addSubview(placeholderLabel)
        
        profileImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
        }
        
        imageSetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        meetingNameField.snp.makeConstraints { (make) in
            make.top.equalTo(imageSetLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(361)
            make.height.equalTo(37)
        }
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: meetingNameField.frame.height))
        meetingNameField.leftView = leftPaddingView
        meetingNameField.leftViewMode = .always

        meetingDescriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingNameField.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(361)
            make.height.equalTo(250)
        }
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionField).offset(12)
            make.left.equalTo(meetingDescriptionField).offset(12.8) // textview, textfield 간의 placeholder margin 차이로 인해 미세한 위치조정
        }
        meetingDescriptionField.delegate = self

        manageFinishButton.snp.makeConstraints { (make) in
                make.top.equalTo(meetingDescriptionField.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.width.equalTo(140)
                make.height.equalTo(44)
            }
        
    }
    
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
}

extension MeetingManageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let circularImage = selectedImage.circularImage(size: profileImageButton.bounds.size)
            profileImageButton.setImage(circularImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension MeetingManageViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}


