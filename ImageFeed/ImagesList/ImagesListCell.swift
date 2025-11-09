//
//  ImagesListCell.swift
//  ImageFeed
//

import UIKit

class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeTap(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
    
    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(UIImage(resource: isLiked ? .likeActive : .likeNoActive),for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }
}
