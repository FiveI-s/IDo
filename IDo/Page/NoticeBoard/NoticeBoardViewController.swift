//
//  NoticeBoardViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit

class NoticeBoardViewController: UIViewController {
    
    private let noticeBoardView = NoticeBoardView()
    
    override func loadView() {
        view = noticeBoardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation 관련 함수
        navigationControllerSet()
        navigationBarButtonAction()
        
        noticeBoardView.noticeBoardTableView.delegate = self
        noticeBoardView.noticeBoardTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noticeBoardView.noticeBoardTableView.reloadData()
    }

}

// Navigation 관련 extension
private extension NoticeBoardViewController {
    
    func navigationControllerSet() {
        
        // 네비게이션 LargeTitle 비활성화 및 title 입력
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Team.첫사랑(하늬바람)"
    }
    
    func navigationBarButtonAction() {
        
        // 네비게이션 오른쪽 버튼 생성
        let createButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(moveCreateVC))
        self.navigationItem.rightBarButtonItems = [ createButton ]
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(color: .main)
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = UIColor(color: .main)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // 메모 생성 페이지 이동
    @objc func moveCreateVC() {
        let createNoticeBoardVC = CreateNoticeBoardViewController()
        navigationController?.pushViewController(createNoticeBoardVC, animated: true)
    }
}

extension NoticeBoardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeBoardTableViewCell.identifier, for: indexPath) as? NoticeBoardTableViewCell else { return UITableViewCell() }
        
        return cell
    }
}
