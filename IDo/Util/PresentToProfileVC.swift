//
//  PresentToProfileVC.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/11/14.
//

import UIKit
import FirebaseStorage

class PresentToProfileVC {
    
    static let urlCache = FBURLCache.shared
    static let storage = Storage.storage().reference()
    
    static func presentToProfileVC(from presentingVC: UIViewController, with profile: UserSummary) {
        let profileViewController = MyProfileViewController()
        profileViewController.userProfile = profile
        
        // 이미지 로딩 로직
        if let profileImageURL = profile.profileImagePath {
            self.getUserImage(referencePath: profileImageURL, imageSize: .medium) { [weak profileViewController] downloadedImage in
                DispatchQueue.main.async {
                    if let image = downloadedImage {
                        profileViewController?.profileImage.setImage(image, for: .normal)
                    }
                }
            }
        } else {
            let defaultImage = UIImage(named: "profile") ?? UIImage(systemName: "person.fill")
            profileViewController.profileImage.setImage(defaultImage, for: .normal)
        }
        
        profileViewController.profileName.text = profile.nickName
        profileViewController.choiceEnjoyTextField.text = profile.hobbyList?.first
        profileViewController.selfInfoDetail.text = profile.description
        
        profileViewController.profileImage.isUserInteractionEnabled = true
        profileViewController.profileName.isEditable = false
        profileViewController.choicePickerView.isUserInteractionEnabled = false
        profileViewController.selfInfoDetail.isEditable = false
        profileViewController.logout.isHidden = true
        profileViewController.line.isHidden = true
        profileViewController.deleteID.isHidden = true
        
        presentingVC.present(profileViewController, animated: true, completion: nil)
    }
    
    static func getUserImage(referencePath: String?, imageSize: ImageSize, completion: @escaping(UIImage?) -> Void) {
        guard let referencePath = referencePath else { return }
        let imageRefPath = storage.child(referencePath).child(imageSize.rawValue).fullPath
        self.urlCache.downloadURL(storagePath: imageRefPath) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
