//
//  CommentStackView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/12.
//

import UIKit

class CommentStackView: UIStackView {

    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        return view
    }()
    let profileImageView: BasicImageView = {
        let imageView = BasicImageView(image: UIImage(systemName: "person.fill"))
        imageView.contentMargin = 4
        imageView.backgroundColor = UIColor(color: .contentPrimary)
        return imageView
    }()
    private let sendStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.font = .bodyFont(.small, weight: .regular)
        textView.backgroundColor = UIColor(color: .backgroundSecondary)
        textView.layer.cornerRadius = 5
        textView.textColor = UIColor(color: .placeholder)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = false
        return textView
    }()
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = UIColor(color: .contentPrimary)
        return button
    }()
    private let textViewPlaceHolder = "댓글을 입력해주세요"
    var commentAddHandler: ((String) -> Void)?

    var imageSize: CGFloat = 30

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackViewSetup()
        addViews()
        configureView()
        autoLayoutSetup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentStackView {
    private func stackViewSetup() {
        let margin = Constant.margin3
        axis = .horizontal
        alignment = .top
        distribution = .fill
        spacing = 12
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        backgroundColor = .white
    }

    private func addViews() {
        addSubview(lineView)
        addArrangedSubview(profileImageView)
        addArrangedSubview(sendStackView)
        sendStackView.addArrangedSubview(commentTextView)
        sendStackView.addArrangedSubview(sendButton)
    }

    private func configureView() {
        commentTextView.delegate = self
        commentTextView.text = textViewPlaceHolder

        sendButton.addTarget(self, action: #selector(sendButtonClick), for: .touchUpInside)
    }

    @objc private func sendButtonClick() {
        guard let textComment = commentTextView.text else { return }
        commentAddHandler?(textComment)
        commentTextView.text = ""
        commentTextView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = imageSize
            }
        }
    }

    private func autoLayoutSetup() {
        lineView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.height.equalTo(imageSize)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }
}

extension CommentStackView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { (constraint) in

            if estimatedSize.height < imageSize - 5 {
                textView.isScrollEnabled = false
            } else if textView.currentLineCount > 4 {
                textView.isScrollEnabled = true
            } else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .systemGray4
        }
    }
}

extension UITextView {
    var currentLineCount: Int {
        guard let font else { return 1 }
        return Int(self.contentSize.height / (font.lineHeight))
    }
}
