//
//  MeetingViewController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/11.
//

import Foundation
import UIKit
import FirebaseDatabase

class MeetingViewController: UIViewController {
    let meetingImage = UIImage(systemName: "camera.circle")
    var meetingImageUrls: [String] = []
    var meetingTitle: [String] = []
    var meetingDate: [String] = []
    var categoryData: String?
    var categoryIndex: Int?
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFirebase()
        navigationController?.navigationBar.tintColor = UIColor.black
        setupNavigationBar()
        setupTableView()
        navigationItem()
        if let data = categoryData, // 카테고리 Index에 따른 제목 표시
           let index = categoryIndex,
           index < meetingTitle.count && index < meetingDate.count
        {
            navigationItem.titleView?.subviews.forEach { $0.removeFromSuperview() }
            navigationItem.titleView?.addSubview(createTitleLabel(with: data))
        }
    }

    private func createTitleLabel(with data: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "\(data)"
        titleLabel.textAlignment = .center

        return titleLabel
    }

    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = categoryData ?? ""
        titleLabel.textAlignment = .center

        navigationItem.titleView = titleLabel
    }
    
    func loadDataFromFirebase() {
        guard let category = categoryData else { return }
            
        let ref = Database.database().reference().child(category).child("meetings")
        
        ref.observe(.value) { [weak self] (snapshot) in
            
            var newTitles: [String] = []
            var newDates: [String] = []
            var newImageUrls: [String] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let title = dict["title"] as? String,
                   let description = dict["description"] as? String,
                   let imageUrl = dict["imageUrl"] as? String {
                    newTitles.append(title)
                    newDates.append(description)
                    newImageUrls.append(imageUrl)
                }
            }
            
            self?.meetingTitle = newTitles
            self?.meetingDate = newDates
            self?.meetingImageUrls = newImageUrls
            
            self?.tableView.reloadData()
        }
    }



    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BasicCell.self, forCellReuseIdentifier: "Cell")

        view.addSubview(tableView)
    }

    func navigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .done, target: self, action: #selector(setBtnTap))


        //        button.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        //        let noticeBoardVC = MeetingCreateViewController()
        //        navigationController?.pushViewController(noticeBoardVC, animated: true)

    }

    @objc
    func setBtnTap() {
        let createMeetingVC = MeetingCreateViewController()
        createMeetingVC.selectedCategory = self.categoryData
        navigationController?.pushViewController(createMeetingVC, animated: true)
        
        
    }

}

extension MeetingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BasicCell
        cell.titleLabel.text = meetingTitle[indexPath.row]
        cell.aboutLabel.text = meetingDate[indexPath.row]
        
        let imageUrl = meetingImageUrls[indexPath.row]
        
        if let cachedImage = ImageCache.shared.getImage(for: imageUrl) {
            cell.basicImageView.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: URL(string: imageUrl)!) { (data, _, _) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.basicImageView.image = image
                        ImageCache.shared.cacheImage(image, for: imageUrl)
                    }
                }
            }.resume()
        }
        
        return cell
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noticeBoardVC = NoticeMeetingController()
        noticeBoardVC.meetingIndex = indexPath.row
        noticeBoardVC.categoryData = self.categoryData
        navigationController?.pushViewController(noticeBoardVC, animated: true)
    }


}
