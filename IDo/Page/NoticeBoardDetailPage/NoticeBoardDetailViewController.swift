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
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    private let commentPositionView: UIView = UIView()
    private let addCommentStackView: CommentStackView = CommentStackView()
    private var addCommentViewBottomConstraint: Constraint? = nil
    private var firebaseCommentManager: FirebaseCommentManaer
    private var currentUser: User?
    private var myProfileImage: UIImage?
    private var noticeBoard: NoticeBoard
    private let club: Club
    private let firebaseNoticeBoardManager: FirebaseManager
    weak var delegate: FirebaseManagerDelegate?
    
    private var editIndex: Int
    
    init(noticeBoard: NoticeBoard, club: Club, firebaseNoticeBoardManager: FirebaseManager, editIndex: Int) {
        self.noticeBoard = noticeBoard
        self.firebaseCommentManager = FirebaseCommentManaer(refPath: ["CommentList",noticeBoard.id], noticeBoard: noticeBoard)
        self.club = club
        self.firebaseNoticeBoardManager = firebaseNoticeBoardManager
        self.editIndex = editIndex
        super.init(nibName: nil, bundle: nil)
        self.currentUser = Auth.auth().currentUser
        guard let profileImageURL = noticeBoard.rootUser.profileImageURL  else { return }
        FBURLCache.shared.downloadURL(storagePath: profileImageURL + "/\(ImageSize.small.rawValue)") { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.noticeBoardDetailView.setupUserImage(image: image)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        firebaseCommentManager.update = { [weak self] in
            guard let self else { return }
            self.firebaseCommentManager.noticeBoardUpdate()
            self.delegate?.updateComment(noticeBoardID: self.noticeBoard.id, commentCount: "\(self.firebaseCommentManager.modelList.count)")
        }
        firebaseCommentManager.readDatas { result in
            switch result {
            case .success(_):
                self.commentTableView.reloadData()
            case .failure(_):
                self.commentTableView.reloadData()
            }
        }
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        guard let noticeBoard = firebaseNoticeBoardManager.noticeBoards.first(where: { $0.id == noticeBoard.id }) else { return }
        self.noticeBoard = noticeBoard
        print(noticeBoard)
        commentTableView.reloadSections(IndexSet(integer: 0), with: .none)
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
        noticeBoardSetup()
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
    
    func noticeBoardSetup() {
        if let dateString = noticeBoard.createDate.diffrenceDate {
            noticeBoardDetailView.writerInfoView.writerTimeLabel.text = dateString
        }
        noticeBoardDetailView.writerInfoView.writerNameLabel.text = noticeBoard.rootUser.nickName
        noticeBoardDetailView.contentTitleLabel.text = noticeBoard.title
        noticeBoardDetailView.contentDescriptionLabel.text = noticeBoard.content
        
        noticeBoardDetailView.loadingNoticeBoardImages(imageCount: noticeBoard.imageList.count)
        
        firebaseCommentManager.getNoticeBoardImages(noticeBoard: noticeBoard) { imageList in
            let sortedImageList = imageList.sorted(by: { $0.key < $1.key }).map{ $0.value }
            self.noticeBoardDetailView.addNoticeBoardImages(images: sortedImageList)
            DispatchQueue.main.async {
                self.commentTableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
        
        noticeBoardDetailView.writerInfoView.moreButtonTapHandler = { [weak self] in
            guard let self else { return }
            
            // MARK: - 게시판 업데이트 로직
            let updateHandler: (UIAlertAction) -> Void = { _ in
                let createNoticeVC = CreateNoticeBoardViewController(club: self.club, firebaseManager: self.firebaseNoticeBoardManager, index: self.editIndex, images: self.firebaseCommentManager.noticeBoardImages)
                
                self.firebaseNoticeBoardManager.selectedImage = self.firebaseCommentManager.noticeBoardImages
                
                createNoticeVC.editingTitleText = self.noticeBoard.title
                createNoticeVC.editingContentText = self.noticeBoard.content
                
                self.navigationController?.pushViewController(createNoticeVC, animated: true)
            }
            let deleteHandler: (UIAlertAction) -> Void = { _ in
                //MARK: 게시판 삭제 로직 구현
                self.firebaseNoticeBoardManager.deleteNoticeBoard(at: self.editIndex) { success in
                    if success {
                        self.firebaseNoticeBoardManager.readNoticeBoard(clubID: self.club.id)
                    }
                }
            }
            
            AlertManager.showUpdateAlert(on: self, updateHandler: updateHandler, deleteHandler: deleteHandler)
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
                    self.firebaseCommentManager.modelList.remove(at: indexPath.row)
                }
                let updateAction = UIAlertAction(title: "댓글 수정", style: .default) { _ in
                    let comment = self.firebaseCommentManager.modelList[indexPath.row]
                    let vc = CommentUpdateViewController(comment: comment)
                    vc.commentUpdate = { [weak self] comment in
                        guard let self else { return }
                        self.firebaseCommentManager.updateDatas(data: comment)
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
        firebaseCommentManager.getMyProfileImage(uid: currentUser!.uid, imageSize: .small) { image in
            DispatchQueue.main.async {
                self.addCommentStackView.profileImageView.imageView.image = image
                self.addCommentStackView.profileImageView.backgroundColor = UIColor(color: .white)
                self.addCommentStackView.profileImageView.contentMargin = 0
                self.myProfileImage = image
            }
        }
        
        addCommentStackView.commentAddHandler = { [weak self] content in
            guard let self else { return }
            if let iDoUser = firebaseCommentManager.currentIDoUser {
                let user = UserSummary(id: iDoUser.id, profileImageURL: iDoUser.profileImage, nickName: iDoUser.nickName)
                let comment = Comment(id: UUID().uuidString, noticeBoardID: "NoticeBoardID", writeUser: user, createDate: Date(), content: content)
                firebaseCommentManager.appendData(data: comment) { isComplete in
                    if isComplete {
                        if self.firebaseCommentManager.modelList.count == 1 {
                            self.commentTableView.reloadData()
                        } else {
                            self.commentTableView.beginUpdates()
                            self.commentTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .none)
                            self.commentTableView.endUpdates()
                        }
                    }
                }
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
            return firebaseCommentManager.modelList.isEmpty ? 1 : firebaseCommentManager.modelList.count
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
        if firebaseCommentManager.modelList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCountTableViewCell.identifier, for: indexPath) as? EmptyCountTableViewCell else { return UITableViewCell() }
            cell.viewState = firebaseCommentManager.viewState
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell,
              let currentUser else { return UITableViewCell() }
        cell.selectionStyle = .none
        if let defaultImage = UIImage(systemName: "person.fill") {
            cell.setUserImage(profileImage: defaultImage)
        }
        let comment = firebaseCommentManager.modelList[indexPath.row]
        firebaseCommentManager.getUserImage(referencePath: comment.writeUser.profileImageURL, imageSize: .small) { image in
            guard let image else { return }
            cell.setUserImage(profileImage: image)
        }
        cell.updateEnable = comment.writeUser.id == currentUser.uid
        cell.contentLabel.text = comment.content
        cell.writeInfoView.writerNameLabel.text = comment.writeUser.nickName
        cell.moreButtonTapHandler = { [weak self] in
            //TODO: 같이 LongPress할때와 똑같이 작동함 함수로 뺄 필요가 있음
            guard let self else { return }
            
            let updateHandler: (UIAlertAction) -> Void = { _ in
                let comment = self.firebaseCommentManager.modelList[indexPath.row]
                let vc = CommentUpdateViewController(comment: comment)
                vc.commentUpdate = { [weak self] comment in
                    guard let self else { return }
                    self.firebaseCommentManager.updateDatas(data: comment) { _ in
                        self.commentTableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
                vc.hidesBottomBarWhenPushed = true
                vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let deleteHandler: (UIAlertAction) -> Void = { _ in
                self.firebaseCommentManager.modelList.remove(at: indexPath.row)
            }
            
            AlertManager.showUpdateAlert(on: self, updateHandler: updateHandler, deleteHandler: deleteHandler)
        }
        guard let dateText = comment.createDate.diffrenceDate else { return cell }
        cell.setDate(dateText: dateText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let currentUser else { return nil }
        if firebaseCommentManager.modelList.isEmpty { return nil }
        let comment = firebaseCommentManager.modelList[indexPath.row]
        guard comment.writeUser.id == currentUser.uid else { return nil }
        let deleteAction = UIContextualAction(style: .normal, title: "삭제", handler: {(action, view, completionHandler) in
            
            let comment = self.firebaseCommentManager.modelList[indexPath.row]
            self.firebaseCommentManager.deleteData(data: comment) { isComplete in
                if self.firebaseCommentManager.modelList.isEmpty {
                    tableView.reloadData()
                } else {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .none)
                    tableView.endUpdates()
                }
            }
            
        })
        let updateAction = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
            let comment = self.firebaseCommentManager.modelList[indexPath.row]
            let vc = CommentUpdateViewController(comment: comment)
            vc.commentUpdate = { [weak self] comment in
                guard let self else { return }
                self.firebaseCommentManager.updateDatas(data: comment)
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
