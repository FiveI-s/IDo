//
//  NoticeMeetingController.swift
//  IDo
//
//  Created by t2023-m0053 on 2023/10/12.
//

import Pageboy
import Tabman
import UIKit

class NoticeMeetingController: TabmanViewController {
    private var viewControllers: [UIViewController] = []
    private var tempView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tempView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        view.addSubview(tempView)
        tempView.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(30)
        }
        let HomeVC = NoticeHomeController()
        let titleVC = NoticeBoardViewController()

        viewControllers.append(HomeVC)
        viewControllers.append(titleVC)

        dataSource = self

        let bar = TMBar.ButtonBar()
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        addBar(bar, dataSource: self, at: .custom(view: tempView!, layout: nil))
    }
}

extension NoticeMeetingController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController?
    {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        // return nil
        return .at(index: 0)
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "홈")
        case 1:
            return TMBarItem(title: "게시판")
        default:
            let title = "Page \(index)"
            return TMBarItem(title: title)
        }
    }
}
