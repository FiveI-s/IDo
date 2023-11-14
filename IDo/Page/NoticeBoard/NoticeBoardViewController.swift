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
        
        firebaseManager.readNoticeBoard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firebaseManager.delegate = self
        
        
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
                        self.firebaseManager.readNoticeBoard()
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
        let profileViewController = MyProfileViewController()
        profileViewController.userProfile = profile

        if let profileImageURL = profile.profileImagePath {
            firebaseManager.getUserImage(referencePath: profileImageURL, imageSize: .medium) { [weak profileViewController] downloadedImage in
                DispatchQueue.main.async {
                    if let image = downloadedImage {
                        profileViewController?.profileImage.setImage(image, for: .normal)
                    }
                }
            }
        }
        else {
            
            if let defaultImage = UIImage(named: "profile") {
                profileViewController.profileImage.setImage(defaultImage, for: .normal)
            }
        }

        profileViewController.profileName.text = profile.nickName
        if let hobbyList = profile.hobbyList {
            profileViewController.choiceEnjoyTextField.text = hobbyList.first
        }
        profileViewController.selfInfoDetail.text = profile.description
        
        profileViewController.profileImage.isUserInteractionEnabled = true
        profileViewController.profileName.isEditable = false
        profileViewController.choicePickerView.isUserInteractionEnabled = false
        profileViewController.selfInfoDetail.isEditable = false
        profileViewController.logout.isHidden = true
        profileViewController.line.isHidden = true
        profileViewController.deleteID.isHidden = true

         // 전체 화면으로 모달을 표시하려면 이 줄을 추가하세요.
        self.present(profileViewController, animated: true, completion: nil)
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
