//
//  BlockListViewController.swift
//  IDo
//
//  Created by 김도현 on 2023/11/17.
//

import UIKit

class BlockListViewController: UIViewController {
    
    private let blockListTableView: UITableView = {
        let tableview = UITableView()
        tableview.rowHeight = 36 + 8 + 8
        tableview.separatorStyle = .none
        return tableview
    }()
    private let emptyMessageView: EmptyMessageStackView = EmptyMessageStackView(messageType: .noMember)
    private var isEmpty: Bool = false {
        didSet {
            emptyMessageView.isHidden = !isEmpty
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isEmpty = MyProfile.shared.myUserInfo?.blockList?.isEmpty ?? true
        blockListTableView.reloadData()
    }

}

private extension BlockListViewController {
    func setup() {
        setupNavigation()
        addViews()
        setupAutoLayout()
        setupTableView()
    }
    
    func addViews() {
        view.addSubview(blockListTableView)
        view.addSubview(emptyMessageView)
    }
    
    func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        blockListTableView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeArea).inset(Constant.margin3)
            make.horizontalEdges.equalTo(safeArea).inset(Constant.margin4)
        }
        
        emptyMessageView.snp.makeConstraints { make in
            make.center.equalTo(safeArea)
        }
    }
    
    func setupTableView() {
        blockListTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.identifier)
        blockListTableView.delegate = self
        blockListTableView.dataSource = self
    }
    
    func setupNavigation() {
        if let navigationBar = navigationController?.navigationBar {
            NavigationBar.setNavigationTitle(for: navigationItem, in: navigationBar, title: "차단 목록")
        }
    }
}

extension BlockListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyProfile.shared.myUserInfo?.blockList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCell.identifier, for: indexPath) as? MemberTableViewCell,
              let userList = MyProfile.shared.myUserInfo?.blockList else { return UITableViewCell() }
        cell.selectionStyle = .none
        let user = userList[indexPath.row]
        cell.nameLabel.text = user.nickName
        cell.descriptionLabel.text = user.description
        cell.profileImageView.imageView.image = nil
        cell.headImageView.isHidden = true
        cell.xmarkImageView.isHidden = false

        if let profilePath = user.profileImagePath {
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
        } else {
            if let defaultImage = UIImage(systemName: "person.fill") {
                cell.setUserImage(profileImage: defaultImage, color: UIColor(color: .contentBackground))
            }
        }

        cell.onImageTap = { [weak self] in
            self?.navigateToProfilePage(for: indexPath)
        }
        cell.onXmarkTap = { [weak self] in
            guard let indexPath = self?.blockListTableView.indexPath(for: cell) else { return }
            MyProfile.shared.removeBlockUser(blockUser: userList[indexPath.row]) {
                self?.blockListTableView.reloadData()
            }
        }

        return cell
    }
    
    func navigateToProfilePage(for indexPath: IndexPath) {
        if let userList = MyProfile.shared.myUserInfo?.blockList {
            let profile = userList[indexPath.row]
            PresentToProfileVC.presentToProfileVC(from: self, with: profile)
        }
    }
}
