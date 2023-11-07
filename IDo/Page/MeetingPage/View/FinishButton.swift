import UIKit

class FinishButton: UIButton {

    // 내부 글자 설정
    init(title: String = "생성하기") {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.bodyFont(.large, weight: .medium)
        self.backgroundColor = UIColor(color: .contentPrimary)
        self.setTitleColor(UIColor(color: .white), for: .normal)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.addTarget(self, action: #selector(showDebug), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func showDebug() {
        print("버튼누름")
    }
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? UIColor(color: .contentPrimary) : UIColor(color: .contentDisable)
        }
    }
}
