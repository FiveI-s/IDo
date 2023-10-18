//
//  NoticeBoardDetailViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase

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
    private var addCommentViewBottomConstraint: Constraint? = nil
    private var firebaseManager: FirebaseCommentManager!
    private var viewState: ViewState = .loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager = FirebaseCommentManager(noticeBoardID: "NoticeBoardID")
        firebaseManager.update = { [weak self] in
            self?.commentTableView.reloadData()
        }
        firebaseManager.readCommtents()
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
        addCommentSetup()
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
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(commentLongPress))
        commentTableView.addGestureRecognizer(longPress)
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentTableView.register(EmptyCountTableViewCell.self, forCellReuseIdentifier: EmptyCountTableViewCell.identifier)
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    @objc func commentLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: commentTableView)
            if let indexPath = commentTableView.indexPathForRow(at: touchPoint) {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let removeAction = UIAlertAction(title: "댓글 삭제", style: .destructive) { _ in
                    self.firebaseManager.commentList.remove(at: indexPath.row)
                }
                let updateAction = UIAlertAction(title: "댓글 수정", style: .default) { _ in
                    let comment = self.firebaseManager.commentList[indexPath.row]
                    let vc = CommentUpdateViewController(comment: comment)
                    vc.commentUpdate = { [weak self] comment in
                        guard let self else { return }
                        self.firebaseManager.updateComments(comment: comment)
                    }
                    vc.hidesBottomBarWhenPushed = true
                    vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                alert.addAction(cancelAction)
                alert.addAction(updateAction)
                alert.addAction(removeAction)
                present(alert, animated: true)
            }
        }
    }
    
    func addCommentSetup() {
        addCommentStackView.commentAddHandler = { [weak self] content in
            guard let self else { return }
            if let user = Auth.auth().currentUser {
                let user = UserSummary(id: user.uid, nickName: "test")
                let comment = Comment(id: UUID().uuidString, noticeBoardID: "NoticeBoardID", writeUser: user, createDate: Date(), content: content)
                firebaseManager.addComment(comment: comment)
            } else {
                //TODO: 사용자 로그인이 필요하다는 경고창과 함꼐 로그인 화면으로 넘기기
            }
        }
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
            return firebaseManager.commentList.isEmpty ? 1 : firebaseManager.commentList.count
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
        if firebaseManager.commentList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCountTableViewCell.identifier, for: indexPath) as? EmptyCountTableViewCell else { return UITableViewCell() }
            cell.viewState = firebaseManager.viewState
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let comment = firebaseManager.commentList[indexPath.row]
        cell.contentLabel.text = comment.content
        cell.userInfoStackView.writerNameLabel.text = comment.writeUser.nickName
        cell.moreButtonTapHandler = { [weak self] in
            //TODO: 같이 LongPress할때와 똑같이 작동함 함수로 뺄 필요가 있음
            guard let self else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let removeAction = UIAlertAction(title: "댓글 삭제", style: .destructive) { _ in
                self.firebaseManager.commentList.remove(at: indexPath.row)
            }
            let updateAction = UIAlertAction(title: "댓글 수정", style: .default) { _ in
                let comment = self.firebaseManager.commentList[indexPath.row]
                let vc = CommentUpdateViewController(comment: comment)
                vc.commentUpdate = { [weak self] comment in
                    guard let self else { return }
                    self.firebaseManager.updateComments(comment: comment)
                }
                vc.hidesBottomBarWhenPushed = true
                vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(updateAction)
            alert.addAction(removeAction)
            present(alert, animated: true)
        }
        guard let dateText = comment.createDate.diffrenceDate else { return cell }
        cell.setDate(dateText: dateText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if firebaseManager.commentList.isEmpty { return nil }
        let deleteAction = UIContextualAction(style: .normal, title: "삭제", handler: {(action, view, completionHandler) in
            let comment = self.firebaseManager.commentList[indexPath.row]
            self.firebaseManager.deleteComment(comment: comment)
        })
        let updateAction = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
            let comment = self.firebaseManager.commentList[indexPath.row]
            let vc = CommentUpdateViewController(comment: comment)
            vc.commentUpdate = { [weak self] comment in
                guard let self else { return }
                self.firebaseManager.updateComments(comment: comment)
            }
            vc.hidesBottomBarWhenPushed = true
            vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        deleteAction.backgroundColor = UIColor(color: .negative)
        updateAction.backgroundColor = UIColor(color: .contentPrimary)
        let config = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
}
