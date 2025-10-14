//
//  CachingImagesManager.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/15/25.
//

import Foundation

class CachingImagesManager {
    static let shared = CachingImagesManager()
    
    private let networkManager = NetworkManager.shared
    private var images = NSCache<NSString, NSData>()
    
    func setImages(url: String, completion: @escaping (Data?) -> Void) {
        let cacheKey = url as NSString
        if let cachedData = images.object(forKey: cacheKey) {
            completion(cachedData as Data)
            return
        }
        networkManager.downloadImage(imageURL: url) { [weak self] (result: Result<Data, NetworkError>) in
            switch result {
            case .success(let data):
                self?.images.setObject(data as NSData, forKey: cacheKey)
                completion(data)
            case .failure:
                completion(nil)
            }
        }
    }
    
}
