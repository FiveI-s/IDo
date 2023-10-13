//
//  HorizentalImageTitleView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit

enum ViewType {
    case rect
    case circle
}

class HorizentalImageTitleView: UIStackView {
    let imageView: BasicImageView = BasicImageView(image: UIImage(systemName: "person"))
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 이름"
        label.textColor = UIColor(color: .textStrong)
        label.font = .bodyFont(.small, weight: .regular)
        return label
    }()
    
    var imageSize: CGFloat = 30 {
        didSet {
            sizeUpdate()
        }
    }
    
    var image: UIImage? = nil {
        didSet {
            imageUpdate()
        }
    }
    
    var imageType: ViewType = .rect
    var imageViewContentMargin: CGFloat = 8 {
        didSet {
            imageView.contentMargin = imageViewContentMargin
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageType == .circle {
            imageView.layer.cornerRadius = imageView.bounds.height / 2
        }
    }
    
}

private extension HorizentalImageTitleView {
    func setup() {
        stackViewSetup()
        addViews()
    }
    func stackViewSetup() {
        axis = .horizontal
        alignment = .center
        distribution = .fillProportionally
    }
    func addViews() {
        addArrangedSubview(imageView)
        addArrangedSubview(titleLabel)
    }
    func sizeUpdate() {
        imageView.snp.remakeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
    }
    func imageUpdate() {
        imageView.imageView.image = self.image
    }
}
