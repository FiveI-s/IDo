//
//  NoticeCell.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import SnapKit
import UIKit

class NoticeCell: UITableViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        return label
    }()

    let commentsLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        return label
    }()

    let dataLable: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        return label
    }()

    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        return imageView
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, commentsLabel, dataLable])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 5

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(categoryImageView)
        contentView.addSubview(stackView)

        categoryImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(categoryImageView)
            make.leading.equalTo(categoryImageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(10)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) 구현되지 않았습니다.")
    }
}
