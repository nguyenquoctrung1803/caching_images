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
    
    private let downloadQueue = DispatchQueue(label: "com.trung.nguyenq.CachingImages.download", qos: .userInitiated, attributes: .concurrent)
    
    func setImages(url: String, completion: @escaping (Data?) -> Void) {
        let cacheKey = url as NSString
        
        downloadQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            // Check if cached
            if let cachedData = self.images.object(forKey: cacheKey) {
                completion(cachedData as Data)
                return
            }
            
            // Download on background thread
            self.networkManager.downloadImage(imageURL: url) { [weak self] (result: Result<Data, NetworkError>) in
                guard let self = self else {
                    completion(nil)
                    return
                }
                
                switch result {
                case .success(let data):
                    completion(data)
                    self.images.setObject(data as NSData, forKey: cacheKey)
                    
                case .failure:
                    completion(nil)
                }
            }
        }
    }
}
