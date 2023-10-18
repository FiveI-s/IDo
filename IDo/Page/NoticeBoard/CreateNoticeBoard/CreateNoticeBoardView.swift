//
//  CreateNoticeBoardView.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class CreateNoticeBoardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 제목을 작성하는 textView
    private(set) lazy var titleTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.font = UIFont.bodyFont(.large, weight: .semibold)
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    // Title Text 글자 수 표시 label
    private(set) lazy var titleCountLabel: UILabel = {
        var label = UILabel()
        label.text = "(0/15)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .medium)
        return label
    }()
    
    // 내용을 작성하는 textView
    private(set) lazy var contentTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.font = UIFont.bodyFont(.small, weight: .medium)
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    // Content Text 글자 수 표시 label
    private(set) lazy var contentCountLabel: UILabel = {
        var label = UILabel()
        label.text = "(0/500)"
        label.textColor = UIColor(color: .placeholder)
        label.font = UIFont.bodyFont(.small, weight: .medium)
        return label
    }()
    
    
    // 사진을 추가하는 button
    private(set) lazy var addPictureButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        button.setImage(UIImage(systemName: "camera", withConfiguration: imageConfig), for: .normal)
        button.tintColor = UIColor(color: .main)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(color: .main).cgColor
        button.layer.cornerRadius = 5
        return button
    }()
    
    // 추가 사진을 보여주는 collectionView
    private(set) lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
}

private extension CreateNoticeBoardView {
    
    func configureUI() {
        backgroundColor = UIColor.white
    }
    
    func addSubView() {
        addSubview(titleTextView)
        addSubview(titleCountLabel)
        addSubview(contentTextView)
        addSubview(contentCountLabel)
        addSubview(addPictureButton)
        addSubview(galleryCollectionView)
    }
    
    func autoLayout() {
        titleTextView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
            make.height.equalTo(40)
        }
        
        titleCountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom).offset(Constant.margin1)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleCountLabel.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
            make.height.equalTo(320)
        }
        
        contentCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(Constant.margin1)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
        }
        
        addPictureButton.snp.makeConstraints { make in
            make.top.equalTo(contentCountLabel.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
            make.height.equalTo(30)
        }
        
        galleryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(addPictureButton.snp.bottom).offset(Constant.margin3)
            make.leading.equalTo(snp.leading).offset(Constant.margin3)
            make.trailing.equalTo(snp.trailing).offset(-Constant.margin3)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Constant.margin3)
        }
    }
}
