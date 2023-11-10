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
    private let firebaseNoticeBoardManager: FirebaseManager
    private let firebaseClubDatabaseManager: FirebaseClubDatabaseManager
    weak var delegate: FirebaseManagerDelegate?
    
    private var editIndex: Int
    
    init(noticeBoard: NoticeBoard, firebaseNoticeBoardManager: FirebaseManager, editIndex: Int) {
        self.noticeBoard = noticeBoard
        self.firebaseCommentManager = FirebaseCommentManaer(refPath: ["CommentList",noticeBoard.id], noticeBoard: noticeBoard)
        self.firebaseNoticeBoardManager = firebaseNoticeBoardManager
        self.editIndex = editIndex
        self.firebaseClubDatabaseManager = FirebaseClubDatabaseManager(refPath: [firebaseNoticeBoardManager.club.category, "meetings", firebaseNoticeBoardManager.club.id])
        super.init(nibName: nil, bundle: nil)
        self.currentUser = Auth.auth().currentUser
        guard let profileImageURL = noticeBoard.rootUser.profileImagePath  else { return }
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
            self.firebaseCommentManager.updateNoticeBoard()
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
        NavigationBar.setNavigationCategoryTitle(for: navigationItem)
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        guard let noticeBoard = firebaseNoticeBoardManager.noticeBoards.first(where: { $0.id == noticeBoard.id }) else { return }
        self.noticeBoard = noticeBoard
        updateNoticeBoardSetup()
        firebaseCommentManager.readDatas { result in
            switch result {
            case .success(let commentList):
                DispatchQueue.main.async {
                    if commentList.isEmpty {
                        self.commentTableView.reloadSections(IndexSet(integer: 0), with: .none)
                    } else {
                        self.commentTableView.reloadSections(IndexSet(integer: 1), with: .none)
                    }
//                    self.commentTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
            make.top.equalTo(safeArea).inset(Constant.margin3)
            make.left.right.equalTo(safeArea).inset(Constant.margin4)
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
    
    func updateNoticeBoardSetup() {
        if let dateString = noticeBoard.createDate.toDate?.diffrenceDate {
            noticeBoardDetailView.writerInfoView.writerTimeLabel.text = dateString
        }
        noticeBoardDetailView.writerInfoView.writerNameLabel.text = noticeBoard.rootUser.nickName
        noticeBoardDetailView.contentTitleLabel.text = noticeBoard.title
        noticeBoardDetailView.contentDescriptionLabel.text = noticeBoard.content
        
        noticeBoardDetailView.loadingNoticeBoardImages(imageCount: noticeBoard.imageList?.count ?? 0)
        firebaseCommentManager.getNoticeBoardImages(noticeBoard: noticeBoard) { imageList in
            let sortedImageList = imageList.sorted(by: { $0.key < $1.key }).map{ $0.value }
            self.noticeBoardDetailView.addNoticeBoardImages(images: sortedImageList)
            DispatchQueue.main.async {
                self.commentTableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
        guard let profileImageURL = noticeBoard.rootUser.profileImagePath  else { return }
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
    
    func noticeBoardSetup() {
//        if let dateString = noticeBoard.createDate.toDate?.diffrenceDate {
//            noticeBoardDetailView.writerInfoView.writerTimeLabel.text = dateString
//        }
//        noticeBoardDetailView.writerInfoView.writerNameLabel.text = noticeBoard.rootUser.nickName
//        noticeBoardDetailView.contentTitleLabel.text = noticeBoard.title
//        noticeBoardDetailView.contentDescriptionLabel.text = noticeBoard.content
//        
//        noticeBoardDetailView.loadingNoticeBoardImages(imageCount: noticeBoard.imageList?.count ?? 0)
//        
//        firebaseCommentManager.getNoticeBoardImages(noticeBoard: noticeBoard) { imageList in
//            let sortedImageList = imageList.sorted(by: { $0.key < $1.key }).map{ $0.value }
//            self.noticeBoardDetailView.addNoticeBoardImages(images: sortedImageList)
//            DispatchQueue.main.async {
//                self.commentTableView.reloadSections(IndexSet(integer: 0), with: .none)
//            }
//        }
        
        noticeBoardDetailView.writerInfoView.moreButtonTapHandler = { [weak self] in
            guard let self else { return }
            
            if noticeBoard.rootUser.id == currentUser?.uid {
                // MARK: - 게시판 업데이트 로직
                let updateHandler: (UIAlertAction) -> Void = { _ in
                    let createNoticeVC = CreateNoticeBoardViewController(club: self.firebaseNoticeBoardManager.club, firebaseManager: self.firebaseNoticeBoardManager, index: self.editIndex)
                    
                    self.firebaseNoticeBoardManager.selectedImage = self.firebaseCommentManager.noticeBoardImages
                    
                    self.firebaseNoticeBoardManager.newSelectedImage = self.firebaseCommentManager.noticeBoardImages
                    
                    createNoticeVC.editingTitleText = self.noticeBoard.title
                    createNoticeVC.editingContentText = self.noticeBoard.content
                    
                    self.firebaseNoticeBoardManager.removeSelecteImage = []
                    
                    self.navigationController?.pushViewController(createNoticeVC, animated: true)
                }
                
                // MARK: - 게시판 삭제 로직
                let deleteHandler: (UIAlertAction) -> Void = { _ in
                    self.firebaseNoticeBoardManager.deleteNoticeBoard(at: self.editIndex) { success in
                        if success {
                            self.firebaseCommentManager.deleteAllCommentList()
                            self.firebaseNoticeBoardManager.readNoticeBoard()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
                AlertManager.showUpdateAlert(on: self, updateHandler: updateHandler, deleteHandler: deleteHandler)
            }
            else {
                // MARK: - 게시판 신고 로직
                let declarationHandler: (UIAlertAction) -> Void = { _ in
                    let spamHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let dislikeHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let selfHarmHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let illegalSaleHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let nudityHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let hateSpeechHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let violenceHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    let bullyingHandler: (UIAlertAction) -> Void = { _ in
                        
                        self.handleSuccessAction(title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?")
                    }
                    
                    AlertManager.showDeclarationActionSheet(on: self, title: "신고하기", message: "신고의 이유를 해당 항목에서 선택해주세요.", spamHandler: spamHandler, dislikeHandler: dislikeHandler, selfHarmHandler: selfHarmHandler, illegalSaleHandler: illegalSaleHandler, nudityHandler: nudityHandler, hateSpeechHandler: hateSpeechHandler, violenceHandler: violenceHandler, bullyingHandler: bullyingHandler)
                }
                AlertManager.showDeclaration(on: self, title: "알림", message: "이 게시글을 신고하시겠습니까?", declarationHandler: declarationHandler)
            }
        }
    }
    
    func handleSuccessAction(title: String, message: String) {
        let okHandler: (UIAlertAction) -> Void = { _ in
            
            // 해당 게시글의 작성자에 접근
            let rootUser = self.firebaseNoticeBoardManager.noticeBoards[self.editIndex].rootUser
            
            // 클럽 userList에서 해당 게시글 작성자 인덱스에 접근
            guard let rootUserIndex = self.firebaseNoticeBoardManager.club.userList?.firstIndex(where: { $0.id == rootUser.id}) else { return }
            
            // club에 있는 noticeboardList 지우기
            self.firebaseClubDatabaseManager.removeNoticeBoard(club: self.firebaseNoticeBoardManager.club, clubNoticeboard: self.firebaseNoticeBoardManager.noticeBoards[self.editIndex]) { success in
                
                self.firebaseNoticeBoardManager.club.noticeBoardList?.removeAll(where: {$0.id == self.firebaseNoticeBoardManager.noticeBoards[self.editIndex].id})
                
                
            }
            
            // 그냥 noticeboardList에서 지우기
            self.firebaseNoticeBoardManager.deleteNoticeBoard(at: self.editIndex) { success in
                if success {
                    
                    // 신고 횟수
                    var declarationCount = self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount ?? 0
                    declarationCount += 1
                    self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount = declarationCount
                    
                    self.firebaseNoticeBoardManager.updateUserDeclarationCount(userID: self.noticeBoard.rootUser.id, declarationCount: declarationCount)
                    
                    
                    self.firebaseNoticeBoardManager.readNoticeBoard()
                    
                    if self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount == 3 {
                        
                        // club에 있는 유저 삭제
                        self.firebaseClubDatabaseManager.removeUser(club: self.firebaseNoticeBoardManager.club, user: self.firebaseNoticeBoardManager.club.userList![rootUserIndex]) { success in
                            if success {
                                // 후에 해당 작성자에게 안내 메일 발송 기능 구현 예정
                                print("해당 작성자가 모임에서 방출되었습니다.")
                            }
                        }
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        AlertManager.showCheckDeclaration(on: self, title: title, message: message, okHandler: okHandler)
    }
    
    func tableViewSetup() {
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentTableView.register(EmptyCountTableViewCell.self, forCellReuseIdentifier: EmptyCountTableViewCell.identifier)
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    func addCommentSetup() {
        if let imageData = MyProfile.shared.myUserInfo?.profileImage[ImageSize.small.rawValue],
           let image = UIImage(data: imageData) {
            addCommentStackView.profileImageView.imageView.image = image
            addCommentStackView.profileImageView.backgroundColor = UIColor(color: .white)
            addCommentStackView.profileImageView.contentMargin = 0
            myProfileImage = image
        }
        
        addCommentStackView.commentAddHandler = { [weak self] content in
            guard let self else { return }
            if let myUserInfo = MyProfile.shared.myUserInfo {
                let user = UserSummary(id: myUserInfo.id, profileImagePath: myUserInfo.profileImagePath, nickName: myUserInfo.nickName)
                let comment = Comment(id: UUID().uuidString, noticeBoardID: noticeBoard.id, writeUser: user, createDate: Date(), content: content)
                firebaseCommentManager.appendData(data: comment) { isComplete in
                    if isComplete {
                        var myCommentList = myUserInfo.myCommentList ?? []
                        myCommentList.append(comment)
                        MyProfile.shared.update(myCommentList: myCommentList)
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
            cell.setUserImage(profileImage: defaultImage, color: UIColor(color: .contentBackground))
        }
        let comment = firebaseCommentManager.modelList[indexPath.row]
        firebaseCommentManager.getUserImage(referencePath: comment.writeUser.profileImagePath, imageSize: .small) { image in
            guard let image else { return }
            cell.setUserImage(profileImage: image, color: UIColor(color: .white), margin: 0)
        }
        let isCommentWriteUser = comment.writeUser.id == currentUser.uid
        cell.contentLabel.text = comment.content
        cell.writeInfoView.writerNameLabel.text = comment.writeUser.nickName
        cell.moreButtonTapHandler = { [weak self] in
            //TODO: 같이 LongPress할때와 똑같이 작동함 함수로 뺄 필요가 있음
            guard let self else { return }
            if isCommentWriteUser {
                let updateHandler: (UIAlertAction) -> Void = { _ in
                    let comment = self.firebaseCommentManager.modelList[indexPath.row]
                    let vc = CommentUpdateViewController(comment: comment)
                    vc.commentUpdate = { [weak self] updateComment in
                        guard let self else { return }
                        guard var myCommentList = MyProfile.shared.myUserInfo?.myCommentList else { return }
                        if myCommentList.update(element: updateComment) == nil { return }
                        MyProfile.shared.update(myCommentList: myCommentList)
                        self.firebaseCommentManager.updateDatas(data: updateComment) { _ in
                            DispatchQueue.main.async {
                                self.commentTableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    }
                    vc.hidesBottomBarWhenPushed = true
                    vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let deleteHandler: (UIAlertAction) -> Void = { _ in
                    let removeCommnet = self.firebaseCommentManager.modelList[indexPath.row]
                    guard var myCommentList = MyProfile.shared.myUserInfo?.myCommentList else { return }
                    myCommentList.removeAll(where: { $0.id == removeCommnet.id })
                    MyProfile.shared.update(myCommentList: myCommentList)
                    self.firebaseCommentManager.deleteData(data: removeCommnet) { isComplete in
                        if self.firebaseCommentManager.modelList.isEmpty {
                            tableView.reloadData()
                        } else {
                            self.deleteCell(tableView: tableView, indexPath: indexPath)
                        }
                    }
                }
                
                AlertManager.showUpdateAlert(on: self, updateHandler: updateHandler, deleteHandler: deleteHandler)
            } else {
                let declarationHandler: (UIAlertAction) -> Void = { _ in
                    let spamHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let dislikeHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let selfHarmHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let illegalSaleHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let nudityHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let hateSpeechHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let violenceHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    let bullyingHandler: (UIAlertAction) -> Void = { _ in
                        self.declarationAlert(indexPath: indexPath)
                    }
                    
                    AlertManager.showDeclarationActionSheet(on: self, title: "신고하기", message: "신고의 이유를 해당 항목에서 선택해주세요.", spamHandler: spamHandler, dislikeHandler: dislikeHandler, selfHarmHandler: selfHarmHandler, illegalSaleHandler: illegalSaleHandler, nudityHandler: nudityHandler, hateSpeechHandler: hateSpeechHandler, violenceHandler: violenceHandler, bullyingHandler: bullyingHandler)
                }
                AlertManager.showDeclaration(on: self, title: "알림", message: "이 게시글을 신고하시겠습니까?", declarationHandler: declarationHandler)
            }
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
        let removeAction = UIContextualAction(style: .normal, title: "삭제", handler: {(action, view, completionHandler) in
            
            let removeCommnet = self.firebaseCommentManager.modelList[indexPath.row]
            guard var myCommentList = MyProfile.shared.myUserInfo?.myCommentList else { return }
            myCommentList.removeAll(where: { $0.id == removeCommnet.id })
            MyProfile.shared.update(myCommentList: myCommentList)
            self.firebaseCommentManager.deleteData(data: removeCommnet) { isComplete in
                if self.firebaseCommentManager.modelList.isEmpty {
                    tableView.reloadData()
                } else {
                    self.deleteCell(tableView: tableView, indexPath: indexPath)
                }
            }
            
        })
        let updateAction = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
            let comment = self.firebaseCommentManager.modelList[indexPath.row]
            let vc = CommentUpdateViewController(comment: comment)
            vc.commentUpdate = { [weak self] updateComment in
                guard let self else { return }
                guard var myCommentList = MyProfile.shared.myUserInfo?.myCommentList else { return }
                if myCommentList.update(element: updateComment) == nil { return }
                MyProfile.shared.update(myCommentList: myCommentList)
                self.firebaseCommentManager.updateDatas(data: updateComment) { _ in
                    self.commentTableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            vc.hidesBottomBarWhenPushed = true
            vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        removeAction.backgroundColor = UIColor(color: .negative)
        updateAction.backgroundColor = UIColor(color: .contentPrimary)
        let config = UISwipeActionsConfiguration(actions: [removeAction, updateAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    private func declarationAlert(indexPath: IndexPath) {
        let okHandler: (UIAlertAction) -> Void = { _ in
            let commentUser = self.firebaseCommentManager.modelList[indexPath.row].writeUser
            
            guard let rootUserIndex = self.firebaseNoticeBoardManager.club.userList?.firstIndex(where: { $0.id == commentUser.id}) else { return }
            
            let deleteCommnet = self.firebaseCommentManager.modelList[indexPath.row]
            self.firebaseCommentManager.deleteData(data: deleteCommnet) { isComplete in
                var declarationCount = self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount ?? 0
                declarationCount += 1
                self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount = declarationCount
                self.firebaseNoticeBoardManager.updateUserDeclarationCount(userID: deleteCommnet.writeUser.id, declarationCount: declarationCount)
                self.firebaseClubDatabaseManager.removeUserComment(comment: deleteCommnet)
                
                if self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount == 3 {
                    
                    // club에 있는 유저 삭제
                    self.firebaseClubDatabaseManager.removeUser(club: self.firebaseNoticeBoardManager.club, user: self.firebaseNoticeBoardManager.club.userList![rootUserIndex]) { success in
                        if success {
                            // 후에 해당 작성자에게 안내 메일 발송 기능 구현 예정
                            print("해당 작성자가 모임에서 방출되었습니다.")
                        }
                    }
                }
                if self.firebaseCommentManager.modelList.isEmpty {
                    self.commentTableView.reloadData()
                } else {
                    self.deleteCell(tableView: self.commentTableView, indexPath: indexPath)
                }
            }
        }
        AlertManager.showCheckDeclaration(on: self, title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?", okHandler: okHandler)
    }
    
    private func insertCell(tableView: UITableView, indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
    
    private func deleteCell(tableView: UITableView, indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
    
}
