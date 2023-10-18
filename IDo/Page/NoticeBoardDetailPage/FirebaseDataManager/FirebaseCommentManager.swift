//
//  FirebaseDataManager.swift
//  IDo
//
//  Created by 김도현 on 2023/10/16.
//

import Foundation
import Firebase
import FirebaseDatabase

enum FirebaseError: Error {
    case dataSnapshotNil
    case networkError
    case userNotFound
    case userTokenExpired
    case tooManyRequests
    case otherError
}

class FirebaseCommentManager {
    private var ref: DatabaseReference!
    var commentList = [Comment]() {
        didSet {
            update()
        }
    }
    var viewState: ViewState = .loading
    var update: () -> Void = {}
    
    init(noticeBoardID: String) {
        self.ref = Database.database().reference().child("NoticeBoard").child("CommentList")
    }
    
    func addComment(comment: Comment) {
        ref.child(comment.id).setValue(comment.dictionary)
        commentList.append(comment)
    }
    
    func readCommtents() {
        ref.getData { error, dataSnapshot in
            if let error {
                let nsError = error as NSError
                if nsError.code == 1 { self.viewState = .error(true) }
                else { self.viewState = .error(false) }
                self.update()
                return
            }
            guard let dataSnapshot else {
                self.viewState = .error(false)
                self.update()
                return
            }
            guard let value = dataSnapshot.value as? [String: Any] else {
                self.viewState = .loaded
                self.commentList = []
                return
            }
            let commentList: [Comment] = self.decodingDataSnapshot(value: value)
            let commentSortedList: [Comment] = commentList.sorted(by: {
                    $0.createDate <= $1.createDate
                })
            self.viewState = .loaded
            self.commentList = commentSortedList
        }
    }
    
    func updateComments(comment: Comment) {
        guard let index = commentList.firstIndex(where: { $0.id == comment.id }) else { return }
        commentList[index] = comment
        ref.updateChildValues([comment.id: comment.dictionary])
    }
    
    func deleteComment(comment: Comment) {
        commentList.removeAll(where: { $0.id == comment.id })
        ref.updateChildValues([comment.id: nil])
    }
    
    private func decodingDataSnapshot<T: Decodable>(value: [String: Any]) -> [T] {
        let commentTestList: [T] = value.compactMap { key, value in
            let comment: T? = decodingSingleDataSnapshot(value: value)
            return comment
        }
        return commentTestList
    }
    
    private func getDecodingData<T: Decodable>(dataSnapshot: DataSnapshot) -> T? {
        guard let value = dataSnapshot.value as? [String: Any] else { return nil }
        guard let data: T = self.decodingSingleDataSnapshot(value: value) else { return  nil }
        return data
    }
    
    private func decodingSingleDataSnapshot<T: Decodable>(value: Any) -> T? {
        let decoder = JSONDecoder()
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
