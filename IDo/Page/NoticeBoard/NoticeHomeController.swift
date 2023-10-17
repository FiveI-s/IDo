//
//  NoticeHomeController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import UIKit
import FirebaseDatabase

class NoticeHomeController: UIViewController {
    
    var meetingId: String?
    var categoryData: String?
    var meetingIndex: Int?
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "MeetingProfileImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var label: UILabel = {
        var label = UILabel()
        label.font = .headFont(.xSmall, weight: .bold)
        label.text = "[B.R.P] 보라매 런앤플레이"
        return label
    }()

    lazy var textView: UITextView = {
        var textView = UITextView()
        textView.font = .bodyFont(.medium, weight: .regular)
        textView.text = "안녕하세요. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다.설명입니다. 설명입니다. 설명입니다.설명입니다.설명입니다.설명입니다.설명입니다. 설명입니다."
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadDataFromFirebase()
    }

    func setup() {
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(textView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.5)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(100)
        }
    }
    
    func loadDataFromFirebase() {
        guard let category = categoryData else { return }
        
        let ref = Database.database().reference().child(category).child("meetings")
        
        ref.observe(.value) { [weak self] (snapshot) in
            var index = 0
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let meetingData = childSnapshot.value as? [String: Any],
                   let title = meetingData["title"] as? String,
                   let description = meetingData["description"] as? String {
                    
                    if index == self?.meetingIndex {
                        DispatchQueue.main.async {
                            self?.label.text = title
                            self?.textView.text = description
                        }
                        break
                    }
                    index += 1
                }
            }
        }
    }


    
}
