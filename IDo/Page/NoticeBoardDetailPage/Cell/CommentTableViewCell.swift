//
//  CommentTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit
import SnapKit

class CommentTableViewCell: UITableViewCell, Reusable {
    
    let userInfoStackView: WriterStackView = WriterStackView()
    var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        label.text = "텍스트 입니다"
        label.numberOfLines = 1
        return label
    }()
    var moreButtonTapHandler: () -> Void = {}

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentTableViewCell {
    func setDate(dateText: String) {
        userInfoStackView.writerTimeLabel.text = dateText
    }
}

private extension CommentTableViewCell {
    func setup() {
        addViews()
        autoLayoutSetup()
        writeStackViewSetup()
    }
    func addViews() {
        contentView.addSubview(userInfoStackView)
        contentView.addSubview(contentLabel)
    }
    func autoLayoutSetup() {
        userInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Constant.margin2)
            make.left.right.equalTo(contentView)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoStackView.snp.bottom).offset(Constant.margin2)
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(Constant.margin2)
        }
    }
    func writeStackViewSetup() {
        userInfoStackView.moreButtonTapHandler = { [weak self] in
            guard let self else { return }
            self.moreButtonTapHandler()
        }
    }
}
