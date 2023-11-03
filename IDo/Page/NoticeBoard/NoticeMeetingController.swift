//
//  NoticeMeetingController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import FirebaseAuth
import FirebaseDatabase
import Pageboy
import Tabman
import SnapKit
import UIKit

enum AuthState {
    case root
    case member
    case notMember
}

final class NoticeMeetingController: TabmanViewController {
    private var viewControllers: [UIViewController] = []
    private var tempView: UIView = UIView()
    private let firebaseManager: FirebaseManager
    private var club: Club
    private let firebaseClubDatabaseManager: FirebaseClubDatabaseManager
    private let clubImage: UIImage
    private let homeVC: NoticeHomeController
    
    private var authState: AuthState {
        didSet {
            updateNavigationItme()
        }
    }

    init(club: Club, currentUser: MyUserInfo, clubImage: UIImage) {
        self.club = club
        self.firebaseManager = FirebaseManager(club: club)
        self.clubImage = clubImage
        self.firebaseClubDatabaseManager = FirebaseClubDatabaseManager(refPath: [club.category,"meetings",club.id])
        
        let isRootUser = currentUser.id == club.rootUser.id
        let isClubMember = club.userList?.contains(where: { $0.id == currentUser.id }) ?? false
        if isRootUser {
            self.authState = .root
        } else if isClubMember {
            self.authState = .member
        } else {
            self.authState = .notMember
        }
        self.homeVC = NoticeHomeController(club: club, authState: authState, firebaseClubDataManager: firebaseClubDatabaseManager, clubImage: clubImage)
        super.init(nibName: nil, bundle: nil)
        
        firebaseClubDatabaseManager.readData()
        homeVC.signUpButtonUpdate = { [weak self] authState in
            self?.authState = authState
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authCheck()
        setupTabman()
    }
    
    func setupTabman() {
        view.addSubview(tempView)
        
        tempView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(30)
        }
        
        setupTabmanViewController()
        setupTabmanBar()
        
        bounces = false
        dataSource = self
        isScrollEnabled = false
        
    }
    
    private func setupTabmanBar() {
        let bar = TMBar.ButtonBar()
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        // 탭 바의 배경 색상 설정
        bar.backgroundView.style = .flat(color: .white)
        // 탭 아이템의 글자 색상 설정
        bar.buttons.customize { (button) in
            // 비활성화된 탭의 색상
            button.tintColor = UIColor(color: .contentDisable)
            
            // 활성화된 탭의 색상
            button.selectedTintColor = UIColor(color: .main)
        }
        
        // 선택된 탭 아래에 나타나는 인디케이터의 색상 설정
        bar.indicator.tintColor = UIColor(color: .main)
        
        addBar(bar, dataSource: self, at: .custom(view: tempView, layout: nil))
    }
    
    private func setupTabmanViewController() {
        let titleVC = NoticeBoardViewController(firebaseManager: firebaseManager)

        viewControllers.append(homeVC)
        viewControllers.append(titleVC)
    }
}

extension NoticeMeetingController {
    
    private func authCheck() {
        guard let currentUser = MyProfile.shared.myUserInfo else { return }
        if currentUser.id == club.rootUser.id {
            authState = .root
        } else if club.userList?.contains(where: { $0.id == currentUser.id }) ?? false {
            authState = .member
        } else {
            authState = .notMember
        }
    }
    
    private func updateNavigationItme() {
        switch authState {
        case .root:
            let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(moreAlert))
            navigationItem.rightBarButtonItem = moreButton
        case .member:
            let outButton = UIBarButtonItem(title: "모임 탈퇴", style: .plain, target: self, action: #selector(outAlert))
            outButton.tintColor = UIColor(color: .negative)
            navigationItem.rightBarButtonItem = outButton
        case .notMember:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "알림", message: "모임에 가입한 회원만 이용 가능합니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func moveCreateVC() {
        let createNoticeBoardVC = CreateNoticeBoardViewController(club: club, firebaseManager: firebaseManager)
        
        // 네비게이션 백 버튼의 이름 설정
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        
        navigationController?.pushViewController(createNoticeBoardVC, animated: true)
    }
    
    @objc func moreAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let updateAction = UIAlertAction(title: "수정", style: .default) { _ in
            self.moveUpdateVC()
        }
        let removeClubAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.removeAler()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(updateAction)
        alertController.addAction(removeClubAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc private func removeAler() {
        let alertController = UIAlertController(title: "정말 모임을 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
        let outAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.removeClub()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(outAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func removeClub() {
        firebaseClubDatabaseManager.removeClub { isCompleted in
            if isCompleted { self.navigationController?.popViewController(animated: true) }
        }
    }
    
    @objc private func outAlert() {
        let alertController = UIAlertController(title: "정말 모임에서 탈퇴하시겠습니까?", message: nil, preferredStyle: .alert)
        let outAction = UIAlertAction(title: "탈퇴", style: .destructive) { _ in
            self.outClub()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(outAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func outClub() {
        guard let myUserSummary = MyProfile.shared.myUserInfo?.toUserSummary,
              let outUserIndex = self.firebaseClubDatabaseManager.model?.userList?.firstIndex(where: { $0.id == myUserSummary.id }) else { return }
        firebaseClubDatabaseManager.removeUser(user: myUserSummary) { isCompleted in
            if isCompleted {
                self.authState = .notMember
                self.homeVC.signUpButton.isHidden = false
                self.homeVC.memberTableView.beginUpdates()
                self.homeVC.memberTableView.deleteRows(at: [IndexPath(row: outUserIndex, section: 0)], with: .automatic)
                self.homeVC.memberTableView.endUpdates()
            }
        }
    }

    func moveUpdateVC() {
        let updateNoticeBoardVC = MeetingManageViewController(club: club, clubImage: clubImage)
        updateNoticeBoardVC.updateHandler = { [weak self] club, data in
            self?.homeVC.update(club: club, imageData: data)
        }

        // 네비게이션 백 버튼의 이름 설정
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        
        navigationController?.pushViewController(updateNoticeBoardVC, animated: true) // 모임 수정 페이지
    }
}

extension NoticeMeetingController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController?
    {
        if index == 1 {
            if authState == .notMember {
                showAlert()
                return nil
            }
            let createButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(moveCreateVC))
            navigationItem.rightBarButtonItem = createButton
        } else {
            updateNavigationItme()
        }
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        // return nil
        return .at(index: 0)
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
//        print("###", index)
        switch index {
        case 0:
            return TMBarItem(title: "홈")
        case 1:
            return TMBarItem(title: "게시판")
        default:
            let title = "Page \(index)"
            return TMBarItem(title: title)
        }
    }
}
