//
//  NoticeBoardCRUD.swift
//  IDo
//
//  Created by Junyoung_Hong on 2023/10/19.
//

import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Foundation
import UIKit


protocol FirebaseManagerDelegate: AnyObject {
    func reloadData()
    func updateComment(noticeBoardID: String, commentCount: String)
}

// completion을 escaping으로 바꾸기
// image URL 업로드

class FirebaseManager {
    weak var delegate: FirebaseManagerDelegate?

    var noticeBoards: [NoticeBoard] = []
    var club: Club
    var missSelectedImage: [UIImage] = []
    
    var isClubExists: Bool = true
    
    
    // 원본
    var selectedImage: [String: StorageImage] = [:]
    
    // 새로운 딕셔너리
    var newSelectedImage: [String: StorageImage] = [:]
    
    // 삭제 할 딕셔너리
    var removeSelecteImage: [StorageImage] = []
    //var updateImage: [UIImage] = []
    
    init(club: Club) {
        self.club = club
    }
    
    // MARK: - 데이터 저장

    func saveNoticeBoard(noticeBoard: NoticeBoard, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id)
        
        guard let noticeBoardDict = noticeBoard.dictionary else { return }
                
        ref.setValue(noticeBoardDict) { error, _ in
            if let error = error {
                print("Error saving notice board: \(error)")
                completion?(false)
            }
            else {
                print("Successfully saved notice board.")
                completion?(true)
            }
        }
    }
    
    // MARK: - 데이터 생성
    func createNoticeBoard(title: String, content: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("noticeBoards").child(club.id)
        let newNoticeBoardID = ref.childByAutoId().key ?? ""
        
        guard let currentUserID = MyProfile.shared.myUserInfo?.id else { return }
        guard let currentUserNickName = MyProfile.shared.myUserInfo?.nickName else { return }
        var currentUser = UserSummary(id: currentUserID, profileImagePath: nil, nickName: currentUserNickName)
        if let currentUserProfileURL = MyProfile.shared.myUserInfo?.profileImagePath {
            currentUser.profileImagePath = currentUserProfileURL
        }
        
        self.uploadImages(noticeBoardID: newNoticeBoardID, imageList: self.newSelectedImage) { success, imageURLs in
            if success {
                let createDate = Date().dateToString
                let newNoticeBoard = NoticeBoard(id: newNoticeBoardID, rootUser: currentUser, createDate: createDate, clubID: self.club.id, title: title, content: content, imageList: imageURLs ?? [], commentCount: "0")
                self.addNoticeBoardToClub(noticeBoard: newNoticeBoard)
                self.saveNoticeBoard(noticeBoard: newNoticeBoard) { success in
                    if success {
                        self.addMyNoticeBoard(noticeBoard: newNoticeBoard)
                        self.noticeBoards.insert(newNoticeBoard, at: 0)
                        DispatchQueue.main.async {
                            self.delegate?.reloadData()
                        }
                    }
                    completion(success)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func addNoticeBoardToClub(noticeBoard: NoticeBoard) {
        let clubRef = Database.database().reference().child(club.category).child("meetings").child(club.id).child("noticeBoardList")
        var noticeBoards = club.noticeBoardList ?? []
        let indexRef = clubRef.child("\(noticeBoards.count)")
        clubRef.updateChildValues(["\(noticeBoards.count)":noticeBoard.dictionary]) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            noticeBoards.append(noticeBoard)
            self.club.noticeBoardList = noticeBoards
        }
    }

    // MARK: - 데이터 읽기
    func readNoticeBoard(completion: @escaping (Bool) -> Void) {
        
        let ref = Database.database().reference().child("noticeBoards").child(club.id)
        
        ref.getData(completion: { (error, snapshot) in
            if let error = error {
                print("Error getting data: \(error)")
                completion(false)
                return
            }
            
            guard let value = snapshot?.value as? [String: Any] else {
                DispatchQueue.main.async {
                    self.delegate?.reloadData()
                }
                completion(false)
                return
            }
            
            var newNoticeBoards: [NoticeBoard] = DataModelCodable.decodingDataSnapshot(value: value)
            
            var myBlockList = MyProfile.shared.myUserInfo?.blockList ?? []
            myBlockList.forEach { blockUser in
                newNoticeBoards.removeAll(where: { $0.rootUser.id == blockUser.id })
            }
            self.noticeBoards = newNoticeBoards.sorted(by: { $0.createDate > $1.createDate })
            DispatchQueue.main.async {
                self.delegate?.reloadData()
            }
            completion(true)
        })
    }

    // MARK: - 데이터 업데이트
    func updateNoticeBoard(at index: Int, title newTitle: String, content newContent: String, completion: @escaping (Bool) -> Void) {
        if index >= 0, index < self.noticeBoards.count {
            var updatedNoticeBoard = self.noticeBoards[index]
            updatedNoticeBoard.title = newTitle
            updatedNoticeBoard.content = newContent
            
            var deleteStorageImage: [String] = []
            removeSelecteImage.forEach { storageImage in
                if selectedImage.contains(where: {$0.value.imageUID == storageImage.imageUID}) {
                
                    let path = "noticeBoards/\(club.id)/\(updatedNoticeBoard.id)/images/\(storageImage.imageUID)"
                    deleteStorageImage.append(path)
                }
            }
            deleteImage(noticeBoardID: updatedNoticeBoard.id, imagePaths: deleteStorageImage) { success in
                if success {
                    // 먼저 새로운 이미지를 업로드
                    self.uploadImages(noticeBoardID: updatedNoticeBoard.id, imageList: self.newSelectedImage) { success, newImageURLs in
                        if success {
                            // 기존 이미지 목록에 새로운 이미지 URL을 추가
                            updatedNoticeBoard.imageList = newImageURLs ?? []
                            // 업데이트된 게시글을 저장
                            self.saveNoticeBoard(noticeBoard: updatedNoticeBoard) { success in
                                if success {
                                    self.updateMyNoticeBoard(noticeBoard: updatedNoticeBoard)
                                    self.noticeBoards[index] = updatedNoticeBoard
                                    DispatchQueue.main.async {
                                        self.delegate?.reloadData()
                                    }
                                }
                                completion(success)
                            }
                        } else {
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func updateNoticeBoardCommentCount(noticeBoard: NoticeBoard) {
        let ref = Database.database().reference().child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id).child("commentCount")
        ref.setValue(noticeBoard.commentCount)
    }
    
    // MARK: - 데이터 삭제

    func deleteNoticeBoard(at index: Int, completion: @escaping (Bool) -> Void) {
        if index >= 0, index < self.noticeBoards.count {
            let noticeBoardID = self.noticeBoards[index].id
            let imagePaths = self.noticeBoards[index].imageList?.map { $0.savedImagePath } ?? []
            let ref = Database.database().reference().child("noticeBoards").child(noticeBoards[index].clubID).child(noticeBoardID)
            
            ref.removeValue { error, _ in
                if let error = error {
                    print("Error deleting notice board: \(error)")
                    completion(false)
                }
                else {
                    print("Successfully deleted notice board.")
                    self.deleteNoticeBoardToClub(noticeBoard: self.noticeBoards[index])
                    let noticeBoard = self.noticeBoards[index]
                    if let myUserInfo = MyProfile.shared.myUserInfo,
                       myUserInfo.id == noticeBoard.rootUser.id {
                        self.removeMyNoticeBoard(noticeBoard: self.noticeBoards[index])
                    } else {
                        self.removeNoticeBoard(removeNoticeBoard: self.noticeBoards[index])
                    }
                    self.deleteImage(noticeBoardID: self.noticeBoards[index].id, imagePaths: imagePaths) { success in
                        if success {
                            completion(true)
                        }
                    }
                    self.noticeBoards.remove(at: index)
                    DispatchQueue.main.async {
                        self.delegate?.reloadData()
                    }
                }
            }
        }
        else {
            completion(false)
        }
    }
    
    private func deleteNoticeBoardToClub(noticeBoard: NoticeBoard) {
        let clubRef = Database.database().reference().child(club.category).child("meetings").child(club.id).child("noticeBoardList")
        guard let noticeBoardIndex = club.noticeBoardList?.firstIndex(where: { $0.id == noticeBoard.id }) else { return }
        let indexRef = clubRef.child("\(noticeBoardIndex)")
        clubRef.updateChildValues(["\(noticeBoardIndex)": nil]) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    // MARK: - 이미지 업로드
    func uploadImages(noticeBoardID: String, imageList: [String: StorageImage], completion: @escaping (Bool, [NoticeBoardImagePath]?) -> Void) {
        let clubID = club.id
        let storageRef = Storage.storage().reference().child("noticeBoards").child(clubID).child(noticeBoardID).child("images")
        var imageURLs: [NoticeBoardImagePath] = []
        
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in imageList {
            dispatchGroup.enter()
            let ref = storageRef.child(image.imageUID)
            
            if let uploadData = image.savedImage.jpegData(compressionQuality: 0.5) {
                let metadata = StorageMetadata()
                metadata.customMetadata = ["index": String(index)]
                ref.putData(uploadData, metadata: metadata) { _, error in
                    if let error = error {
                        print("Failed to upload image:", error)
                    } else {
                        // fullPath 속성을 사용하여 참조 경로를 저장
                        let noticeBoardImagePath = NoticeBoardImagePath(imageUID: image.imageUID, savedImagePath: ref.fullPath)
                        imageURLs.append(noticeBoardImagePath)
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(imageURLs.count == imageList.count, imageURLs)
        }
    }
    
    // MARK: - 이미지 다운로드
//    func downloadImages(imagePaths: [String], completion: @escaping ([UIImage]?) -> Void) {
//        let storageRef = Storage.storage().reference()
////        var downloadedImages: [UIImage] = []
////        var imageDict: [String: UIImage] = [:]
//        
////        let sortedPaths = imagePaths.sorted()
//        let dispatchGroup = DispatchGroup()
//        
//        for index in 0..<imagePaths.count {
//            //dispatchGroup.enter()
//            let ref = storageRef.child(imagePaths[index])
//            
//            FBURLCache.shared.downloadURL(storagePath: ref.fullPath) { result in
//                switch result {
//                case .success(let image):
////                    imageDict[String(index)] = image
//                    self.selectedImage[String(index)] = image
//                    self.delegate?.reloadData()
//                case .failure(let error):
//                    print("이미지 다운로드 실패: \(error)")
//                }
//                //dispatchGroup.leave()
//            }
//        }
//        
//        // 모든 이미지를 가지고 난 후, 테이블 뷰 다시 그리기
//        
////        dispatchGroup.notify(queue: .main) {
////            for path in imagePaths {
////                if let image = imageDict[path] {
////                    downloadedImages.append(image)
////                }
////            }
////            
////            if !downloadedImages.isEmpty {
////                self.selectedImage = downloadedImages
////                self.delegate?.reloadData()
////            }
////            completion(downloadedImages.isEmpty ? nil : downloadedImages)
////        }
//    }
    
    // MARK: - 프로필 다운로드
    func getUserImage(referencePath: String?, imageSize: ImageSize, completion: @escaping(UIImage?) -> Void) {
        guard let referencePath else { return }
        let imageRefPath = Storage.storage().reference().child(referencePath).child(imageSize.rawValue).fullPath
        FBURLCache.shared.downloadURL(storagePath: imageRefPath) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - 이미지 삭제
    func deleteImage(noticeBoardID: String, imagePaths: [String], completion: @escaping (Bool) -> Void) {
//        let storageRef = Storage.storage().reference().child("noticeBoards").child(clubID).child(noticeBoardID).child("images")
        let storageRef = Storage.storage().reference()
        
        let dispatchGroup = DispatchGroup()
        
        for imagePath in imagePaths {
            dispatchGroup.enter()
            let ref = storageRef.child(imagePath)
            
            ref.delete { error in
                if let error = error {
                    print("이미지 삭제 중 오류 발생: \(error)")
                } else {
                    
                    print("이미지가 성공적으로 삭제되었습니다.")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(true)
        }
    }
    
    //MARK: - 내 정보에 게시판 추가
    func addMyNoticeBoard(noticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        guard var myInfo = MyProfile.shared.myUserInfo else { return }
        let ref = Database.database().reference().child("Users").child(myInfo.id)
        var noticeBoardList = [NoticeBoard]()
        if let myNoticeBoardList = myInfo.myNoticeBoardList {
            noticeBoardList = myNoticeBoardList
        }
        if noticeBoardList.contains(where: { $0.id == noticeBoard.id }) { return }
        noticeBoardList.insert(noticeBoard, at: 0)
        MyProfile.shared.update(myNoticeBoardList: noticeBoardList)
    }
    
    //MARK: - 내 정보에 게시판 추가
    func updateMyNoticeBoard(noticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        guard var myInfo = MyProfile.shared.myUserInfo else { return }
        let ref = Database.database().reference().child("Users").child(myInfo.id)
        var noticeBoardList = [NoticeBoard]()
        if let myNoticeBoardList = myInfo.myNoticeBoardList {
            noticeBoardList = myNoticeBoardList
        }
        guard let index = noticeBoardList.firstIndex(where: { $0.id == noticeBoard.id }) else { return }
        noticeBoardList[index] = noticeBoard
        MyProfile.shared.update(myNoticeBoardList: noticeBoardList)
    }
    
    //MARK: - 내 정보에 게시판 추가
    func removeMyNoticeBoard(noticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        guard var myInfo = MyProfile.shared.myUserInfo else { return }
        let ref = Database.database().reference().child("Users").child(myInfo.id)
        var noticeBoardList = [NoticeBoard]()
        if let myNoticeBoardList = myInfo.myNoticeBoardList {
            noticeBoardList = myNoticeBoardList
        }
        noticeBoardList.removeAll(where: { $0.id == noticeBoard.id })
        MyProfile.shared.update(myNoticeBoardList: noticeBoardList)
    }
    
    // MARK: 다른 사용자의 게시판 제거(신고로 인한 삭제시)
    func removeNoticeBoard(removeNoticeBoard: NoticeBoard, completion: (() -> Void)? = nil) {
        let ref = Database.database().reference().child("Users").child(removeNoticeBoard.rootUser.id).child("myNoticeBoardList")
        ref.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard dataSnapShot?.exists() != nil,
                  let values = dataSnapShot?.value as? [Any] else {
                print("사용자의 게시판 리스트가 존재하지 않습니다.")
                return
            }
            var noticeBoardList = [NoticeBoard]()
            values.forEach { value in
                if let noticeBoard: NoticeBoard = DataModelCodable.decodingSingleDataSnapshot(value: value) {
                    if noticeBoard.id == removeNoticeBoard.id { return }
                    noticeBoardList.append(noticeBoard)
                }
            }
            ref.setValue(noticeBoardList.asArrayDictionary())
        }
    }
    
    // MARK: - 신고 횟수 저장(noticeBoard에서 진행)
    func updateUserDeclarationCount(userID: String, declarationCount: Int, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child(club.category).child("meetings").child(club.id).child("userList")
        
        var userList = club.userList
        guard let index = userList?.firstIndex(where: { $0.id == userID}) else { return }
        userList?[index].declarationCount = declarationCount
        ref.setValue(userList?.asArrayDictionary()) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    // MARK: - Users에서 declarationCount 불러오기
    func getDeclarationCount(userID: String, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child(club.category).child("meetings").child(club.id).child("userList")
        
        ref.getData(completion: { (error, snapshot) in
            if let error = error {
                print("Error getting data: \(error)")
                completion?(false)
                return
            }
            else {
//                guard let userList =
                completion?(true)
            }
        })
    }
    
    //MARK: observe 클럽
    func observeClubUserList() {
        let club = self.club
        let clubRef = Database.database().reference().child(club.category).child("meetings").child(club.id).child("userList")
        clubRef.observe(.value) { dataSnapShot in
            print("update club")
            if dataSnapShot.exists() {
                guard dataSnapShot.exists(),
                      let values = dataSnapShot.value as? [Any] else {
                    print("club에 value가 존재하지 않습니다.")
                    return
                }
                self.isClubExists = true
                
                var userList: [UserSummary] = []
                values.forEach { value in
                    guard let user: UserSummary = DataModelCodable.decodingSingleDataSnapshot(value: value) else {
                        print("업데이트된 모임 맴버를 디코딩하지 못했습니다.")
                        return
                    }
                    userList.append(user)
                }
                self.club.userList = userList
            } else {
                self.isClubExists = false
            }
        }
    }
    
    func removeObserveClubUserList() {
        let club = self.club
        let ref = Database.database().reference().child(club.category).child("meetings").child(club.id)
        ref.removeAllObservers()
    }
}
