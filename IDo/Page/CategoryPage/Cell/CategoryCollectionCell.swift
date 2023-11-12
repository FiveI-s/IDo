//
//  CategoryColletcionCell.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/23.
//

import Foundation
import SnapKit
import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"

    private(set) lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let label: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupViews() {
        contentView.addSubview(categoryStackView)
        categoryStackView.addArrangedSubview(categoryImageView)
        categoryStackView.addArrangedSubview(label)

        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(8)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.bottom.equalTo(contentView.snp.bottom).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        categoryImageView.snp.makeConstraints { make in
            make.height.width.equalTo(80)
        }

//        label.snp.makeConstraints { make in
//            make.top.equalTo(categoryImageView.snp.bottom).offset(20)
//            make.leading.trailing.equalToSuperview().inset(20)
//            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
//        }
    }
}
