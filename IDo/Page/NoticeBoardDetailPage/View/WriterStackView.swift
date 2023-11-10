//
//  UserInfoStackView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit

final class WriterStackView: UIStackView {
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    let writerImageView: BasicImageView = {
        let imageView = BasicImageView(image: UIImage(systemName: "person.fill"))
        imageView.backgroundColor = UIColor(color: .contentBackground)
        imageView.contentMargin = 4
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let moreImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "ellipsis"))
//        imageView.tintColor = UIColor(color: .backgroundTertiary)
        imageView.tintColor = UIColor(color: .placeholder)
        return imageView
    }()
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    let writerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .medium)
        label.textColor = UIColor(color: .textStrong)
        label.numberOfLines = 1
        label.text = "사용자 이름"
        return label
    }()
    let writerTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        label.textColor = UIColor(color: .text2)
        label.numberOfLines = 1
        let date = Date().addingTimeInterval(-200)
        label.text = date.diffrenceDate
        return label
    }()
    var moreButtonTapHandler: () -> Void = {}
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        writerImageView.layer.cornerRadius = writerImageView.bounds.height / 2
    }
}

private extension WriterStackView {
    func setup() {
        stackViewSetup()
        addViews()
        autoLayoutSetup()
        imageViewSetup()
    }
    
    func stackViewSetup() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 8
    }
    
    func addViews() {
        addArrangedSubview(writerImageView)
        addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(writerNameLabel)
        horizontalStackView.addArrangedSubview(moreImageView)
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(writerTimeLabel)
    }
    
    func autoLayoutSetup() {
        writerImageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
    }
    
    func imageViewSetup() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(moreButtonTap))
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(gesture)
        moreImageView.contentMode = .center
        moreImageView.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(18.5)
        }
    }
    
    @objc func moreButtonTap() {
        moreButtonTapHandler()
    }
}
