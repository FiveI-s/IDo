//
//  URLCache.swift
//  IDo
//
//  Created by 김도현 on 2023/10/24.
//

import UIKit
import FirebaseStorage

final class CacheImage {
    var image: UIImage
    var updated: Date?
    
    init(image: UIImage, updated: Date?) {
        self.image = image
        self.updated = updated
    }
}

class FBURLCache {
    static let shared = FBURLCache()
    private let imageCache = NSCache<NSString, CacheImage>()
    private var downloadTasks: [IndexPath: URLSessionDataTask] = [:]
    
    private init() {}
    
    func cancelDownloadURL(indexPath: IndexPath) {
        downloadTasks[indexPath]?.cancel()
        downloadTasks[indexPath] = nil
    }
    
    //TODO: 코드를 메서드를 어떻게 줄일지 생각해보기
    func downloadURL(storagePath: String, indexPath: IndexPath? = nil, completion: @escaping (Result<UIImage,Error>) -> Void) {
        var cacheImage: CacheImage? = nil
        if let image = imageCache.object(forKey: storagePath as NSString) {
            completion(.success(image.image))
            cacheImage = image
        }
        let storage = Storage.storage().reference(withPath: storagePath)
                
        storage.getMetadata { metadata, error in
            if let error {
                completion(.failure(error))
                return
            }
                        
            if let cacheImageUpdated = cacheImage?.updated,
               let storageDataUpdated = metadata?.updated,
               cacheImageUpdated == storageDataUpdated {
                return
            }
                                                
            storage.downloadURL { url, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let url else { return }
                let request = URLRequest(url: url)
                self.downloadImageData(request: request, storagePath: storagePath, indexPath: indexPath, updated: metadata?.updated) { result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            completion(.success(image))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    if let indexPath {
                        self.downloadTasks.removeValue(forKey: indexPath)
                    }
                }
            }
        }
    }
    
    struct ImageIndex {
        var index: String
        var image: UIImage
    }
    
    func downloadURL(storagePath: String, indexPath: IndexPath? = nil, completion: @escaping (Result<ImageIndex,Error>) -> Void) {
        
//        if let image = imageCache.object(forKey: storagePath as NSString) {
//            completion(.success(image))
//            return
//        }
        let storage = Storage.storage().reference(withPath: storagePath)
        storage.getMetadata { metadata, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let indexMetaData = metadata?.customMetadata?["index"] else {
                print("메타데이터가 없습니다")
                return
            }
            storage.downloadURL { url, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let url else { return }
                let request = URLRequest(url: url)
                
                self.downloadImageData(request: request, storagePath: storagePath, updated: metadata?.updated) { result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            let imageIndex = ImageIndex(index: indexMetaData, image: image)
                            completion(.success(imageIndex))
                            return
                        }
                        print("image Data를 읽을수 없습니다.")
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                    
                }
            }
        }
    }
    
    private func downloadImageData(request: URLRequest, storagePath: String, indexPath: IndexPath? = nil, updated: Date? = nil, completion: @escaping (Result<Data,Error>) -> Void) {
        let urlTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            guard let data,
                let response else { return }
            completion(.success(data))
            if let image = UIImage(data: data) {
                let cacheImage = CacheImage(image: image, updated: updated)
                self?.imageCache.setObject(cacheImage, forKey: storagePath as NSString)
            }
        }
        if let indexPath {
            downloadTasks[indexPath] = urlTask
        }
        urlTask.resume()
    }
}
