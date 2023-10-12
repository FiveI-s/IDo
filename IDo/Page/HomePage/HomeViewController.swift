////
////  ViewController.swift
////  IDo
////
////  Created by Junyoung_Hong on 2023/10/10.
////
///
import UIKit
import SnapKit

class HomeViewController : UIViewController {
    let joinClub = UILabel()
    let line = UIView()
    let joinClubList = ["신림 헬린이 모여라", "동대문구 배드민턴 모임"]
    var tableView = UITableView()
    
    let suggestClub = UILabel()
    let line2 = UIView()
    let suggestClubList = ["종로 맛집 모임", "판교 앱개발 모임"]
    var tableView2 = UITableView()
    
    func makeJoinClub() {
        joinClub.text = "가입한 모임"
        joinClub.textColor = .black
        joinClub.font = .headFont(.small, weight: .regular)
    }
    func makeLine() {
        line.backgroundColor = .black
    }
    func makeLine2() {
        line2.backgroundColor = .black
    }
    func makeSuggestClub() {
        suggestClub.text = "추천 모임"
        suggestClub.textColor = .black
        suggestClub.font = .headFont(.small, weight: .regular)
    }
    func makeTableView() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    func makeTableView2() {
        tableView2.register(CategoryCell.self, forCellReuseIdentifier: "Cell")
        tableView2.dataSource = self
        tableView2.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeJoinClub()
        makeSuggestClub()
        makeLine()
        makeLine2()
        makeTableView()
        makeTableView2()
        setLayout()
    }
    func setLayout() {
        view.addSubview(joinClub)
        view.addSubview(suggestClub)
        view.addSubview(line)
        view.addSubview(line2)
        view.addSubview(tableView)
        view.addSubview(tableView2)
        
        joinClub.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(20)
        }
        suggestClub.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(280)
            make.left.equalToSuperview().offset(20)
        }
        line.snp.makeConstraints { make in
            make.top.equalTo(joinClub.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(350)
            make.height.equalTo(1)
        }
        line2.snp.makeConstraints { make in
            make.top.equalTo(suggestClub.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(350)
            make.height.equalTo(1)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        tableView2.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinClubList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategoryCell
        cell.label.text = joinClubList[indexPath.row]
        cell.categoryImageView.image = UIImage(named: "MeetingProfileImage")
        return cell
    }
}
