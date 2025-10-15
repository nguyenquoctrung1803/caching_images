//
//  ListImagesItemTableViewCell.swift
//  CachingImages
//
//  Created by trungnguyenq on 10/14/25.
//

import UIKit

let kListImagesItemTableViewCell = "ListImagesItemTableViewCell"
class ListImagesItemTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var csHeigtMainImage: NSLayoutConstraint!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblImageSize: UILabel!
    
    var idImage: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(obj: ListImagesDTO) {
        self.idImage = obj.id
        self.lblAuthor.text = obj.author
        self.lblImageSize.text = "Size: \(obj.width)x\(obj.height)"
        self.mainImage.image = nil
        CachingImagesManager.shared.setImages(url: obj.downloadUrl) { data in
            guard let data = data, let imageNetWork = UIImage(data: data) else {
                print("Failed to create image from data for URL: \(obj.downloadUrl)")
                return
            }
            DispatchQueue.main.async {
                if let idImage = self.idImage {
                    if idImage == obj.id {
                        self.mainImage.image = imageNetWork
                    }
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
