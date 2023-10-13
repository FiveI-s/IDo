//
//  EmptyAbleTableVIew.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import UIKit

class EmptyAbleTableView: UITableView {
    
    enum CellCountState {
        case nomarl
        case empty
    }
    
    let emptyMessageView: EmptyMessageStackView = EmptyMessageStackView()
    
    var state: CellCountState = .nomarl {
        didSet {
            emptyMessageView.isHidden = state == .nomarl
        }
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
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

private extension EmptyAbleTableView {
    private func setup() {
        addSubview(emptyMessageView)
        emptyMessageView.isHidden = true
        emptyMessageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
