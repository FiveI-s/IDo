//
//  CircleView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit

class BasicImageView: UIView {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(color: .white)
        return imageView
    }()
    
    var contentMargin: CGFloat = 8 {
        didSet {
            update()
        }
    }

    init(image: UIImage? = nil) {
        imageView.image = image
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BasicImageView {
    func setup() {
        addViews()
        autoLayoutSetup()
    }
    func addViews() {
        addSubview(imageView)
    }
    func autoLayoutSetup() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentMargin)
        }
    }
    func update() {
        imageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(contentMargin)
        }
    }
}
