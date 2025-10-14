//
//  ListImagesRepositories.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import Foundation

class ListImagesRepositories {
    private let networkManager = NetworkManager.shared
    
    func getListImages(page: Int, limit: Int = 100, completion: @escaping ([ListImagesDTO]?, Error?) -> Void) {
        let url = kGetPicsumsEndpoint + "?page=\(page)&limit=\(limit)"
        
        networkManager.get(urlString: url) { result in
            switch result {
            case .success(let data):
                let images = ListImagesDTO.mappingArray(from: data)
                if images.isEmpty {
                    // If mapping fails, try to decode directly
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decodedImages = try decoder.decode([ListImagesDTO].self, from: data)
                        completion(decodedImages, nil)
                    } catch {
                        completion(nil, error)
                    }
                } else {
                    completion(images, nil)
                }
            case .failure(let networkError):
                // Convert NetworkError to NSError for backward compatibility
                let error = NSError(
                    domain: "ListImagesRepositories",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: networkError.localizedDescription]
                )
                completion(nil, error)
            }
        }
    }
}
