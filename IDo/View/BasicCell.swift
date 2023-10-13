//
//  BasicCell.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import UIKit

class BasicCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .regular)
        return label
    }()

    let aboutLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        return label
    }()

    let basicImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(aboutLabel)
        contentView.addSubview(basicImageView)
        basicImageView.snp.makeConstraints { make in

            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(basicImageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).offset(-10)
        }

        aboutLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualTo(contentView).offset(-10)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) 구현되지 않았습니다.")
    }
}
