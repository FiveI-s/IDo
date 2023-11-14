//
//  NoticeBoardView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import Foundation
import UIKit

final class NoticeBoardDetailView: UIStackView {
    
    var onImageTap: (() -> Void)?
    
    let writerInfoView: WriterStackView = WriterStackView()
    let contentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.large, weight: .bold)
        label.text = "제목 입니다."
        label.numberOfLines = 0
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    let contentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.text = """
                    텍스트 입니다
                    텍스트 입니다.
                    텍스트 입니다
                    텍스트 입니다.
                    """
        label.numberOfLines = 0
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    var updateEnable: Bool = false {
        didSet {
            writerInfoView.moreImageView.isHidden = !updateEnable
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addTapGestureToProfileImageView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension NoticeBoardDetailView {
    private func setup() {
        stackViewSetup()
        addViews()
    }
    private func stackViewSetup() {
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = 12
    }
    private func addViews() {
        addArrangedSubview(writerInfoView)
        addArrangedSubview(contentTitleLabel)
        addArrangedSubview(contentDescriptionLabel)
        addArrangedSubview(imageStackView)
    }
}

extension NoticeBoardDetailView {
    func loadingNoticeBoardImages(imageCount: Int) {
        let appendImageCount = imageCount - imageStackView.arrangedSubviews.count
        if appendImageCount == 0 {
            return
        } else if appendImageCount > 0 {
            appendNoticeBoardImageView(count: appendImageCount)
        } else {
            let count = abs(appendImageCount)
            removeNoticeBoardImageView(count: count)
        }
    }
    
    private func appendNoticeBoardImageView(count: Int) {
        DispatchQueue.main.async {
            for _ in 0..<count {
                let imageView = self.createLodingImageView()
                DispatchQueue.main.async {
                    self.imageStackView.addArrangedSubview(imageView)
                }
                imageView.snp.makeConstraints { make in
                    make.height.equalTo(imageView.snp.width).multipliedBy(0.9)
                }
            }
        }
    }
    
    private func removeNoticeBoardImageView(count: Int) {
        DispatchQueue.main.async {
            for _ in 0..<count {
                self.imageStackView.arrangedSubviews.last?.removeFromSuperview()
            }
        }
    }
    func addNoticeBoardImages(images: [StorageImage]) {
        for index in 0..<images.count {
            DispatchQueue.main.async {
                guard let imageView = self.imageStackView.arrangedSubviews[index] as? LodingImageView else { return }
                imageView.image = images[index].savedImage
                imageView.viewState = .loaded
            }
        }
    }
    private func createLodingImageView() -> LodingImageView {
        let imageView = LodingImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.viewState = .loading
        imageView.backgroundColor = UIColor(color: .backgroundSecondary)
        return imageView
    }
    func setupUserImage(image: UIImage) {
        writerInfoView.writerImageView.imageView.image = image
        writerInfoView.writerImageView.contentMargin = 0
        writerInfoView.writerImageView.backgroundColor = UIColor(color: .white)
    }
    private func addTapGestureToProfileImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        writerInfoView.writerImageView.isUserInteractionEnabled = true
        writerInfoView.writerImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func profileImageTapped() {
        onImageTap?()
    }
}
