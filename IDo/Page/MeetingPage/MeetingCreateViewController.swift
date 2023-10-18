import UIKit
import FirebaseDatabase
import FirebaseStorage

class MeetingCreateViewController: UIViewController {
    
    var selectedCategory: String?
    
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
    
    let countMeetingNameField: UILabel = {
        let label = UILabel()
        label.text = "0/16"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
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
    
    let countDescriptionField: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.text = "0/300"
        return label
    }()
    
    func shakeAnimation(for view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-2, 2, -2, 2, -2, 2] // 애니메이션 값 조정
        view.layer.add(animation, forKey: "shake")
    }
    
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "모임에 대한 소개를 해주세요."
        label.font = UIFont(name: "SF Pro", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.placeholderText
        return label
    }()
    
    private let createFinishButton = FinishButton()


    @objc private func createMeeting() {
        guard let title = meetingNameField.text, !title.isEmpty,
              let description = meetingDescriptionField.text, !description.isEmpty else {
            print("모임의 이름과 설명은 필수 입력 항목입니다.")
            return
        }
        
        var imageData: Data? = nil
            if let image = profileImageButton.image(for: .normal) {
                imageData = image.jpegData(compressionQuality: 0.8) // 이미지 품질
            }

            saveMeetingToFirebase(name: title, description: description, imageData: imageData)
        }


    private func saveMeetingToFirebase(name: String, description: String, imageData: Data?) {
        guard let category = selectedCategory else { return }
        //
        let ref = Database.database().reference().child(category).child("meetings")
        let newMeetingID = ref.childByAutoId().key ?? ""
        
        if let imageData = imageData {
            // 이미지 업로드
            let storageRef = Storage.storage().reference().child("\(selectedCategory ?? "default_category")").child("meeting_images").child("\(newMeetingID).png")

            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Failed to upload image to Firebase Storage:", error)
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let imageUrl = url?.absoluteString else { return }
                    
                    // 데이터에 해당 키로 저장
                    let data: [String: Any] = [
                        "id": newMeetingID,
                        "title": name,
                        "description": description,
                        "imageUrl": imageUrl
                    ]
                    
                    ref.child(newMeetingID).setValue(data) { [weak self] (error, _) in
                        if let error = error {
                            print("Data could not be saved: \(error).")
                        } else {
                            print("Data saved successfully!")
                            let alert = UIAlertController(title: "완료", message: "모임을 개설했습니다!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                                self?.navigationController?.popViewController(animated: true)
                            }))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }



 

    private func setupCreateButton() {
        createFinishButton.addTarget(self, action: #selector(createMeeting), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCreateButton()
        updateFinishButtonState()
        view.addSubview(meetingDescriptionField)
        view.addSubview(placeholderLabel)
        configureUI()
    }
    
    private func configureUI() {
        // UI 설정
        view.addSubview(profileImageButton)
        view.addSubview(imageSetLabel)
        view.addSubview(meetingNameField)
        meetingNameField.delegate = self
        view.addSubview(countMeetingNameField)
        view.addSubview(createFinishButton)
        view.addSubview(countDescriptionField)
        
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
        
        countMeetingNameField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingNameField.snp.bottom).offset(4)
            make.right.equalTo(meetingNameField.snp.right)
        }
        
        meetingDescriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingNameField.snp.bottom).offset(22)
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
        
        
        countDescriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(meetingDescriptionField.snp.bottom).offset(4)
            make.right.equalTo(meetingDescriptionField.snp.right)
        }
        
    }
    
    @objc private func profileImageTapped() {
        profileImageButton.openImagePicker(in: self)
    }
    
    func updateFinishButtonState() {
            // meetingNameField와 meetingDescriptionField가 모두 내용이 있을때만 활성화
            let istitleFieldEmpty = meetingNameField.text?.isEmpty ?? true
            let isDescriptionEmpty = meetingDescriptionField.text.isEmpty
            createFinishButton.isEnabled = !(istitleFieldEmpty || isDescriptionEmpty)
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
        countDescriptionField.text = "\(textView.text.count)/300"
        updateFinishButtonState()
        
        if textView.text.count > 300 {
            shakeAnimation(for: countDescriptionField)
            countDescriptionField.textColor = .red
        } else {
            countDescriptionField.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if prospectiveText.count > 301 {
            return false
        }
        return true
    }
}


extension MeetingCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == meetingNameField else {
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
                updateFinishButtonState()
            }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        countMeetingNameField.text = "\(prospectiveText.count)/16"
        
        if prospectiveText.count > 16 {
            shakeAnimation(for: countMeetingNameField)
            countMeetingNameField.textColor = .red
            return false
        } else {
            countMeetingNameField.textColor = .black
        }
        
        return true
        
    }
}




