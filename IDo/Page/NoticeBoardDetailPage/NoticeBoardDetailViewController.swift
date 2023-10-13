//
//  NoticeBoardDetailViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit
import SnapKit

final class NoticeBoardDetailViewController: UIViewController {
    
    private let noticeBoardDetailView: NoticeBoardDetailView = NoticeBoardDetailView()
    private let commentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(color: .backgroundPrimary)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        return tableView
    }()
    private let commentPositionView: UIView = UIView()
    private let addCommentStackView: CommentStackView = CommentStackView()
    private let dummyList: [Int] = [1,2,3,4,5,6,7,8,9,10]
    private var addCommentViewBottomConstraint: Constraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

}

private extension NoticeBoardDetailViewController {
    func setup() {
        addViews()
        autoLayoutSetup()
        tableViewSetup()
    }
    func addViews() {
        view.addSubview(commentPositionView)
        view.addSubview(commentTableView)
        view.addSubview(addCommentStackView)
    }
    func autoLayoutSetup() {
        let safeArea = view.safeAreaLayoutGuide
        
        commentTableView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea).inset(Constant.margin3)
            make.bottom.equalTo(commentPositionView.snp.top).offset(Constant.margin3)
        }
        
        addCommentStackView.snp.makeConstraints { make in
            make.left.right.equalTo(safeArea)
            self.addCommentViewBottomConstraint = make.bottom.equalTo(safeArea).constraint
        }
        
        commentPositionView.snp.makeConstraints { make in
            make.edges.equalTo(addCommentStackView)
        }
        
    }
    func tableViewSetup() {
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentTableView.register(EmptyCountTableViewCell.self, forCellReuseIdentifier: EmptyCountTableViewCell.identifier)
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let safeAreaBottomHeight = view.safeAreaInsets.bottom
        self.addCommentViewBottomConstraint?.update(inset: keyboardHeight - safeAreaBottomHeight)
    }

    @objc func keyBoardWillHide(notification: NSNotification) {
        self.addCommentViewBottomConstraint?.update(inset: 0)
    }
}

extension NoticeBoardDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return dummyList.isEmpty ? 1 : dummyList.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerView = UIView()
            headerView.addSubview(noticeBoardDetailView)
            noticeBoardDetailView.snp.makeConstraints { make in
                make.top.left.right.bottom.equalTo(headerView)
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dummyList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCountTableViewCell.identifier, for: indexPath) as? EmptyCountTableViewCell else { return UITableViewCell() }
            cell.setMessage(image: UIImage(systemName: "bubble.right.fill"), imageSize: 60, title: "댓글이 없습니다.", description: "댓글을 작성해주세요")
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
    
}
