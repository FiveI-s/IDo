import UIKit

class MeetingCreateViewController: UIViewController {
    
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
        textView.layer.borderColor = UIColor.lightGray.cgColor// .
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
    
    private let createFinishButton = FinishButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(meetingDescriptionField)
        view.addSubview(placeholderLabel)
        configureUI()
    }
    
    private func configureUI() {
        // UI 설정
        view.addSubview(profileImageButton)
        view.addSubview(imageSetLabel)
        view.addSubview(meetingNameField)
        view.addSubview(createFinishButton)
        
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

        createFinishButton.snp.makeConstraints { (make) in
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

extension MeetingCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let circularImage = selectedImage.circularImage(size: profileImageButton.bounds.size)
            profileImageButton.setImage(circularImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension MeetingCreateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}




// 네비게이션
//    navigationController?.navigationBar.barTintColor = .white
//    navigationItem.title = "미팅 생성"
//    let cancelButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(cancelButtonTapped))
//    navigationItem.leftBarButtonItem = cancelButton
//}
//
//
//
//@objc func cancelButtonTapped() {
//    // 취소 버튼이 눌렸을 때의 액션
//    self.dismiss(animated: true, completion: nil)
//}

