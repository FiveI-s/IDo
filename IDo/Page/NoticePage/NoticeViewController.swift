//
//  NoticeViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit

class NoticeViewController: UIViewController {
    let noticeTitle = ["제목입니다"]
    let noticeComments = ["누구님의 게시글에 댓글을 달았습니다."]
    let noticeDate = ["2023.10.11 오후 10:01"]
    let noticeImage = UIImage(systemName: "camera.circle")
    private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)

        tableView.register(NoticeCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constant.margin3)
        }
    }
}

extension NoticeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NoticeCell
        cell.label.text = noticeTitle[indexPath.row]
        cell.commentsLabel.text = noticeComments[indexPath.row]
        cell.dataLable.text = noticeDate[indexPath.row]
        cell.categoryImageView.image = noticeImage
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
