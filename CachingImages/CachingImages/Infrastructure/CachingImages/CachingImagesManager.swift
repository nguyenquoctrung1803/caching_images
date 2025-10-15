//
//  CachingImagesManager.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/15/25.
//

import Foundation
import UIKit

class CachingImagesManager {
    static let shared = CachingImagesManager()
    
    private let networkManager = NetworkManager.shared
    private var images = NSCache<NSString, UIImage>()
    
    private let downloadQueue = DispatchQueue(label: "com.trung.nguyenq.CachingImages.download", qos: .userInitiated, attributes: .concurrent)
    
    func setImages(url: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = url as NSString
        
        downloadQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            // Check if cached UIImage
            if let cachedImage = self.images.object(forKey: cacheKey) {
                completion(cachedImage)
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
                    // Decode image using ImageIO on background thread
                    if let decodedImage = self.decodeImage(from: data) {
                        // Cache decoded UIImage with cost
                        let cost = Int(decodedImage.size.width * decodedImage.size.height * decodedImage.scale * decodedImage.scale)
                        self.images.setObject(decodedImage, forKey: cacheKey, cost: cost)
                        completion(decodedImage)
                    } else {
                        completion(nil)
                    }
                    
                case .failure:
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Decode Image using ImageIO (Best Performance)
    private func decodeImage(from data: Data) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldAllowFloat: true,
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
