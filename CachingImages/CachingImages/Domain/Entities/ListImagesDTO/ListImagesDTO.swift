//
//  ListImagesDTO.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import Foundation

// MARK: - ListImagesDTO
class ListImagesDTO: Codable {
    var id: String
    var author: String
    var width: Int
    var height: Int
    var url: String
    var downloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case downloadUrl = "download_url"
    }
    
    // MARK: - Static Mapping
    static func mapping(from json: [String: Any]) -> ListImagesDTO? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
              let dto = try? JSONDecoder().decode(ListImagesDTO.self, from: jsonData) else {
            return nil
        }
        return dto
    }
    
    static func mapping(from jsonArray: [[String: Any]]) -> [ListImagesDTO] {
        return jsonArray.compactMap { mapping(from: $0) }
    }
    
    static func mapping(from data: Data) -> ListImagesDTO? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return mapping(from: json)
    }
    
    static func mappingArray(from data: Data) -> [ListImagesDTO] {
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            return []
        }
        return mapping(from: jsonArray)
    }
}
