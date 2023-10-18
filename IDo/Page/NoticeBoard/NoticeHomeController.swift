//
//  NoticeHomeController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import SnapKit
import UIKit
import FirebaseDatabase

class NoticeHomeController: UIViewController {
    
    var meetingId: String?
    var categoryData: String?
    var meetingIndex: Int?
//    var meetingImageUrls: [String] = []
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "MeetingProfileImage")
        return imageView
    }()
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.font = .headFont(.xSmall, weight: .bold)
        label.text = "[B.R.P] 보라매 런앤플레이"
        return label
    }()
    
    lazy var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = .bodyFont(.medium, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.text = "안녕하세요. 설명입니다. "
        textLabel.text = "안녕하세요. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다.설명입니다. "
        return textLabel
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = true
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 25
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadDataFromFirebase()
    }
    
    func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        
        scrollStackViewContainer.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(50)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.layoutMarginsGuide.snp.top)
            make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
        }
        
        configureContainerView()
    }
    
    private func configureContainerView() {
        scrollStackViewContainer.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(150)
        }
        scrollStackViewContainer.addArrangedSubview(label)
        scrollStackViewContainer.addArrangedSubview(textLabel)
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
                   let description = meetingData["description"] as? String,
                   let imageUrlString = meetingData["imageUrl"] as? String,
                   let imageUrl = URL(string: imageUrlString) {
                    
                    if index == self?.meetingIndex {
                        DispatchQueue.main.async {
                            self?.label.text = title
                            self?.textLabel.text = description
                            
                            // 이미지 캐시 확인
                            if let cachedImage = ImageCache.shared.getImage(for: imageUrlString) {
                                self?.imageView.image = cachedImage
                            } else {
                                // 이미지 로드
                                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                    if let error = error {
                                        print("Failed to load image: ", error.localizedDescription)
                                        return
                                    }
                                    
                                    guard let data = data, let image = UIImage(data: data) else { return }
                                    
                                    // 이미지 캐시 저장
                                    ImageCache.shared.cacheImage(image, for: imageUrlString)
                                    
                                    DispatchQueue.main.async {
                                        self?.imageView.image = image
                                    }
                                }.resume()
                            }
                        }
                        break
                    }
                    index += 1
                }
            }
        }
        scrollStackViewContainer.addArrangedSubview(label)
        scrollStackViewContainer.addArrangedSubview(textLabel)
    }


}

