//
//  NoticeBoardViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit
import FirebaseAuth

class NoticeBoardViewController: UIViewController {
    
    private let noticeBoardView = NoticeBoardView()
    private let noticeBoardEmptyView = NoticeBoardEmptyView()

    
    var firebaseManager: FirebaseManager
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noticeBoardView.noticeBoardTableView.delegate = self
        noticeBoardView.noticeBoardTableView.dataSource = self
        
        firebaseManager.observeClubUserList()
        firebaseManager.readNoticeBoard() {success in
            if success {
                print("Firebase 정보 불러오기 성공")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseManager.delegate = self
        isClubExists()
        isMyClub()
        firebaseManager.readNoticeBoard { [weak self] _ in
            self?.noticeBoardView.noticeBoardTableView.reloadData()
        }
    }
    
    deinit {
        print("NoticeBoardViewController Deinit")
        firebaseManager.removeObserveClubUserList()
    }
    
    private func selectView() {
        if firebaseManager.noticeBoards.isEmpty {
            noticeBoardView.removeFromSuperview()
            if noticeBoardEmptyView.superview == nil {
                view.addSubview(noticeBoardEmptyView)
                setupView(for: noticeBoardEmptyView)
            }
        }
        else {
            noticeBoardEmptyView.removeFromSuperview()
            if noticeBoardView.superview == nil {
                view.addSubview(noticeBoardView)
                setupView(for: noticeBoardView)
            }
        }
    }
    
    private func setupView(for subView: UIView) {
        subView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

//MARK: Club 확인 관련
extension NoticeBoardViewController {
    private func isMyClub() {
        guard MyProfile.shared.isJoin(in: firebaseManager.club) else {
            AlertManager.showIsNotClubMemberChek(on: self)
            return
        }
        return
    }
    
    private func isClubExists() {
        if firebaseManager.isClubExists == false {
            AlertManager.showAlert(on: self, title: "클럽이 존재하지 않습니다", message: nil) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        return 
    }
}

// MARK: - 테이블 뷰 관련
extension NoticeBoardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firebaseManager.noticeBoards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeBoardTableViewCell.identifier, for: indexPath) as? NoticeBoardTableViewCell else { return UITableViewCell() }
        let noticeBoard = firebaseManager.noticeBoards[indexPath.row]
        cell.titleLabel.text = noticeBoard.title
        cell.contentLabel.text = noticeBoard.content
        cell.timeLabel.text = noticeBoard.createDate.toDate?.diffrenceDate ?? noticeBoard.createDate
        if let profileImageURL = noticeBoard.rootUser.profileImagePath {
            FBURLCache.shared.cancelDownloadURL(indexPath: indexPath)
            cell.indexPath = indexPath
            firebaseManager.getUserImage(referencePath: profileImageURL, imageSize: .medium) { downloadedImage in
                if let image = downloadedImage {
                    cell.setUserImage(profileImage: image, color: UIColor(color: .white), margin: 0)
                }
            }
        }
        else {
            if let defaultImage = UIImage(systemName: "person.fill") {
                cell.setUserImage(profileImage: defaultImage, color: UIColor(color: .contentBackground))
            }
        }
        cell.nameLabel.text = firebaseManager.noticeBoards[indexPath.row].rootUser.nickName
        cell.commentLabel.text = firebaseManager.noticeBoards[indexPath.row].commentCount
        cell.selectionStyle = .none
        
        cell.onImageTap = { [weak self] in
            self?.navigateToProfilePage(for: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NoticeBoardDetailViewController(noticeBoard: firebaseManager.noticeBoards[indexPath.row], firebaseNoticeBoardManager: firebaseManager, editIndex: indexPath.row)
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentNoticeBoard = firebaseManager.noticeBoards[indexPath.row]
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        if currentNoticeBoard.rootUser.id == currentUserID {
            let deleteNoticeBoardAction = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
                self.firebaseManager.deleteNoticeBoard(at: indexPath.row) { success in
                    if success {
                        self.firebaseManager.readNoticeBoard() {success in
                            if success {
                                print("Firebase 정보 불러오기 성공")
                            }
                        }
                    }
                }
                completion(true)
            }
            
            deleteNoticeBoardAction.backgroundColor = .systemRed
            deleteNoticeBoardAction.image = UIImage(systemName: "trash.fill")
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteNoticeBoardAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        } else {
            // 게시글 작성자와 현재 사용자가 다를 때
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    func navigateToProfilePage(for indexPath: IndexPath) {
        let profile = firebaseManager.noticeBoards[indexPath.row].rootUser
        PresentToProfileVC.presentToProfileVC(from: self, with: profile)
    }
}

// MARK: - FirebaseManaerDelegate 관련
extension NoticeBoardViewController: FirebaseManagerDelegate {
    func reloadData() {
        selectView()
        noticeBoardView.noticeBoardTableView.reloadData()
    }
    func updateComment(noticeBoardID: String, commentCount: String) {
        guard let index = firebaseManager.noticeBoards.firstIndex(where: { $0.id == noticeBoardID }) else { return }
        firebaseManager.noticeBoards[index].commentCount = commentCount
        reloadData()
    }
}
