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
import FirebaseStorage

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
    let urlCache = FBURLCache.shared
    let storage = Storage.storage().reference()
    
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
        firebaseCommentManager.readDatas { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.commentTableView.reloadData()
                case .failure(_):
                    self.commentTableView.reloadData()
                }
            }
        }
        NavigationBar.setNavigationCategoryTitle(for: navigationItem)
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        guard isClubExists(), isJoinCheck() else { return }
        
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
    
    // MARK: - 게시판 사용자 정보 보여주기
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
    
    func presentToProfilePage() {
        let profile = noticeBoard.rootUser
        PresentToProfileVC.presentToProfileVC(from: self, with: profile)
    }
    
    func noticeBoardSetup() {
        noticeBoardDetailView.onImageTap = { [weak self] in
            // 여기에서 MyProfileViewController로 넘어가는 로직을 구현합니다.
            self?.presentToProfilePage()
        }
        noticeBoardDetailView.writerInfoView.moreButtonTapHandler = { [weak self] in
            guard let self,
                isJoinCheck(), isClubExists() else { return }
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
//                    self.firebaseClubDatabaseManager.removeNoticeBoard(club: self.firebaseNoticeBoardManager.club, clubNoticeboard: self.firebaseNoticeBoardManager.noticeBoards[self.editIndex])
                    self.firebaseNoticeBoardManager.deleteNoticeBoard(at: self.editIndex) { success in
                        if success {
                            self.firebaseCommentManager.deleteAllCommentList()
                            self.firebaseNoticeBoardManager.readNoticeBoard() { success in
                                if success {
                                    print("Firebase 정보 불러오기 성공")
                                }
                            }
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
                let blockHandler: ((UIAlertAction) -> Void) = { [weak self] _ in
                    guard let self else { return }
                    MyProfile.shared.appendBlockUser(blockUser: self.noticeBoard.rootUser) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                AlertManager.showDeclaration(on: self, declarationHandler: declarationHandler, blockHandler: blockHandler)
            }
        }
    }
    
    //MARK: 게시글 신고
    func handleSuccessAction(title: String, message: String) {
        let okHandler: (UIAlertAction) -> Void = { _ in
            guard self.isJoinCheck(), self.isClubExists() else { return }
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
                    
                    
                    self.firebaseNoticeBoardManager.readNoticeBoard() { success in
                        if success {
                            print("Firebase 정보 불러오기 성공")
                        }
                    }
                    
                    if (self.firebaseNoticeBoardManager.club.userList?[rootUserIndex].declarationCount) ?? 0 >= 3 {
                        let userList = self.firebaseNoticeBoardManager.club.userList ?? []
                        let user = self.firebaseNoticeBoardManager.noticeBoards[self.editIndex].rootUser
                        
                        if user.id == self.firebaseNoticeBoardManager.club.rootUser.id {
                            self.firebaseClubDatabaseManager.removeClub(club: self.firebaseNoticeBoardManager.club) { isSuccess in
                                if isSuccess {
                                    guard let uid = Auth.auth().currentUser?.uid else {
                                        return
                                    }
                                    MyProfile.shared.getUserProfile(uid: uid) { _ in
                                        self.navigationController?.popToRootViewController(animated: true)
                                        return
                                    }
                                }
                                self.navigationController?.popToRootViewController(animated: true)
                                return
                            }
                            return
                        }
                        
                        self.firebaseClubDatabaseManager.removeUser(club: self.firebaseNoticeBoardManager.club, user: self.firebaseNoticeBoardManager.club.userList![rootUserIndex], isBlock: true) { success in
                            if success {
                                // 후에 해당 작성자에게 안내 메일 발송 기능 구현 예정
                                print("해당 작성자가 모임에서 방출되었습니다.")
                                self.navigationController?.popViewController(animated: true)
                                return
                            }
                        }
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        let noticeBoardRootUser = firebaseNoticeBoardManager.noticeBoards[editIndex].rootUser
        let clubRootUser = firebaseNoticeBoardManager.club.rootUser
        
        if noticeBoardRootUser.id == clubRootUser.id {
            AlertManager.showDeclaration(on: self, title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?\n이 게시글은 모임장의 게시글입니다.\n신고당하면 모임이 삭제될 수 있습니다.", declarationHandler: okHandler)
        } else {
            AlertManager.showCheckDeclaration(on: self, title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?", okHandler: okHandler)
        }
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
            
            guard isJoinCheck(), isClubExists() else {
                return
            }
            addComment(commentContent: content)
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

//MARK: 댓글 관련
extension NoticeBoardDetailViewController {
    
    private func addComment(commentContent: String) {
        guard isJoinCheck(), isClubExists() else { return }
        if let myUserInfo = MyProfile.shared.myUserInfo {
            let user = myUserInfo.toUserSummary
            let comment = Comment(id: UUID().uuidString, noticeBoardID: noticeBoard.id, writeUser: user, createDate: Date(), content: commentContent)
            
            firebaseCommentManager.appendData(data: comment) { isComplete in
                if isComplete {
                    
                    var myCommentList = myUserInfo.myCommentList ?? []
                    myCommentList.append(comment)
                    MyProfile.shared.update(myCommentList: myCommentList)
                    
                    self.firebaseCommentManager.readDatas { result in
                        switch result {
                        case .success(let commentList):
                            self.firebaseNoticeBoardManager.noticeBoards[self.editIndex].commentCount = String(commentList.count)
                            let updateNoticeBoard = self.firebaseNoticeBoardManager.noticeBoards[self.editIndex]
                            self.firebaseNoticeBoardManager.updateNoticeBoardCommentCount(noticeBoard: updateNoticeBoard)
                            self.delegate?.updateComment(noticeBoardID: updateNoticeBoard.id, commentCount: updateNoticeBoard.commentCount)
                            DispatchQueue.main.async {
                                self.commentTableView.reloadData()
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } else {
            //TODO: 사용자 로그인이 필요하다는 경고창과 함꼐 로그인 화면으로 넘기기
        }
    }
    
    private func update(comment: Comment) {
        guard isJoinCheck(), isClubExists() else { return }
        guard var myCommentList = MyProfile.shared.myUserInfo?.myCommentList else { return }
        if myCommentList.update(element: comment) == nil { return }
        MyProfile.shared.update(myCommentList: myCommentList)
        firebaseCommentManager.updateDatas(data: comment) { [weak self] _ in
            self?.commentTableView.reloadData()
        }
    }
    
    private func delete(comment: Comment) {
        guard isJoinCheck(), isClubExists() else { return }
        guard var myCommentList = MyProfile.shared.myUserInfo?.myCommentList else { return }
        myCommentList.removeAll(where: { $0.id == comment.id })
        MyProfile.shared.update(myCommentList: myCommentList)
        self.firebaseCommentManager.deleteData(data: comment) { [weak self] isComplete in
            guard let self else { return }
            self.firebaseCommentManager.readDatas { result in
                switch result {
                case .success(let commentList):
                    self.firebaseNoticeBoardManager.noticeBoards[self.editIndex].commentCount = String(commentList.count)
                    let updateNoticeBoard = self.firebaseNoticeBoardManager.noticeBoards[self.editIndex]
                    self.firebaseNoticeBoardManager.updateNoticeBoardCommentCount(noticeBoard: updateNoticeBoard)
                    self.delegate?.updateComment(noticeBoardID: updateNoticeBoard.id, commentCount: updateNoticeBoard.commentCount)
                    DispatchQueue.main.async {
                        self.commentTableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: 현재 클럽 상태 (사용자가 방출된 경우, 클럽이 없어진경우)
extension NoticeBoardDetailViewController {
    private func isJoinCheck() -> Bool {
        guard MyProfile.shared.isJoin(in: firebaseNoticeBoardManager.club) else {
            AlertManager.showIsNotClubMemberChek(on: self)
            return false
        }
        return true
    }
    private func isClubExists() -> Bool {
        if firebaseNoticeBoardManager.isClubExists == false {
            AlertManager.showAlert(on: self, title: "클럽이 존재하지 않습니다", message: nil) { _ in
                if let navigationController = self.navigationController {
                    for controller in navigationController.viewControllers {
                        if let meetingVC = controller as? MeetingViewController {
                            navigationController.popToViewController(meetingVC, animated: true)
                            break
                        }
                    }
                    navigationController.popToRootViewController(animated: true)
                }
            }
            return false
        }
        return true
    }
}

// MARK: 테이블뷰 관련
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
            guard let self else { return }
            if isCommentWriteUser {
                let updateHandler: (UIAlertAction) -> Void = { [weak tableView] _ in
                    guard let indexPath = tableView?.indexPath(for: cell) else { return }
                    let vc = CommentUpdateViewController(comment: comment)
                    vc.commentUpdate = { [weak self] updateComment in
                        guard let self else { return }
                        self.update(comment: updateComment)
                    }
                    vc.hidesBottomBarWhenPushed = true
                    vc.view.backgroundColor = UIColor(color: .backgroundPrimary)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let deleteHandler: (UIAlertAction) -> Void = { [weak tableView] _ in
                    guard let indexPath = tableView?.indexPath(for: cell) else { return }
                    let removeCommnet = self.firebaseCommentManager.modelList[indexPath.row]
                    self.delete(comment: removeCommnet)
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
                let blockHandler: ((UIAlertAction) -> Void) = { [weak self] _ in
                    guard let indexPath = tableView.indexPath(for: cell),
                          let blockUser = self?.firebaseCommentManager.modelList[indexPath.row].writeUser else { return }
                    MyProfile.shared.appendBlockUser(blockUser: blockUser) {
                        self?.firebaseCommentManager.readDatas { result in
                            switch result {
                            case .success(let commentList):
                                DispatchQueue.main.async {
                                    if commentList.isEmpty {
                                        self?.commentTableView.reloadSections(IndexSet(integer: 0), with: .none)
                                    } else {
                                        self?.commentTableView.reloadSections(IndexSet(integer: 1), with: .none)
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                AlertManager.showDeclaration(on: self, title: nil, message: nil, declarationHandler: declarationHandler, blockHandler: blockHandler)
            }
        }
        guard let dateText = comment.createDate.diffrenceDate else { return cell }
        cell.setDate(dateText: dateText)
        
        cell.onImageTap = { [weak self] in
            self?.navigateToProfilePage(for: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let currentUser else { return nil }
        if firebaseCommentManager.modelList.isEmpty { return nil }
        let comment = firebaseCommentManager.modelList[indexPath.row]
        guard comment.writeUser.id == currentUser.uid else { return nil }
        let removeAction = UIContextualAction(style: .normal, title: "삭제", handler: { [weak self] (action, view, completionHandler) in
            guard let self else { return }
            let removeCommnet = self.firebaseCommentManager.modelList[indexPath.row]
            self.delete(comment: removeCommnet)
        })
        let updateAction = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
            let comment = self.firebaseCommentManager.modelList[indexPath.row]
            let vc = CommentUpdateViewController(comment: comment)
            vc.commentUpdate = { [weak self] updateComment in
                guard let self else { return }
                self.update(comment: updateComment)
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
    
    //MARK: 댓글 신고
    private func declarationAlert(indexPath: IndexPath) {
        let commentUser = self.firebaseCommentManager.modelList[indexPath.row].writeUser
        guard let commentWriteUser = self.firebaseNoticeBoardManager.club.userList?.firstIndex(where: { $0.id == commentUser.id }) else { return }
        let deleteComment = self.firebaseCommentManager.modelList[indexPath.row]
        let clubRootUser = self.firebaseNoticeBoardManager.club.rootUser
        let okHandler: (UIAlertAction) -> Void = { _ in
            guard self.isJoinCheck(), self.isClubExists() else { return }
            
            self.firebaseCommentManager.deleteData(data: deleteComment) { isComplete in
                var declarationCount = self.firebaseNoticeBoardManager.club.userList?[commentWriteUser].declarationCount ?? 0
                declarationCount += 1
                self.firebaseNoticeBoardManager.club.userList?[commentWriteUser].declarationCount = declarationCount
                self.firebaseNoticeBoardManager.updateUserDeclarationCount(userID: deleteComment.writeUser.id, declarationCount: declarationCount)
                self.firebaseClubDatabaseManager.removeUserComment(comment: deleteComment)
                
                if self.firebaseNoticeBoardManager.club.userList?[commentWriteUser].declarationCount ?? 0 >= 3 {
                    
                    guard let userList = self.firebaseNoticeBoardManager.club.userList else {
                        print("UserList에 신고당해 방출될 회원이 없습니다.")
                        return
                    }
                    
                    let user = userList[commentWriteUser]
                    
                    if user.id == self.firebaseNoticeBoardManager.club.rootUser.id {
                        self.firebaseClubDatabaseManager.removeClub(club: self.firebaseNoticeBoardManager.club) { isSuccess in
                            if isSuccess {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                            self.navigationController?.popToRootViewController(animated: true)
                            return
                        }
                        return
                    }
                    
                    // club에 있는 유저 삭제
                    self.firebaseClubDatabaseManager.removeUser(club: self.firebaseNoticeBoardManager.club, user: self.firebaseNoticeBoardManager.club.userList![commentWriteUser], isBlock: true) { success in
                        if success {
                            // 후에 해당 작성자에게 안내 메일 발송 기능 구현 예정
                            print("해당 작성자가 모임에서 방출되었습니다.")
                            self.firebaseCommentManager.readDatas { [weak self] result in
                                switch result {
                                case .success(_):
                                    DispatchQueue.main.async {
                                        self?.commentTableView.reloadData()
                                    }
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            return
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.commentTableView.reloadData()
                }
            }
        }
        if commentUser.id == clubRootUser.id {
            AlertManager.showCheckDeclaration(on: self, title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?\n이 게시글은 모임장의 게시글입니다.\n신고당하면 모임이 삭제될 수 있습니다.", okHandler: okHandler)
        } else {
            AlertManager.showCheckDeclaration(on: self, title: "알림", message: "해당 항목으로 이 게시글을 신고하시겠습니까?", okHandler: okHandler)
        }
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
    func navigateToProfilePage(for indexPath: IndexPath) {
        let profile = firebaseCommentManager.modelList[indexPath.row].writeUser
        PresentToProfileVC.presentToProfileVC(from: self, with: profile)
    }
}
