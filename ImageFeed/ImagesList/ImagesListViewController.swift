//
//  ViewController.swift
//  ImageFeed
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func photosCountDidUpdate()
    func didUpdateCell(at indexPath: IndexPath)
    func setImage(for cell: ImagesListCell, with url: URL, _ completion: @escaping (Result<RetrieveImageResult, Error>) -> Void)
    func configLabel(for cell: ImagesListCell, with text: String)
    func configLikeButton(for cell: ImagesListCell, isLiked: Bool)
    
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol{
    
    @IBOutlet private var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var imagesCount: Int { presenter?.photos.count ?? 0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
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
            viewController.fullImageURL = presenter?.getUrlForFullSizePhoto(at: indexPath.row)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func photosCountDidUpdate(){
        updateTableViewAnimated()
    }
    
    private func updateTableViewAnimated() {
        let currentRowCount = tableView.numberOfRows(inSection: 0)
        let newRowCount = imagesCount
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
        imagesCount
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
        let testMode =  ProcessInfo.processInfo.arguments.contains("testMode")
        if testMode {
            return
        }
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            presenter?.getNewPhotos() {_ in}
        }
    }
    
    func didUpdateCell(at indexPath: IndexPath){
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func setImage(for cell: ImagesListCell, with url: URL, _ completion: @escaping (Result<RetrieveImageResult, Error>) -> Void){
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(with: url, placeholder: UIImage(resource: .stub)) {result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func configLabel(for cell: ImagesListCell, with text: String) {
        cell.dateLabel.text = text
    }
    
    func configLikeButton(for cell: ImagesListCell, isLiked: Bool) {
        let image = UIImage(resource: isLiked ? .likeActive : .likeNoActive)
        cell.likeButton.setImage(image, for: .normal)
        cell.likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath){
        presenter?.configImageCell(for: cell, with: indexPath)
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = tableView.bounds.width - 32 //trailing and leading constraints
        
        guard let cellHeight = presenter?.getHeightForView(at: indexPath.row, width: width) else { return 0}
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter?.didChangeLike(indexPath.row){
            [weak self] result in
            guard let self else {return}
            switch result {
            case .success(let isLiked):
                cell.setIsLiked(isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("ImagesListViewController.imageListCellDidTapLike: \(error.localizedDescription)")
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


