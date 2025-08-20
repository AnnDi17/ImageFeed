//
//  ImagesListCell.swift
//  ImageFeed
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!

    @IBAction func likeTap(_ sender: UIButton) {
    }
}
