//
//  NoticeHomeController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import FirebaseAuth
import FirebaseDatabase
import SnapKit
import UIKit

final class NoticeHomeController: UIViewController {
    var signUpButtonUpdate: ((AuthState) -> Void)?
    private let firebaseClubDatabaseManager: FirebaseClubDatabaseManager
    private let clubImage: UIImage? = nil
    private let club: Club
    let memberTableView: IntrinsicTableView = {
        let tableview = IntrinsicTableView()
        tableview.rowHeight = 36 + 8 + 8
        tableview.isScrollEnabled = false
        tableview.separatorStyle = .none
        return tableview
    }()

    private let authState: AuthState
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.backgroundColor = UIColor(color: .contentBackground)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        return imageView
    }()
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.font = .headFont(.xSmall, weight: .bold)
        label.text = "[B.R.P] 보라매 런앤플레이"
        return label
    }()
    
    lazy var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = .bodyFont(.medium, weight: .regular)
        textLabel.numberOfLines = 0
        textLabel.text = "안녕하세요. 설명입니다. "
        textLabel.text = "안녕하세요. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다. 설명입니다.설명입니다. "
        return textLabel
    }()

    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가입하기", for: .normal)
        button.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(color: .contentPrimary)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 25
        return view
    }()
    
    init(club: Club, authState: AuthState, firebaseClubDataManager: FirebaseClubDatabaseManager) {
        self.club = club
        self.firebaseClubDatabaseManager = firebaseClubDataManager
        self.authState = authState
        super.init(nibName: nil, bundle: nil)
        
        let isClubMember = authState != .notMember
//        signUpButton.isHidden = isClubMember
        signUpButton.snp.updateConstraints { make in
            if isClubMember {
                make.height.equalTo(0)
            } else {
                make.height.equalTo(50)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadDataFromFirebase()
        firebaseClubDatabaseManager.readData { _ in
            DispatchQueue.main.async {
                self.memberTableView.reloadData()
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
        // 백 버튼 아이템 생성 및 설정
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //loadDataFromFirebase()
        super.viewWillAppear(animated)
    }
    
    @objc func handleSignUp() {
        signUpButton.isEnabled = false
        print("Sign Up button tapped!.")
        addUser()
    }
    
    // 탭해서 이미지 전체보기
    @objc func imageTapped() {
        if let image = imageView.image {
            let imageViewer = FullScreenImageViewer(image: image)
            imageViewer.modalPresentationStyle = .fullScreen
            present(imageViewer, animated: true, completion: nil)
        }
    }

    
    private func addUser() {
        guard let idoUser = MyProfile.shared.myUserInfo?.toIDoUser else {
            signUpButton.isEnabled = true
            return
        }
        firebaseClubDatabaseManager.appendUser(user: idoUser.toUserSummary) { isCompleted in
            if isCompleted {
//                self.signUpButton.isHidden = isCompleted
                self.signUpButton.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }
            let authState: AuthState = isCompleted ? .member : .notMember
            guard let count = self.firebaseClubDatabaseManager.model?.userList?.count else {
                self.signUpButton.isEnabled = true
                return
            }
            self.signUpButtonUpdate?(authState)
            self.memberTableView.beginUpdates()
            self.memberTableView.insertRows(at: [IndexPath(row: count - 1, section: 0)], with: .automatic)
            self.memberTableView.endUpdates()
            self.addMyClubList()
        }
    }
    
    private func addMyClubList() {
        guard let club = firebaseClubDatabaseManager.model else { return }
        var myClubList = MyProfile.shared.myUserInfo?.myClubList ?? []
        myClubList.append(club)
        MyProfile.shared.update(myClubList: myClubList)
    }

    func setup() {
        addViews()
        setupAutoLayout()
        setupTableView()
    }
    
    private func addViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        scrollStackViewContainer.addArrangedSubview(imageView)
        scrollStackViewContainer.addArrangedSubview(label)
        scrollStackViewContainer.addArrangedSubview(textLabel)
        scrollStackViewContainer.addArrangedSubview(memberTableView)
        view.addSubview(signUpButton)
    }
    
    private func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let desiredAspectRatio: CGFloat = 2.0 / 3.0
        imageView.snp.makeConstraints { make in
            make.right.equalTo(scrollStackViewContainer).inset(Constant.margin4)
            make.height.equalTo(imageView.snp.width).multipliedBy(desiredAspectRatio)
            make.centerX.equalToSuperview()
        }
           
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(safeArea.snp.top).inset(Constant.margin3)
            make.bottom.equalTo(signUpButton.snp.top).offset(Constant.margin3)
        }
        
        scrollStackViewContainer.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView.contentLayoutGuide).inset(Constant.margin4)
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(30)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width).inset(Constant.margin4)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.left.right.equalToSuperview().inset(Constant.margin4)
            make.bottom.equalTo(safeArea.snp.bottom).inset(20)
        }
    }
    
    private func setupTableView() {
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.identifier)
    }

    func loadDataFromFirebase() {
        label.text = club.title
        textLabel.text = club.description
        if let clubImage {
            imageView.image = clubImage
        } else {
            guard var imageURL = club.imageURL else { return }
            imageURL += "/\(ImageSize.medium.rawValue)"
            FBURLCache.shared.downloadURL(storagePath: imageURL) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func update(club: Club, imageData: Data) {
        DispatchQueue.main.async {
            self.label.text = club.title
            self.textLabel.text = club.description
            self.imageView.image = UIImage(data: imageData)
        }
    }
}

extension NoticeHomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firebaseClubDatabaseManager.model?.userList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return MemberListHeaderView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCell.identifier, for: indexPath) as? MemberTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        if let userList = firebaseClubDatabaseManager.model?.userList, let rootUser = firebaseClubDatabaseManager.model?.rootUser {
            let user = userList[indexPath.row]
            cell.nameLabel.text = user.nickName
            cell.descriptionLabel.text = user.description
            cell.profileImageView.imageView.image = nil
            cell.headImageView.isHidden = (user.id != rootUser.id)
            guard let profilePath = user.profileImagePath else {
                if let defaultImage = UIImage(systemName: "person.fill") {
                    cell.setUserImage(profileImage: defaultImage, color: UIColor(color: .contentBackground))
                }
                return cell }
            FBURLCache.shared.downloadURL(storagePath: profilePath + "/\(ImageSize.small.rawValue)") { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.setUserImage(profileImage: image, color: UIColor(color: .white), margin: 0)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard authState == .root,
              let user = firebaseClubDatabaseManager.model?.userList?[indexPath.row] else { return nil }
        let removeAction = UIContextualAction(style: .normal, title: "삭제") { _, _, _ in
            self.firebaseClubDatabaseManager.removeUser(user: user) { isCompleted in
                if isCompleted {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
        }
        removeAction.backgroundColor = UIColor(color: .negative)
        let config = UISwipeActionsConfiguration(actions: [removeAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
