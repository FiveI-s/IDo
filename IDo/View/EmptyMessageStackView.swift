//
//  EmptyMessageStackView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit

final class EmptyMessageStackView: UIStackView {

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
