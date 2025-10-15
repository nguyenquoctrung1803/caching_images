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
        
        // Calculate target size based on aspect ratio from ListImagesDTO
        let imageViewWidth = self.mainImage.bounds.width > 0 ? self.mainImage.bounds.width : UIScreen.main.bounds.width
        let aspectRatio = CGFloat(obj.height) / CGFloat(obj.width)
        let targetHeight = imageViewWidth * aspectRatio
        
        // height will limit range (150-400)
        let constrainedHeight = min(max(targetHeight, 150), 400)
        self.csHeigtMainImage.constant = constrainedHeight
        
        let targetSize = CGSize(width: imageViewWidth, height: constrainedHeight)
        
        // Load, downsample and decode image
        CachingImagesManager.shared.setImages(url: obj.downloadUrl, targetSize: targetSize) { [weak self] downsampledImage in
            guard let self = self else { return }
            if self.idImage == obj.id {
                DispatchQueue.main.async {
                    self.mainImage.image = downsampledImage
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
