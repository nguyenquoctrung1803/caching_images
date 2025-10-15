//
//  CachingImagesManager.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/15/25.
//

import Foundation
import UIKit
import ImageIO

class CachingImagesManager {
    static let shared = CachingImagesManager()
    
    private let networkManager = NetworkManager.shared
    private var images = NSCache<NSString, UIImage>()
    
    private let downloadQueue = DispatchQueue(label: "com.trung.nguyenq.CachingImages.download", qos: .userInitiated, attributes: .concurrent)
    private let decodeQueue = DispatchQueue(label: "com.trung.nguyenq.CachingImages.decode", qos: .userInitiated, attributes: .concurrent)
    
    
    func setImages(url: String, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = "\(url)_\(Int(targetSize.width))x\(Int(targetSize.height))" as NSString
        
        if let cachedImage = images.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        // Download and process on background
        downloadQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            self.networkManager.downloadImage(imageURL: url) { [weak self] (result: Result<Data, NetworkError>) in
                guard let self = self else {
                    completion(nil)
                    return
                }
                
                switch result {
                case .success(let data):
                    // Decode and downsample on background thread
                    self.decodeQueue.async {
                        if let downsampledImage = self.downsampleImage(from: data, to: targetSize, scale: UIScreen.main.scale) {
                            // Cache the downsampled image
                            let cost = Int(downsampledImage.size.width * downsampledImage.size.height * downsampledImage.scale * downsampledImage.scale * 4)
                            
                            completion(downsampledImage)
                            self.images.setObject(downsampledImage, forKey: cacheKey, cost: cost)
                        } else {
                            completion(nil)
                        }
                    }
                    
                case .failure(let error):
                    print("Download failed: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    private func downsampleImage(from data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        return UIImage(cgImage: downsampledImage)
    }
}
