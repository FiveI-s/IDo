//
//  CategoryViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import SnapKit
import UIKit

class CategoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        makeInstructions()
        makeLine()
        setLayout()
        
        selectCategoryCollectionView.delegate = self
        selectCategoryCollectionView.dataSource = self
//        setCollectionView()
        navigationBar()
    }
    // MARK: - 문구 및 구분선
    
    let instructions = UILabel()
    func makeInstructions() {
        DispatchQueue.main.async {
            guard let nickName = MyProfile.shared.myUserInfo?.nickName else { return }
            self.instructions.text = "\(nickName)님, 카테고리를 선택해보세요!"
        }
        instructions.textColor = UIColor(color: .textStrong)
        instructions.font = .bodyFont(.large, weight: .bold)
    }
    
    let line = UIView()
    func makeLine() {
        line.backgroundColor = UIColor(color: .placeholder)
    }
    
    func setLayout() {
        view.addSubview(instructions)
        view.addSubview(line)
        view.addSubview(selectCategoryCollectionView)
        
        instructions.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constant.margin3)
            make.leading.equalToSuperview().offset(Constant.margin4)
        }
        line.snp.makeConstraints { make in
            make.top.equalTo(instructions.snp.bottom).offset(Constant.margin2)
            make.leading.equalToSuperview().offset(Constant.margin4)
            make.trailing.equalToSuperview().offset(-Constant.margin4)
            make.height.equalTo(1)
        }
        selectCategoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(480)
        }
    }
    
    // MARK: - 카테고리 컬렉션 뷰
    let categoryData = ["IT•개발", "사진•영상", "음악•악기", "게임•오락", "여행•맛집", "댄스•공연", "동물•식물", "낚시•캠핑", "운동•스포츠"]
    let categoryImage = [UIImage(named: "develop"), UIImage(named: "photo"), UIImage(named: "music"), UIImage(named: "game"), UIImage(named: "travel"), UIImage(named: "dance"), UIImage(named: "animal"), UIImage(named: "fishing"), UIImage(named: "exercise")]

    private(set) lazy var selectCategoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: CategoryCollectionCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
//    private let categoryCollectionView: UICollectionView = {
//        let layout = UICollectionViewCompositionalLayout { (_: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//            // 아이템 크기
//
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .absolute(150))
//            // 셀의 사이즈
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            // 그룹 크기 ( 셀을 포함 )
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
//            group.interItemSpacing = .fixed(10) // 아이템 간 간격
//
//            // 섹션
//            let section = NSCollectionLayoutSection(group: group)
//            section.interGroupSpacing = 10 // 그룹 간 간격
//            // 안전 영역 인셋을 사용하여 적절한 간격을 결정합니다.
//
//            // 현재 애플리케이션의 화면 중 가장 위에 있는 화면을 찾습니다.
//            if let safeAreaInsets = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets {
//                section.contentInsets = NSDirectionalEdgeInsets(
//                    top: safeAreaInsets.top + 10,
//                    leading: safeAreaInsets.left + 10,
//                    bottom: safeAreaInsets.bottom + 10,
//                    trailing: safeAreaInsets.right + 10
//                )
//            } else {
//                // 안전 영역 인셋을 사용할 수 없는 경우 기본값으로 대체합니다.
//                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//            }
//
//            return section
//        }
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.allowsMultipleSelection = true
//
//        return collectionView
//    }()
//
//    func setCollectionView() {
//        categoryCollectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: CategoryCollectionCell.identifier)
//        categoryCollectionView.delegate = self
//        categoryCollectionView.dataSource = self
//        categoryCollectionView.isScrollEnabled = false
//
//        view.addSubview(categoryCollectionView)
//
//        categoryCollectionView.snp.makeConstraints { make in
//            make.centerX.equalTo(view.safeAreaLayoutGuide)
//            make.left.right.equalTo(view.safeAreaLayoutGuide)
//            make.top.equalTo(line.snp.bottom)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
//    }
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionCell.identifier, for: indexPath) as? CategoryCollectionCell else {
            fatalError()
        }
        cell.label.text = categoryData[indexPath.row]
        cell.categoryImageView.image = categoryImage[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categoryData[indexPath.row]
        let meetingsData = MeetingsData(category: selectedCategory)
        let meetingVC = MeetingViewController(meetingsData: meetingsData)

        // 백 버튼 아이템 생성 및 설정
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")

        TemporaryManager.shared.categoryData = selectedCategory

        navigationController?.pushViewController(meetingVC, animated: true)
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    // CollectionView Cell의 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 20) / 3, height: 140)
    }
    
    // 수평 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // 수직 간견
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

private extension CategoryViewController {
    
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
        
        // 백 버튼 아이템 생성 및 설정
        NavigationBar.setNavigationBackButton(for: navigationItem, title: "")
        
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
}
