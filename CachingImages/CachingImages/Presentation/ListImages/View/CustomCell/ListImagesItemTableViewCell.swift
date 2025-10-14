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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
