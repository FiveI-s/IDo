//
//  CurrentUser.swift
//  IDo
//
//  Created by 김도현 on 2023/10/26.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

final class MyProfile {
    
    static let shared = MyProfile()
    private var firebaseManager: FBDatabaseManager<IDoUser>!
    private var fileCache: ProfileImageCache = ProfileImageCache()
    var myUserInfo: MyUserInfo?
    
    private init() {}
    
    func getUserProfile(uid: String, completion: ((Bool) -> Void)? = nil) {
        firebaseManager = FBDatabaseManager(refPath: ["Users",uid])
        //MARK: 데이터가 바꼈는지 체크하는 부분 로직 생각해보기
//        if let currentUser = fileCache.getFile(uid: uid) {
//            self.myUserInfo = currentUser
//            completion?(true)
//            return
//        }
        firebaseManager.readData { result in
            switch result {
            case .success(let idoUser):
//                if let currentUpdateAt = self.myUserInfo?.updateAt,
//                   let serverUpdateAt = idoUser.updateAt {
//                    if currentUpdateAt >= serverUpdateAt {
//                        completion?(true)
//                        return
//                    }
//                }
                self.myUserInfo = idoUser.toMyUserInfo
                if let profilePath = idoUser.profileImagePath {
                    self.loadImage(defaultPath: profilePath, paths: ImageSize.allCases)
                    completion?(true)
                    return
                }
            case .failure(let error):
                completion?(false)
                print(error.localizedDescription)
            }
        }
    }
    
    func loadImage(defaultPath: String, paths: [ImageSize], completion: (() -> Void)? = nil) {
        let defaultStorageRef = Storage.storage().reference().child(defaultPath)
        paths.forEach { path in
            let storageRefPath = defaultStorageRef.child(path.rawValue).fullPath
            FBURLCache.shared.downloadURL(storagePath: storageRefPath) { result in
                switch result {
                case .success(let image):
                    self.myUserInfo?.profileImage[path.rawValue] = image.pngData()
                    guard let myUserInfo = self.myUserInfo else { return }
                    self.fileCache.storeFile(myUserInfo: myUserInfo)
                    completion?()
                case .failure(let error):
                    print(error.localizedDescription)
                    completion?()
                }
            }
        }
    }
    
    func saveMyUserInfo(myUserInfo: MyUserInfo) {
        self.myUserInfo = myUserInfo
        fileCache.storeFile(myUserInfo: myUserInfo)
    }
    
    func update(nickName: String? = nil, updateProfileImage: UIImage? = nil, description: String? = nil, myClubList: [Club]? = nil, hobbyList: [String]? = nil, myNoticeBoardList: [NoticeBoard]? = nil, myCommentList: [Comment]? = nil, completion: ((Bool) -> Void)? = nil) {
        var myInfo = self.myUserInfo
        if let nickName {
            myInfo?.nickName = nickName
        }
        if let updateProfileImage {
            let smallImage = updateProfileImage.resizeImage(targetSize: CGSize(width: 90, height: 90))
            let mediumImage = updateProfileImage.resizeImage(targetSize: CGSize(width: 480, height: 480))
            if let smallImageData = smallImage.pngData(),
               let mediumImageData = mediumImage.pngData() {
                myInfo?.profileImage[ImageSize.small.rawValue] = smallImageData
                myInfo?.profileImage[ImageSize.small.rawValue] = mediumImageData
                uploadProfileImage(imageData: smallImageData, imageSize: .small)
                uploadProfileImage(imageData: mediumImageData, imageSize: .medium)
            }
        }
        if let description {
            myInfo?.description = description
        }
        if let myClubList {
            myInfo?.myClubList = myClubList
        }
        if let hobbyList {
            myInfo?.hobbyList = hobbyList
        }
        if let myNoticeBoardList {
            myInfo?.myNoticeBoardList = myNoticeBoardList
        }
        if let myCommentList {
            myInfo?.myCommentList = myCommentList
        }
        guard let idoUser = myInfo?.toIDoUser else { return }
        firebaseManager.updateValue(value: idoUser) { isCompletion in
            if isCompletion {
                completion?(isCompletion)
                self.myUserInfo = myInfo
            }
        }
    }
    
    private func uploadProfileImage(imageData: Data, imageSize: ImageSize) {
        guard let uid = myUserInfo?.id else {
            print("uid가 존재하지 않아 이미지 저장에 실패하였습니다")
            return
        }
        let storageRef = Storage.storage().reference().child("UserProfileImages/\(uid)/\(imageSize.rawValue)")
        storageRef.putData(imageData) { _, error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
}


