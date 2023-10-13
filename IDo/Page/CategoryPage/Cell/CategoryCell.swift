//
//  CategoryCell.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import SnapKit
import UIKit

class CategoryCell: UITableViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.font = .headFont(.xSmall, weight: .regular)
        return label
    }()

    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        contentView.addSubview(categoryImageView)
        label.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.leading.equalTo(categoryImageView.snp.trailing).offset(10)
        }

        categoryImageView.snp.makeConstraints { make in

            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) 구현되지 않았습니다.")
    }
}
