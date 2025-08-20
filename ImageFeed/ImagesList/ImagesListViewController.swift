//
//  ViewController.swift
//  ImageFeed
//

import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath){
        let imageName = photosName[indexPath.row]
        let currentDate = Date()
        guard let image = UIImage(named: imageName) else {
            return
        }
        cell.cellImageView.image = image
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        if indexPath.row%2 == 0 {
            cell.likeButton.setImage(UIImage(named: "Like_Active"), for: .normal)
        }
        else {
            cell.likeButton.setImage(UIImage(named: "Like_noActive"), for: .normal)
        }
    }
    
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let wView = tableView.bounds.width - 32 //trailing and leading constraints
        let wImage = image.size.width
        let hImage = image.size.height
        let k = wView / wImage
        var cellHeight = hImage * k
        cellHeight += 8 //top and bottom constraints
        return cellHeight
    }
}

