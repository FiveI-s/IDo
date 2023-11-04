////
////  ViewController.swift
////  IDo
////
////  Created by Junyoung_Hong on 2023/10/10.
////
///
import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HomeViewController : UIViewController {
    
    let suggestClub = UILabel()
    let line = UIView()
    let suggestClubList = "종로 맛집 모임"
    var suggestClubInfo = "종로 맛집 공유 목적. 어서오세요"
    var suggestClubMember = "멤버 318"
    var suggestTableView = UITableView()
    
    let joinClub = UILabel()
    let line2 = UIView()
    var joinClubTableView = UITableView()
    
    let homeEmptyView = HomeEmptyView()
    
    var myClubList = MyProfile.shared.myUserInfo?.myClubList ?? []
    
    var currentUserClublImage: UIImage?
    
    func makeSuggestClub() {
        suggestClub.text = "이런 모임은 어떠신가요?"
        suggestClub.textColor = UIColor(color: .textStrong)
        suggestClub.font = .bodyFont(.large, weight: .bold)
    }
    func makeLine() {
        line.backgroundColor = UIColor(color: .textStrong)
    }
    func makeTableView() {
        suggestTableView.register(BasicCell.self, forCellReuseIdentifier: "Cell")
        suggestTableView.dataSource = self
        suggestTableView.delegate = self
        suggestTableView.separatorStyle = .none
        suggestTableView.rowHeight = UITableView.automaticDimension
        suggestTableView.isScrollEnabled = false
    }
    func makeLine2() {
        line2.backgroundColor = UIColor(color: .placeholder)
    }
    func makeJoinClub() {
        joinClub.text = "가입한 모임"
        joinClub.textColor = UIColor(color: .textStrong)
        joinClub.font = .bodyFont(.large, weight: .bold)
    }
    func makeTableView2() {
        joinClubTableView.register(BasicCell.self, forCellReuseIdentifier: "Cell")
        joinClubTableView.dataSource = self
        joinClubTableView.delegate = self
        joinClubTableView.separatorInset.left = 20
        joinClubTableView.separatorInset.right = 20
        joinClubTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeJoinClub()
        self.makeSuggestClub()
        self.makeLine()
        self.makeLine2()
        self.makeTableView()
        self.HomeViewTopControllerSet()
        self.navigationBar()
        self.updateUIBasedOnData()
        self.makeTableView2()
        self.setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        getUserClubList(userID: MyProfile.shared.myUserInfo!.id)
        updateUIBasedOnData()
        joinClubTableView.reloadData()
    }
    
    func setLayout() {
        view.addSubview(joinClub)
        //view.addSubview(suggestClub)
        //view.addSubview(line)
        view.addSubview(line2)
        view.addSubview(joinClubTableView)
        //view.addSubview(suggestTableView)
        view.addSubview(homeEmptyView)
        
//        suggestClub.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
//            make.leading.equalToSuperview().offset(Constant.margin4)
//        }
//        line.snp.makeConstraints { make in
//            make.top.equalTo(suggestClub.snp.bottom).offset(Constant.margin2)
//            make.leading.equalToSuperview().offset(Constant.margin4)
//            make.trailing.equalToSuperview().offset(-Constant.margin4)
//            make.height.equalTo(1)
//        }
//        suggestTableView.snp.makeConstraints { make in
//            make.top.equalTo(line.snp.bottom)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(78)
//        }
        
        joinClub.snp.makeConstraints { make in
//            make.top.equalTo(suggestTableView.snp.bottom).offset(Constant.margin4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.leading.equalToSuperview().offset(Constant.margin4)
        }
        line2.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(Constant.margin2)
            make.leading.equalToSuperview().offset(Constant.margin4)
            make.trailing.equalToSuperview().offset(-Constant.margin4)
            make.height.equalTo(1)
        }
        joinClubTableView.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        homeEmptyView.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func updateUIBasedOnData() {
        guard let currentUserClubList = MyProfile.shared.myUserInfo?.myClubList else {
            print("사용자 정보가 없습니다")
            return
        }
        if currentUserClubList.count == 0 {
            homeEmptyView.isHidden = false
            joinClubTableView.isHidden = true
        } else {
            homeEmptyView.isHidden = true
            joinClubTableView.isHidden = false
        }
    }
    
    func getUserClubImage(referencePath: String, imageSize: ImageSize, completion: ((UIImage) -> Void)? = nil) {
        // 카테고리 -> meetings_images -> referencePath
        let storageRef = Storage.storage().reference().child(referencePath)
        FBURLCache.shared.downloadURL(storagePath: storageRef.fullPath) { result in
            switch result {
            case .success(let image):
                completion?(image)
            case .failure(let error):
                print("이미지 다운로드 실패: \(error)")
            }
        }
    }
}


extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == suggestTableView {
            return 1
        }
    
        return MyProfile.shared.myUserInfo?.myClubList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        if tableView == suggestTableView {
            // 현재 유저가 선택한 카테고리에 접근 -> 해당 카테고리에 있는 클럽 보여주기
            cell.titleLabel.text = suggestClubList
            cell.aboutLabel.text = suggestClubInfo
            cell.memberLabel.text = suggestClubMember
        } else {
            guard let currentUserClubList = MyProfile.shared.myUserInfo?.myClubList else {
                print("현재 내 클럽이 없습니다.")
                return cell
            }
            cell.titleLabel.text = currentUserClubList[indexPath.row].title
            cell.aboutLabel.text = currentUserClubList[indexPath.row].description
            cell.memberLabel.text = "멤버 \((currentUserClubList[indexPath.row].userList?.count ?? 0) + 1)"
            
            guard let imageReferencePath = currentUserClubList[indexPath.row].imageURL else { return cell }
            getUserClubImage(referencePath: imageReferencePath, imageSize: .medium) { image in
                cell.basicImageView.image = image
            }

        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUserClubList = MyProfile.shared.myUserInfo?.myClubList,
            let clubImagePath = currentUserClubList[indexPath.row].imageURL else { return }
        getUserClubImage(referencePath: clubImagePath, imageSize: .medium) { image in
            let noticeBoardVC = NoticeMeetingController(club: currentUserClubList[indexPath.row], currentUser: MyProfile.shared.myUserInfo!, clubImage: image)
            self.navigationController?.pushViewController(noticeBoardVC, animated: true)
        }
    }
}

private extension HomeViewController {
    
    func HomeViewTopControllerSet() {
        
        // 네비게이션 LargeTitle 비활성화 및 title 입력
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    func navigationBar() {
        
        // 네비게이션 라벨 생성
        let label = UILabel()
        label.text = "i들아 모여라"
        label.font = UIFont.headFont(.xSmall , weight: .bold)
        label.textColor = UIColor(color: .borderSelected)
        let containerView = UIView(); containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7) // 또는 적절한 값을 사용
            make.top.bottom.trailing.equalToSuperview()
        }
        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
}
