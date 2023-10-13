//
//  EmptyCountTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import UIKit

class EmptyCountTableViewCell: UITableViewCell, Reusable {
    
    private let emptyMessageView: EmptyMessageStackView = {
        let view = EmptyMessageStackView(imageSize: 60, image: UIImage(systemName: "bubble.right.fill"))
        view.titleLabel.text = "댓글이 없습니다."
        view.descriptionLabel.text = "댓글을 작성해주세요"
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessage(image: UIImage?, imageSize: CGFloat = 60, title: String?, description: String?) {
        emptyMessageView.setImage(image: image)
        emptyMessageView.imageSize = imageSize
        emptyMessageView.titleLabel.text = title
        emptyMessageView.descriptionLabel.text = description
    }
    
}

private extension EmptyCountTableViewCell {
    func setup() {
        addViews()
        autoLayoutSetup()
    }
    func addViews() {
        contentView.addSubview(emptyMessageView)
    }
    func autoLayoutSetup() {
        emptyMessageView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
    }
}
