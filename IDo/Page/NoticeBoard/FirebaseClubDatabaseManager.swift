//
//  FirebaseNoticeBoardManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/19.
//

import FirebaseDatabase
import FirebaseStorage
import Foundation

class FirebaseClubDatabaseManager: FBDatabaseManager<Club> {
    func removeClub(completion: ((Bool) -> Void)?) {
        guard let club = model else { return }
        ref.removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            self.removeUserClub(user: club.rootUser, club: club)
            self.removeNoticeBoard(club: club)
            if let imagePath = club.imageURL {
                self.removeImage(path: imagePath)
            }
            completion?(true)
        }
    }
    private func removeNoticeBoard(club: Club) {
        let ref = Database.database().reference().child("noticeBoards").child(club.id)
        let noticeBoards = club.noticeBoardList
        ref.removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let noticeBoards else { return }
            noticeBoards.forEach { noticeBoard in
                self.removeUserNoticeBoard(user: noticeBoard.rootUser, noticeBoard: noticeBoard)
                self.removeComment(noticeBoard: noticeBoard)
                noticeBoard.imageList?.compactMap{ self.removeImage(path: $0) }
            }
        }
    }
    private func removeComment(noticeBoard: NoticeBoard) {
        let ref = Database.database().reference().child("CommentList").child(noticeBoard.id)
        ref.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? [String : Any] else { return }
            let commentList: [Comment] = DataModelCodable.decodingDataSnapshot(value: value)
            commentList.forEach { comment in
                let writeUser = comment.writeUser
                self.removeUserComment(user: writeUser, comment: comment)
            }
            ref.removeValue { error, _ in
                if let error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    private func removeUserClub(user: UserSummary, club: Club) {
        let ref = Database.database().reference().child("Users").child(user.id)
        let userClubListRef = ref.child("myClubList")
        userClubListRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? Array<Any> else { return }
            var userClubList = [Club]()
            value.forEach { dict in
                if let club: Club = DataModelCodable.decodingSingleDataSnapshot(value: dict) {
                    userClubList.append(club)
                }
            }
            userClubList.removeAll(where: { $0.id == club.id })
            ref.updateChildValues(["myClubList": userClubList.dictionary])
        }
    }
    private func removeUserNoticeBoard(user: UserSummary, noticeBoard: NoticeBoard) {
        let ref = Database.database().reference().child("Users").child(user.id)
        let userNoticeBoardListRef = ref.child("myNoticeBoardList")
        userNoticeBoardListRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? Array<Any> else { return }
            var userNoticeBoardList = [NoticeBoard]()
            value.forEach { dict in
                if let noticeBoard: NoticeBoard = DataModelCodable.decodingSingleDataSnapshot(value: dict) {
                    userNoticeBoardList.append(noticeBoard)
                }
            }
            userNoticeBoardList.removeAll(where: { $0.id == noticeBoard.id })
            ref.updateChildValues(["myNoticeBoardList" : userNoticeBoardList.dictionary])
        }
    }
    private func removeUserComment(user: UserSummary ,comment: Comment) {
        let ref = Database.database().reference().child("Users").child(user.id)
        let userCommentListRef = ref.child("myCommentList")
        userCommentListRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? Array<Any> else { return }
            var userCommentList = [Comment]()
            value.forEach { dict in
                if let comment: Comment = DataModelCodable.decodingSingleDataSnapshot(value: dict) {
                    userCommentList.append(comment)
                }
            }
            userCommentList.removeAll(where: { $0.id == comment.id })
            ref.updateChildValues(["myCommentList" : userCommentList.dictionary])
        }
    }
    private func removeImage(path: String) {
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.delete { error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    func appendUser(user: UserSummary, completion: ((Bool) -> Void)? = nil) {
        guard let model else { return }
        var userList = model.userList ?? []
        userList.append(user)
        ref.updateChildValues(["userList":userList.asArrayDictionary()]){ error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            completion?(true)
        }
    }
    
    func removeUser(user: UserSummary, completion: ((Bool) -> Void)? = nil) {
        guard let model,
              var userList = model.userList else { return }
        userList.removeAll(where: { $0.id == user.id })
        ref.updateChildValues(["userList":userList.asArrayDictionary()]) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            completion?(true)
        }
    }
}