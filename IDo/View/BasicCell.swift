//
//  BasicCell.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import SnapKit
import UIKit

class BasicCell: UITableViewCell {
    let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .bold)
        label.textColor = .black
        label.contentMode = .top
        return label
    }()

    let aboutLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    let memberLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        label.textColor = UIColor(color: .text2)
        label.contentMode = .bottom
        return label
    }()

    let basicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(color: .contentBackground)
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var indexPath: IndexPath?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(basicImageView)
        contentView.addSubview(labelStackView)

        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(aboutLabel)
        labelStackView.addArrangedSubview(memberLabel)

        basicImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.margin2)
            make.bottom.equalToSuperview().offset(-Constant.margin2).priority(.high)
            make.leading.equalToSuperview().offset(Constant.margin4)
            make.width.height.equalTo(62)
        }

        labelStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constant.margin2)
            make.leading.equalTo(basicImageView.snp.trailing).offset(Constant.margin3)
            make.trailing.equalToSuperview().offset(-Constant.margin4)
            make.bottom.equalToSuperview().offset(-Constant.margin2)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) 구현되지 않았습니다.")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let indexPath {
            FBURLCache.shared.cancelDownloadURL(indexPath: indexPath)
        }
        self.basicImageView.image = nil
    }
}

extension BasicCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
