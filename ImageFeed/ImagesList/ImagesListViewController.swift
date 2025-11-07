//
//  ViewController.swift
//  ImageFeed
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private var imageListServiceObserver: NSObjectProtocol?
    private let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        self.photos = imagesListService.photos
        updateTableViewAnimated()
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self else { return }
                if let newPhotos = notification.userInfo?["Info"] as? [Photo] {
                    self.photos.append(contentsOf: newPhotos)
                } else {
                    self.photos = imagesListService.photos
                }
                self.updateTableViewAnimated()
            }
        
    }
    //data for the screen with a single image
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("prepare: invalid segue destination")
                return
            }
            let fullImageURL = photos[indexPath.row].largeImageURL
            viewController.fullImageURL = fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        let currentRowCount = tableView.numberOfRows(inSection: 0)
        let newRowCount = photos.count
        guard newRowCount > currentRowCount else { return }
        
        var indexPaths: [IndexPath] = []
        for i in currentRowCount..<newRowCount {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        
        tableView.performBatchUpdates{
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            imagesListService.fetchPhotosNextPage(token: OAuth2TokenStorage.shared.token ?? ""){ _ in
            }
        }
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath){
        let url = URL(string: photos[indexPath.row].thumbImageURL)
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(with: url, placeholder: UIImage(resource: .stub)) {[weak self] result in
            guard let self else {return}
            switch result {
            case .success(let data):
                if self.photos[indexPath.row].isLoaded {
                    if let date = photos[indexPath.row].createdAt {
                        cell.dateLabel.text = dateFormatter.string(from: date)
                    } else {
                        cell.dateLabel.text = ""
                    }
                    cell.likeButton.setImage(UIImage(resource: photos[indexPath.row].isLiked ? .likeActive : .likeNoActive),for: .normal)
                } else {
                    self.photos[indexPath.row].isLoaded = true
                    self.photos[indexPath.row].thumbImageSize = data.image.size
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("configCell: \(error.localizedDescription), row: \(indexPath.row)")
            }
        }
        
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size: CGSize
        
        if photos.count > indexPath.row && photos[indexPath.row].isLoaded {
            size = photos[indexPath.row].thumbImageSize
        }
        else {
            let image = UIImage(resource: .stub)
            size = image.size
        }
        
        let wView = tableView.bounds.width - 32 //trailing and leading constraints
        let wImage = size.width
        let hImage = size.height
        let k = wView / wImage
        var cellHeight = hImage * k
        cellHeight += 8 //top and bottom constraints
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(with: OAuth2TokenStorage.shared.token ?? "", photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else {return}
            switch result {
            case .success:
                self.photos[indexPath.row].isLiked = self.imagesListService.photos[indexPath.row].isLiked
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось обновить данные",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

