import UIKit
import SnapKit


class MeetingProfileImageButton: UIButton {
    
    var profileImageChanged: Bool = false
    
    private let plusIconLabel: UILabel = {
        let label = UILabel()
        label.text = "+"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = .blue
        label.textAlignment = .center
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "대표 사진"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(plusIconLabel)
                addSubview(textLabel)
                
                plusIconLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(-10)
                }
                
        textLabel.snp.makeConstraints { make in
                    make.top.equalTo(plusIconLabel.snp.bottom).offset(4)
                    make.centerX.equalToSuperview()
                }
        
        self.layer.cornerRadius = 24
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    // 이미지 선택
    func openImagePicker(in viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .photoLibrary
        viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
            super.setImage(image, for: state)
            updateVisibilityOfLabels(hide: image != nil)
        }
        
    private func updateVisibilityOfLabels(hide: Bool) {
            plusIconLabel.isHidden = hide
            textLabel.isHidden = hide
        }
    
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
        func resizedAndRoundedImage() -> UIImage? {
            let imageWidth = UIScreen.main.bounds.width-40
            let desiredAspectRatio: CGFloat = 3.0 / 4.0
            let imageHeight = imageWidth * desiredAspectRatio
            
            let targetSize = CGSize(width: imageWidth, height: imageHeight)
            let cornerRadius: CGFloat = 24.0

            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
            
            let rect = CGRect(origin: CGPoint.zero, size: targetSize)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            path.addClip()
            
            self.draw(in: rect)

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resultImage
        }
}
