import UIKit

class FinishButton: UIButton {

    // 내부 글자 설정
    init(title: String = "생성하기") {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: "Inter", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        self.backgroundColor = UIColor(named: "Sub")
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.addTarget(self, action: #selector(showDebug), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func showDebug() {
        print("버튼누름")
    }
}
