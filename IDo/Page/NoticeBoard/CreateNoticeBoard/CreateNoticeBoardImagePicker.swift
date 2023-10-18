//
//  CreateNoticeBoardImagePicker.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/13.
//

import UIKit
import SnapKit

protocol ImagePickerDelegate: AnyObject {
    func clickDeleteButton()
}

class CreateNoticeBoardImagePicker: UIView {
    
    weak var delegate: ImagePickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        addSubView()
        autoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var galleryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor(color: .main).cgColor
        imageView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return imageView
    }()
    
    private(set) lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.imageView?.tintColor = UIColor(color: .negative)
        button.imageView?.backgroundColor = UIColor.white
        DispatchQueue.main.async {
            button.layer.cornerRadius = self.frame.size.width/2
        }
        button.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        return button
    }()
    
    @objc func tapDeleteButton() {
        delegate?.clickDeleteButton()
    }
}

private extension CreateNoticeBoardImagePicker {
    
    // NoticeBoardView의 기본 UI 설정
    func configureUI() {
        backgroundColor = UIColor.white
    }
    
    // noticeBoardTableView를 SubView에 추가
    func addSubView() {
        addSubview(galleryImageView)
        addSubview(deleteButton)
    }
    
    // 오토레이아웃 설정
    func autoLayout() {
        
        galleryImageView.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(8)
            make.leading.equalTo(snp.leading).offset(8)
            make.trailing.equalTo(snp.trailing).offset(-8)
            make.bottom.equalTo(snp.bottom).offset(-8)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(5)
            make.trailing.equalTo(snp.trailing).offset(-5)
            make.width.height.equalTo(15)
        }
    }
}
