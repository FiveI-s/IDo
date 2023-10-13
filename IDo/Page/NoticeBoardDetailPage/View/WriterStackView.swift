//
//  UserInfoStackView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit

final class WriterStackView: UIStackView {
    
    private let writerImageView: BasicImageView = {
        let imageView = BasicImageView(image: UIImage(systemName: "person.fill"))
        imageView.backgroundColor = UIColor(color: .contentPrimary)
        imageView.contentMargin = 4
        return imageView
    }()
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    private let writerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        label.numberOfLines = 1
        label.text = "사용자 이름"
        return label
    }()
    private let writerTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        label.textColor = UIColor(color: .text1)
        label.numberOfLines = 1
        let date = Date().addingTimeInterval(-200)
        label.text = date.diffrenceDate
        return label
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        writerImageView.layer.cornerRadius = writerImageView.bounds.width / 2
    }
}

private extension WriterStackView {
    func setup() {
        stackViewSetup()
        addViews()
        autoLayoutSetup()
    }
    
    func stackViewSetup() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 4
    }
    
    func addViews() {
        addArrangedSubview(writerImageView)
        addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(writerNameLabel)
        verticalStackView.addArrangedSubview(writerTimeLabel)
    }
    
    func autoLayoutSetup() {
        writerImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
    }
}
