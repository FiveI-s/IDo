//
//  MyProfileViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit
import SnapKit

class MyProfileViewController: UIViewController {
    
    var profileImage = UIImageView()
    var profileName = UILabel()
    var choiceEnjoy = UITextView()
    let selfInfo = UILabel()
    var selfInfoDetail = UITextView()
    let writeMe = UILabel()
    var writeMeList = ["헬린이 멤버 구합니다","카본 낚시대 20만원선에서 추천 받아요"]
    var writeMeTableView = UITableView()
    
    func makeProfileImage() {
        profileImage.image = UIImage(systemName: "camera.circle.fill")
    }
    func makeProfileName() {
        profileName.text = "애라링"
        profileName.textColor = .black
        profileName.font = UIFont.headFont(.xSmall , weight: .semibold)
    }
    func makeChoiceEnjoy() {
        let firstText = "낚시/캠핑"
        let secondText = "맛집/여행"
        let thirdText = "운동/스포츠"
        let totalText = firstText + ",  " + secondText + ",  " + thirdText
        choiceEnjoy.text = totalText
        choiceEnjoy.textColor = UIColor(color: .borderSelected)
        choiceEnjoy.backgroundColor = UIColor(color: .contentBackground)
        choiceEnjoy.font = UIFont.bodyFont(.xSmall, weight:.semibold)
        choiceEnjoy.layer.cornerRadius = 10
        choiceEnjoy.textContainerInset = UIEdgeInsets(top: 9, left: 6, bottom: 8, right: 6)
    }
    func makeSelfInfo() {
        selfInfo.text = "자기소개"
        selfInfo.textColor = .black
        selfInfo.font = UIFont.bodyFont(.large, weight: .semibold)
    }
    func makeSelfInfoDetail() {
        selfInfoDetail.font = UIFont.bodyFont(.medium, weight: .regular)
        selfInfoDetail.text = "안녕하세요. 이애라입니다."
        selfInfoDetail.textColor = UIColor(named: "ui-text-strong")
        selfInfoDetail.backgroundColor = UIColor(color: .backgroundSecondary)
        selfInfoDetail.layer.cornerRadius = 10
        selfInfoDetail.textContainerInset = UIEdgeInsets(top: 9, left: 8, bottom: 0, right: 9)
    }
    func makeWriteMe() {
        writeMe.text = "작성한 글"
        writeMe.textColor = .black
        writeMe.font = UIFont.bodyFont(.large, weight: .semibold)
    }
    func makeWriteMeTableView() {
        writeMeTableView.register(CategoryCell.self, forCellReuseIdentifier: "Cell")
        writeMeTableView.dataSource = self
        writeMeTableView.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makeProfileImage()
        makeProfileName()
        makeChoiceEnjoy()
        makeSelfInfo()
        makeSelfInfoDetail()
        makeWriteMe()
        makeWriteMeTableView()
        setLayout()
        selfInfoDetail.delegate = self
    }
    func setLayout() {
        view.addSubview(profileImage)
        view.addSubview(profileName)
        view.addSubview(choiceEnjoy)
        view.addSubview(selfInfo)
        view.addSubview(selfInfoDetail)
        view.addSubview(writeMe)
        view.addSubview(writeMeTableView)
        
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(110)
            make.left.equalToSuperview().offset(150)
            make.width.height.equalTo(100)
        }
        profileName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(170)
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
        choiceEnjoy.snp.makeConstraints { make in
            make.top.equalTo(profileName.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(100)
            make.width.equalTo(50)
            make.height.equalTo(35)
        }
        selfInfo.snp.makeConstraints { make in
            make.top.equalTo(choiceEnjoy.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
        }
        selfInfoDetail.snp.makeConstraints { make in
            make.top.equalTo(selfInfo.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(30)
            make.width.equalTo(330)
            make.height.equalTo(130)
        }
        writeMe.snp.makeConstraints { make in
            make.top.equalTo(selfInfoDetail.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
        }
        writeMeTableView.snp.makeConstraints { make in
            make.top.equalTo(writeMe.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
    }
}
extension MyProfileViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let chagedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == selfInfoDetail {
            return chagedText.count <= 299
        }
        return true
    }
}


extension MyProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return writeMeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategoryCell
        if tableView == writeMeTableView {
            cell.label.text = writeMeList[indexPath.row]
        }
        cell.categoryImageView.image = UIImage(systemName: "photo")
        return cell
    }
}
