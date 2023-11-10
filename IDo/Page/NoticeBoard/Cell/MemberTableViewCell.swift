//
//  MemberTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/11/01.
//

import UIKit

final class MemberTableViewCell: UITableViewCell, Reusable {

    let profileImageView: BasicImageView = {
        let imageView = BasicImageView(image: UIImage(systemName: "person.fill"))
        imageView.backgroundColor = UIColor(color: .contentBackground)
        imageView.contentMargin = 4
        imageView.tintColor = UIColor.white
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.small, weight: .medium)
        label.textColor = UIColor(color: .textStrong)
        label.numberOfLines = 1
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.xSmall, weight: .regular)
        label.textColor = UIColor(color: .text2)
        label.numberOfLines = 1
        return label
    }()
    
    var imageSize: CGFloat = 36

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addViews()
        setupAutoLayout()
        setupImageView()
    }
    
    private func addViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupAutoLayout() {
        profileImageView.snp.makeConstraints { make in
            make.left.equalTo(contentView)
            make.width.height.equalTo(imageSize)
            make.verticalEdges.equalTo(contentView).inset(Constant.margin2)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.left.equalTo(profileImageView.snp.right).offset(Constant.margin2)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.left.equalTo(profileImageView.snp.right).offset(Constant.margin2)
        }
    }
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = imageSize/2
        profileImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.imageView.image = nil
    }

}

extension MemberTableViewCell {
    
    func setUserImage(profileImage: UIImage, color: UIColor, margin: CGFloat = 4) {
        DispatchQueue.main.async {
            self.profileImageView.imageView.image = profileImage
            self.profileImageView.imageView.backgroundColor = color
            self.profileImageView.contentMargin = margin
        }
    }
}
