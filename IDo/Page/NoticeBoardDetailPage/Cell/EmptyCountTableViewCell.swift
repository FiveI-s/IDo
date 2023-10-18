//
//  EmptyCountTableViewCell.swift
//  IDo
//
//  Created by 김도현 on 2023/10/13.
//

import UIKit

protocol DataLoding {
    var errorView: EmptyMessageStackView { get }
    var lodingView: UIActivityIndicatorView { get }
    var loadedView: UIStackView { get }
    var viewState: ViewState { get set }
    
    func update()
}

extension DataLoding where Self: UIView {
    func update() {
        DispatchQueue.main.async {
            switch self.viewState {
            case .loading:
                self.lodingView.startAnimating()
                self.lodingView.isHidden = false
                self.errorView.isHidden = true
                self.loadedView.isHidden = true
            case .loaded:
                self.lodingView.stopAnimating()
                self.lodingView.isHidden = true
                self.errorView.isHidden = true
                self.loadedView.isHidden = false
            case .error(let isConnectedToInternet):
                self.lodingView.stopAnimating()
                self.lodingView.isHidden = true
                self.errorView.isHidden = false
                if isConnectedToInternet {
                    self.errorView.type = .custom(image: UIImage(systemName: "xmark"), title: "알수없는 에러", description: "잠시후 다시시도 해주세요")
                    self.errorView.setColor(color: UIColor(color: .negative))
                } else {
                    self.errorView.type = .networkError
                }
                self.loadedView.isHidden = true
            }
        }
    }
}

class EmptyCountTableViewCell: UITableViewCell, Reusable, DataLoding {
    
    
    var errorView: EmptyMessageStackView = EmptyMessageStackView(messageType: .networkError)
    var lodingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    var loadedView: UIStackView = UIStackView()
    var viewState: ViewState = .loading {
        didSet {
            update()
        }
    }
    private let emptyMessageView: EmptyMessageStackView = EmptyMessageStackView(messageType: .commentEmpty)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessage(image: UIImage?, imageSize: CGFloat = 60, title: String?, description: String?) {
        emptyMessageView.setImage(image: image)
        emptyMessageView.imageSize = imageSize
        emptyMessageView.titleLabel.text = title
        emptyMessageView.descriptionLabel.text = description
    }
    
}

private extension EmptyCountTableViewCell {
    func setup() {
        addViews()
        autoLayoutSetup()
    }
    func addViews() {
        contentView.addSubview(errorView)
        contentView.addSubview(lodingView)
        contentView.addSubview(loadedView)
        loadedView.addArrangedSubview(emptyMessageView)
    }
    func autoLayoutSetup() {
        errorView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
        
        loadedView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
        
        lodingView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(Constant.margin3)
            make.left.right.equalTo(contentView)
        }
    }
}
