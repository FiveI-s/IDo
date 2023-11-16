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
    func removeMyClub(completion: ((Bool) -> Void)?) {
        guard let club = model else { return }
        ref.removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            let userList = club.userList ?? []
            for user in userList {
                self.removeUserClub(user: user, removeClub: club)
            }
            self.removeNoticeBoard(club: club)
            if let imagePath = club.imageURL {
                self.removeImage(path: imagePath)
            }
            guard let myUserInfo = MyProfile.shared.myUserInfo else {
                print("사용자 정보가 없어 내 클럽을 지울 수 없습니다.")
                return
            }
            var myClubList = myUserInfo.myClubList ?? []
            myClubList.removeAll(where: { $0.id == club.id })
            MyProfile.shared.update(myClubList: myClubList) { _ in
                completion?(true)
            }
        }
    }
    
    func removeClub(club: Club, userList: [UserSummary] ,completion: ((Bool) -> Void)?) {
        let dispatchGroup = DispatchGroup()
        let clubRef = Database.database().reference().child(club.category).child("meetings").child(club.id)
        clubRef.removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            for user in userList {
                dispatchGroup.enter()
                self.removeUserClub(user: user, removeClub: club) { _ in
                    dispatchGroup.leave()
                }
            }
            self.removeNoticeBoard(club: club)
            if let imagePath = club.imageURL {
                dispatchGroup.enter()
                self.removeImage(path: imagePath) { _ in
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion?(true)
            }
        }
    }
    
    // 유저가 방출된 경우 클럽안에 모든 사용자들에 MyClubList에 방출된 회원 제외시키고,방출된 회원의 club안에 게시판, 댓글 삭제
    private func outUser(in club: Club, outUser: UserSummary, isBlock: Bool, completion: ((Bool) -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        var userList = club.userList ?? []
        userList.forEach { user in
            dispatchGroup.enter()
            self.removeOutUser(in: club, user: user, outUser: outUser) { _ in
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        removeOutUserNoticeBoard(in: club, outUser: outUser) { _ in
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        removeUserClub(user: outUser, removeClub: club) { _ in
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        removeOutUserMyCommentList(in: club, outUser: outUser) { _ in
            dispatchGroup.leave()
        }
        if isBlock { addBlackList(in: club, blockUser: outUser) }
        
        dispatchGroup.notify(queue: .main) {
            completion?(true)
        }
    }
    
    private func addBlackList(in club: Club, blockUser: UserSummary) {
        let ref = Database.database().reference(withPath: "\(club.category)/meetings/\(club.id)/blackList")
        var blackList = club.blackList ?? []
        blackList.append(blockUser)
        ref.setValue(blackList.asArrayDictionary())
    }
    
    // 클럽안에 있는 User들에게 Users 있는 각각의 유저마다 myClubList에 방출된 클럽맴버를 제거하는 메서드
    private func removeOutUser(in club: Club, user: UserSummary, outUser: UserSummary, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child("Users").child(user.id)
        
        ref.getData { error, currentData in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            if let data = currentData?.value as? [String: Any],
               var user: IDoUser = DataModelCodable.decodingSingleDataSnapshot(value: data) {
                if let clubIndex = user.myClubList?.firstIndex(where: { $0.id == club.id }) {
                    if user.id == outUser.id {
                        user.myClubList?.removeAll(where: { $0.id == club.id })
                    } else if var userList = user.myClubList![clubIndex].userList {
                        userList.removeAll(where: { $0.id == outUser.id })
                        user.myClubList?[clubIndex].userList = userList
                    }
                    ref.child("myClubList").setValue(user.myClubList?.asArrayDictionary()) { error, _ in
                        if let error {
                            print(error.localizedDescription)
                            completion?(false)
                            return
                        }
                        completion?(true)
                        return
                    }
                }
            }
        }
    }
    
    // 방출된 회원의 모든 게시판과 관련된 댓글 모두 삭제
    private func removeOutUserNoticeBoard(in club: Club, outUser: UserSummary, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference()
        let outUserRef = ref.child("Users").child(outUser.id)
        outUserRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            guard let value = dataSnapShot?.value else {
                print("방출할 회원의 데이터를 가져오지 못했습니다.")
                completion?(false)
                return
            }
            guard let user: IDoUser = DataModelCodable.decodingSingleDataSnapshot(value: value) else {
                print("방출할 회원에 대한 디코딩에 실패하였습니다.")
                completion?(false)
                return
            }

            var userNoticeBoardList = user.myNoticeBoardList ?? []
            var removeUserNoticeBoard = [NoticeBoard]()
            var clubNoticeBoardList = club.noticeBoardList ?? []
            userNoticeBoardList.forEach { noticeBoard in
                if club.id == noticeBoard.clubID {
                    clubNoticeBoardList.removeAll(where: { $0.id == noticeBoard.id })
                    removeUserNoticeBoard.append(noticeBoard)
                }
            }
            self.removeUserNoticeBoardList(club: club, user: user, removeNoticeBoardList: removeUserNoticeBoard)
            let clubNoticeBoardRef = ref.child(club.category).child("meetings").child(club.id).child("noticeBoardList")

            clubNoticeBoardRef.setValue(clubNoticeBoardList.asArrayDictionary()) { error, _ in
                if let error {
                    print(error.localizedDescription)
                    completion?(false)
                    return
                }
                completion?(true)
            }
        }
    }
    
    // 모임에서 방출된 회원의 나의 댓글리스트의 게시판아이디와 모임의 모든 게시글과 아이디를 비교해서 맞는지 확인후 맞을 경우 해당 댓글을 나의 댓글리스트와 파이어베이스 DB에 CommentList에서 지우는 메서드
    private func removeOutUserMyCommentList(in club: Club, outUser: UserSummary, completion: ((Bool) -> Void)? = nil) {
        let outUserCommentListRef = Database.database().reference().child("Users").child(outUser.id).child("myCommentList")
        outUserCommentListRef.getData { error, dataSnapShot in
            if let error {
                print("방출할 회원의 댓글리스트 데이터를 가져오지 못했습니다.\(error.localizedDescription)")
                completion?(false)
                return
            }
            guard let value = dataSnapShot?.value as? [Any] else {
                print("방출할 회원의 댓글 리스트 데이터를 가져오지 못했습니다.")
                completion?(false)
                return
            }
            var outUserCommentList = [Comment]()
            value.forEach { data in
                if let comment: Comment = DataModelCodable.decodingSingleDataSnapshot(value: data) {
                    outUserCommentList.append(comment)
                }
            }
            let noticeBoardList = club.noticeBoardList ?? []
            var outUserRemoveCommentList = [Comment]()
            noticeBoardList.forEach { noticeBoard in
                let removeCommentList = outUserCommentList.filter { $0.noticeBoardID == noticeBoard.id }
                outUserRemoveCommentList.append(contentsOf: removeCommentList)
            }
            outUserRemoveCommentList.forEach { comment in
                let removeCommentRef = Database.database().reference().child("CommentList").child(comment.noticeBoardID).child(comment.id)
                removeCommentRef.removeValue { error, _ in
                    if let error {
                        print(error.localizedDescription)
                        return
                    }
                }
                outUserCommentList.removeAll(where: { $0.id == comment.id })
            }
            outUserCommentListRef.setValue(outUserCommentList.asArrayDictionary()) { error, _ in
                if let error {
                    print(error.localizedDescription)
                    completion?(false)
                    return
                }
                completion?(true)
                return
            }
        }
    }

    //MARK: 게시판 DB에서 클럽에 있는 모든 게시판 제거
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
//                self.removeUserNoticeBoard(club: club ,user: noticeBoard.rootUser, removeNoticeBoard: noticeBoard)
                self.removeAllComment(noticeBoard: noticeBoard)
                noticeBoard.imageList?.compactMap { self.removeImage(path: $0.savedImagePath) }
            }
        }
    }
    
    //MARK: 클럽 DB에서 특정 게시판 제거
    func removeNoticeBoard(club: Club, clubNoticeboard: NoticeBoard, completion: ((Bool) -> Void)? = nil) {
        let ref = Database.database().reference().child(club.category).child("meetings").child(club.id).child("noticeBoardList")
        var noticeBoardList = club.noticeBoardList
        noticeBoardList?.removeAll(where: { $0.id == clubNoticeboard.id })
        ref.setValue(noticeBoardList?.asArrayDictionary()) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            completion?(true)
            self.removeUserNoticeBoard(club: club, user: clubNoticeboard.rootUser, removeNoticeBoard: clubNoticeboard)
            self.removeAllCommentList(noticeBoard: clubNoticeboard)
            clubNoticeboard.imageList?.compactMap { self.removeImage(path: $0.savedImagePath) }
        }
    }
    
    private func removeAllComment(noticeBoard: NoticeBoard) {
        let ref = Database.database().reference().child("CommentList").child(noticeBoard.id)
        ref.removeValue { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
        }
    }
        
    private func removeAllCommentList(noticeBoard: NoticeBoard) {
        let ref = Database.database().reference().child("CommentList").child(noticeBoard.id)
        ref.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? [String: Any] else { return }
            let commentList: [Comment] = DataModelCodable.decodingDataSnapshot(value: value)
            commentList.forEach { comment in
                self.removeUserComment(comment: comment)
            }
            ref.removeValue { error, _ in
                if let error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    private func removeUserClub(user: UserSummary, removeClub: Club, completion: ((Bool) -> Void)? = nil) {
        let userClubListRef = Database.database().reference().child("Users").child(user.id)
        userClubListRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            guard let value = dataSnapShot?.value else {
                completion?(false)
                return
            }
//            var userClubList = [Club]()
//            value.forEach { dict in
//                if let userClub: Club = DataModelCodable.decodingSingleDataSnapshot(value: dict) {
//                    if userClub.id == removeClub.id { return }
//                    userClubList.append(userClub)
//                }
//            }
//            userClubListRef.setValue(userClubList.asArrayDictionary()) { error, _ in
//                if let error {
//                    print(error.localizedDescription)
//                    completion?(false)
//                    return
//                }
//                completion?(true)
//            }
            guard let idoUser: IDoUser = DataModelCodable.decodingSingleDataSnapshot(value: value) else {
                print("사용자의 내 클럽 정보를 삭제하기 위한 사용자 정보를 디코딩하지 못했습니다")
                completion?(false)
                return
            }
            var clubList = idoUser.myClubList ?? []
            var noticeBoardList = idoUser.myNoticeBoardList ?? []
            var commentList = idoUser.myCommentList ?? []
            noticeBoardList = noticeBoardList.filter { $0.clubID != removeClub.id }
            clubList.removeAll(where: { $0.id == removeClub.id })
            removeClub.noticeBoardList?.forEach { noticeBoard in
                commentList.removeAll(where: { $0.noticeBoardID == noticeBoard.id })
            }
            
            
            userClubListRef.updateChildValues(["myClubList": clubList.asArrayDictionary() as Any,
                                               "myNoticeBoardList": noticeBoardList.asArrayDictionary() as Any,
                                               "myCommentList": commentList.asArrayDictionary() as Any]) { error, _ in
                if let error {
                    print(error.localizedDescription)
                    completion?(false)
                    return
                }
                completion?(true)
            }
        }
    }
    
    private func removeUserNoticeBoard(club: Club, user: UserSummary, removeNoticeBoard: NoticeBoard) {
        let ref = Database.database().reference()
        let noticeBoardRef = ref.child("noticeBoards").child(removeNoticeBoard.clubID).child(removeNoticeBoard.id)
        noticeBoardRef.removeValue()
        let userNoticeBoardListRef = ref.child("Users").child(user.id).child("myNoticeBoardList")
        userNoticeBoardListRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? [Any] else { return }
            var userNoticeBoardList = [NoticeBoard]()
            value.forEach { dict in
                if let noticeBoard: NoticeBoard = DataModelCodable.decodingSingleDataSnapshot(value: dict) {
                    if noticeBoard.id == removeNoticeBoard.id {
                        return
                    }
                    userNoticeBoardList.append(noticeBoard)
                }
            }
            userNoticeBoardListRef.setValue(userNoticeBoardList.asArrayDictionary())
        }
    }
    
    // MARK: 삭제될 사용자의 클럽에 관련된 모든 게시판 삭제 로직
    private func removeUserNoticeBoardList(club: Club, user: IDoUser, removeNoticeBoardList: [NoticeBoard]) {
        let ref = Database.database().reference()
        removeNoticeBoardList.forEach { noticeBoard in
            let noticeBoardRef = ref.child("noticeBoards").child(noticeBoard.clubID).child(noticeBoard.id)
            noticeBoardRef.removeValue()
        }
        let userNoticeBoardListRef = ref.child("Users").child(user.id).child("myNoticeBoardList")
        
        var userNoticeBoardList = user.myNoticeBoardList ?? []
        userNoticeBoardList.forEach { noticeBoard in
            if removeNoticeBoardList.contains(where: { $0.id == noticeBoard.id }) {
                userNoticeBoardList.removeAll(where: { $0.id == noticeBoard.id })
                self.removeAllCommentList(noticeBoard: noticeBoard)
                return
            }
        }
        userNoticeBoardListRef.setValue(userNoticeBoardList.asArrayDictionary())
    }

    func removeUserComment(comment: Comment) {
        let userCommentListRef = Database.database().reference().child("Users").child(comment.writeUser.id).child("myCommentList")
        userCommentListRef.getData { error, dataSnapShot in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let value = dataSnapShot?.value as? [Any] else { return }
            var userCommentList = [Comment]()
            value.forEach { dict in
                if let comment: Comment = DataModelCodable.decodingSingleDataSnapshot(value: dict) {
                    userCommentList.append(comment)
                }
            }
            userCommentList.removeAll(where: { $0.id == comment.id })
            userCommentListRef.setValue(userCommentList.asArrayDictionary())
        }
    }

    private func removeImage(path: String, completion: ((Bool) -> Void)? = nil) {
        let storageRef = Storage.storage().reference(withPath: path)
        storageRef.delete { error in
            if let error {
                print(error.localizedDescription)
                completion?(false)
                return
            }
            completion?(true)
        }
    }

    func appendUser(user: UserSummary, completion: ((Bool) -> Void)? = nil) {
        guard let model else { return }
        var userList = model.userList ?? []
        userList.append(user)
        ref.updateChildValues(["userList": userList.asArrayDictionary()]) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            self.model?.userList = userList
            completion?(true)
        }
    }
    
    func removeMyUser(user: UserSummary, completion: ((Bool) -> Void)? = nil) {
        guard let model,
              var userList = model.userList else { return }
        userList.removeAll(where: { $0.id == user.id })
        ref.updateChildValues(["userList": userList.asArrayDictionary()]) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            self.model?.userList = userList
            completion?(true)
            guard var myClubList = MyProfile.shared.myUserInfo?.myClubList else { return }
            myClubList.removeAll(where: { $0.id == model.id })
            MyProfile.shared.update(myClubList: myClubList)
        }
    }
    
    /* 처음 진입시
     club과 삭제할 outUser를 가지고 메서드에 들어옴
     클럽에서 outUser 제거 후 저장 -> outUser를 제거한 내용을 다른 club안에 userList에 저장 -> outUser에서도 club을 제거
     outUser에서 myNoticeBoard에서 club id 확인해서 제거 -> club에 게시판에도 제거, myCommentList에서 club id 확인해서 제거
    */
    
    func removeUser(club: Club, user: UserSummary, isBlock: Bool, completion: ((Bool) -> Void)? = nil) {
        guard var userList = club.userList else { return }
        userList.removeAll(where: { $0.id == user.id })
        var club = club
        club.userList = userList
        ref.updateChildValues(["userList": userList.asArrayDictionary()]) { error, _ in
            if let error {
                print(error.localizedDescription)
                return
            }
            
            self.outUser(in: club, outUser: user, isBlock: isBlock) { _ in
                completion?(true)
            }
        }
    }
}
