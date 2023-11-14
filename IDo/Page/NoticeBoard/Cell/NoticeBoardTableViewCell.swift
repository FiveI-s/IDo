//
//  NoticeBoardTableViewCell.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class NoticeBoardTableViewCell: UITableViewCell {
    
    static let identifier = "NoticeBoardTableViewCell"
    
    var indexPath: IndexPath?
    
    var onImageTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let indexPath {
            FBURLCache.shared.cancelDownloadURL(indexPath: indexPath)
        }
        profileImageView.imageView.image = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addContentView()
        addStackView()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 게시글 head
    // 작성자 프로필 사진 / 작성자 이름 / 작성 시간
    private(set) lazy var headStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // 작성자 프로필 사진
    private(set) lazy var profileImageView: BasicImageView = {
        let imageView = BasicImageView(image: UIImage(systemName: "person.fill"))
        imageView.backgroundColor = UIColor(color: .contentBackground)
        imageView.contentMargin = 4
        imageView.tintColor = UIColor.white
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    // 작성자 이름
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "홍준영"
        label.font = UIFont.bodyFont(.small, weight: .medium)
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    
    // 작성 시간
    private(set) lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "10월 11일 오후 3:43"
        label.font = UIFont.bodyFont(.xSmall, weight: .regular)
        label.textAlignment = .right
        label.textColor = UIColor(color: .text2)
        return label
    }()
    
    // MARK: - 게시글 body
    // 게시글 제목 / 게시글 내용
    private(set) lazy var bodyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    // 게시글 제목
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "같이 합주 할 사람!!!"
        label.font = UIFont.bodyFont(.medium, weight: .bold)
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    
    // 게시글 내용
    private(set) lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = "이번주 토요일날 같이 장안구에서 합주 할 사람 모여라!!!이번주 토요일날 같이 장안구에서 합주 할 사람 모여라!!!이번주 토요일날 같이 장안구에서 합주 할 사람 모여라!!!"
        label.font = UIFont.bodyFont(.small, weight: .regular)
        label.textColor = UIColor(color: .textStrong)
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - 게시글 foot
    // 게시글 제목 / 게시글 내용
    private(set) lazy var footStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    // 댓글 이미지
    private(set) lazy var commentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "message")
        imageView.tintColor = UIColor(color: .main)
        return imageView
    }()
    
    // 댓글 개수
    private(set) lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.font = UIFont.bodyFont(.xSmall, weight: .medium)
        label.textColor = UIColor(color: .main)
        return label
    }()
}

private extension NoticeBoardTableViewCell {
    
    private func addContentView() {
        contentView.addSubview(headStackView)
        contentView.addSubview(bodyStackView)
        contentView.addSubview(footStackView)
    }
    
    private func addStackView() {
        headStackView.addArrangedSubview(profileImageView)
        headStackView.addArrangedSubview(nameLabel)
        headStackView.addArrangedSubview(timeLabel)
        
        bodyStackView.addArrangedSubview(titleLabel)
        bodyStackView.addArrangedSubview(contentLabel)
        
        footStackView.addArrangedSubview(commentImageView)
        footStackView.addArrangedSubview(commentLabel)
    }
    
    private func autoLayout() {
        
        headStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(Constant.margin2)
            make.leading.equalTo(contentView.snp.leading).offset(Constant.margin4)
            make.trailing.equalTo(contentView.snp.trailing).offset(-Constant.margin4)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
        bodyStackView.snp.makeConstraints { make in
            make.top.equalTo(headStackView.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(contentView.snp.leading).offset(Constant.margin4)
            make.trailing.equalTo(contentView.snp.trailing).offset(-Constant.margin4)
        }
        
        footStackView.snp.makeConstraints { make in
            make.top.equalTo(bodyStackView.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(contentView.snp.leading).offset(Constant.margin4)
            make.trailing.equalTo(contentView.snp.trailing).offset(-Constant.margin4)
            make.bottom.equalTo(contentView.snp.bottom).offset(-Constant.margin2)
        }
        
        commentImageView.snp.makeConstraints { make in
            make.width.height.equalTo(15)
        }
    }
}
extension NoticeBoardTableViewCell {
    
    func setUserImage(profileImage: UIImage, color: UIColor, margin: CGFloat = 4) {
        DispatchQueue.main.async {
            self.profileImageView.imageView.image = profileImage
            self.profileImageView.imageView.backgroundColor = color
            self.profileImageView.contentMargin = margin
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.imageView.isUserInteractionEnabled = true
        profileImageView.imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func profileImageTapped() {
        onImageTap?()
    }
}
