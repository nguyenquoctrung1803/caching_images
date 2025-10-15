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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.mainImage.image = nil
        self.idImage = nil
    }
    
    func configure(obj: ListImagesDTO) {
        self.idImage = obj.id
        self.lblAuthor.text = obj.author
        self.lblImageSize.text = "Size: \(obj.width)x\(obj.height)"
        
        let targetHeight: CGFloat = obj.height > 3000 ? 300 : 200
        self.csHeigtMainImage.constant = targetHeight
        
        // Load and decode image
        CachingImagesManager.shared.setImages(url: obj.downloadUrl) { [weak self] decodedImage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.idImage == obj.id {
                    self.mainImage.image = decodedImage
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
