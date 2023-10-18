//
//  CategoryViewController.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/11.
//

import UIKit

class CategoryViewController: UITableViewController {
    let categoryData = ["IT•개발", "사진•영상", "음악•악기", "게임•오락", "여행•맛집", "댄스•공연", "동물•식물", "낚시•캠핑", "운동•스포츠"]
    let categoryImage = UIImage(systemName: "pencil.circle")

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(CategoryCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategoryCell
        cell.label.text = categoryData[indexPath.row]
        cell.categoryImageView.image = categoryImage
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택한 셀의 인덱스에 따라 다른 화면으로 전환
        switch indexPath.row {
        case 0 ... 9:
            let selectedCategory = categoryData[indexPath.row]

            let exampleVC = MeetingViewController()
            exampleVC.categoryData = selectedCategory
            

            navigationController?.pushViewController(exampleVC, animated: true)
        default:
            break
        }
    }
}
