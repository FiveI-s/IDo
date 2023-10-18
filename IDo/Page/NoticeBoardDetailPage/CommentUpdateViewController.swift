//
//  CommentUpdateViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/17.
//

import Foundation
import UIKit

class CommentUpdateViewController: UIViewController {
    
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor(color: .textStrong)
        textView.font = .bodyFont(.medium, weight: .regular)
        return textView
    }()
    
//    private var comment: CommentTest
    private var comment: Comment
    
//    var commentUpdate: ((CommentTest)->Void)?
    var commentUpdate: ((Comment)->Void)?
    
    init(comment: Comment) {
        self.comment = comment
        super.init(nibName: nil, bundle: nil)
        commentTextView.text = comment.content
    }
//    init(comment: CommentTest) {
//        self.comment = comment
//        super.init(nibName: nil, bundle: nil)
//        commentTextView.text = comment.content
//    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private extension CommentUpdateViewController {
    
    func setup() {
        navigationSetup()
        addViews()
        autoLayoutSetup()
        textViewSetup()
    }
    
    func navigationSetup() {
        let updateButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(updateButtonClick))
        navigationItem.rightBarButtonItem = updateButton
    }
    
    @objc func updateButtonClick() {
        guard let text = commentTextView.text else { return }
        comment.content = text
        commentUpdate?(comment)
        navigationController?.popViewController(animated: true)
    }
    
    func addViews() {
        view.addSubview(commentTextView)
    }
    
    func autoLayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        commentTextView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea).inset(Constant.margin3)
        }
    }
    
    func textViewSetup() {
        commentTextView.delegate = self
    }
}

extension CommentUpdateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let commentEmpty = textView.text.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !commentEmpty
    }
}
