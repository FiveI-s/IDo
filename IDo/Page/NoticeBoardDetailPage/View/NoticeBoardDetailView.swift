//
//  NoticeBoardView.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import Foundation
import UIKit

final class NoticeBoardDetailView: UIStackView {
    
    private let writerInfoView: WriterStackView = WriterStackView()
    private let contentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .bold)
        label.text = "제목 입니다."
        label.numberOfLines = 0
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    private let contentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont(.medium, weight: .regular)
        label.text = """
                    텍스트 입니다
                    텍스트 입니다.
                    텍스트 입니다
                    텍스트 입니다.
                    """
        label.numberOfLines = 0
        label.textColor = UIColor(color: .textStrong)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension NoticeBoardDetailView {
    private func setup() {
        stackViewSetup()
        addViews()
    }
    private func stackViewSetup() {
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = 12
    }
    private func addViews() {
        addArrangedSubview(writerInfoView)
        addArrangedSubview(contentTitleLabel)
        addArrangedSubview(contentDescriptionLabel)
    }
}
