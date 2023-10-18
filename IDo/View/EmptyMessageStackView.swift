//
//  EmptyMessageStackView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit

final class EmptyMessageStackView: UIStackView {
    
    enum MessageType {
        case networkError
        case commentEmpty
        case clubEmpty
        case noticeBoardEmpty
        case custom(image: UIImage?, title: String?, description: String?)
    }

    let basicImageView: BasicImageView = BasicImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headFont(.xSmall, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        label.textAlignment = .center
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .text2)
        label.textAlignment = .center
        return label
    }()
    var type: MessageType = .custom(image: nil, title: nil, description: nil) {
        didSet {
            updateAtType()
        }
    }
    
    var imageSize: CGFloat {
        didSet {
            imageSizeUpdate()
        }
    }
    
    init(_ imageSize: CGFloat = 60) {
        self.imageSize = imageSize
        super.init(frame: .zero)
        axis = .vertical
        alignment = .center
        distribution = .fillProportionally
        spacing = 12
        setup()
    }
    
    convenience init(imageSize: CGFloat = 60, messageType: MessageType) {
        self.init(imageSize)
        self.type = messageType
        updateAtType()
    }
    
    convenience init(imageSize: CGFloat = 60, image: UIImage?) {
        self.init(imageSize)
        basicImageView.imageView.image = image
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EmptyMessageStackView {
    func setImage(image: UIImage?) {
        basicImageView.imageView.image = image
    }
    func setColor(color: UIColor) {
        basicImageView.tintColor = color
    }
}

private extension EmptyMessageStackView {
    func setup() {
        addViews()
        autoLayoutSetup()
        imageViewSetup()
    }
    func addViews() {
        addArrangedSubview(basicImageView)
        addArrangedSubview(titleLabel)
        addArrangedSubview(descriptionLabel)
    }
    func autoLayoutSetup() {
        basicImageView.snp.makeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
    }
    func imageViewSetup() {
        basicImageView.backgroundColor = UIColor(color: .contentPrimary)
        basicImageView.layer.cornerRadius = imageSize / 2
    }
    func imageSizeUpdate() {
        basicImageView.layer.cornerRadius = imageSize / 2
        basicImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
    }
}

private extension EmptyMessageStackView {
    func updateAtType() {
        switch type {
        case .networkError:
            basicImageView.imageView.image = UIImage(systemName: "wifi.exclamationmark")
            setColor(color: UIColor(color: .negative))
            titleLabel.text = "인터넷 연결이 불안정 합니다"
            descriptionLabel.text = "인터넷을 연결하고 다시시도해주세요"
        case .noticeBoardEmpty:
            setImage(image: UIImage(systemName: "list.bullet.clipboard.fill"))
            titleLabel.text = "게시판이 존재하지 않습니다."
            descriptionLabel.text = "게시글 작성을 통해 사람들과 내용을 공유하세요"
        case .commentEmpty:
            setImage(image: UIImage(systemName: "bubble.right.fill"))
            titleLabel.text = "댓글이 없습니다."
            descriptionLabel.text = "댓글을 작성해주세요"
        case .clubEmpty:
            setImage(image: UIImage(systemName: "person.2.fill"))
            titleLabel.text = "선택한 카테고리의 모임이 없습니다"
            descriptionLabel.text = """
                                    취미가 맞는 모임에 참여하시고
                                    서로의 취향을 공유해 보세요
                                   """
        case .custom(let image, let title, let description):
            setImage(image: image)
            titleLabel.text = title
            descriptionLabel.text = description
        }
    }
}
