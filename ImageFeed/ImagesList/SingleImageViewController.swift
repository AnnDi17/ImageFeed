//
//  SingleImageViewController.swift
//  ImageFeed
//


import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var fullImageURL: String? {
        didSet {
            guard isViewLoaded else { return }
            guard let fullImageURL else { return }
            let url = URL(string: fullImageURL)
            imageView.kf.setImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    imageView.frame.size = imageResult.image.size
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure:
                    print("SingleImageViewController: Error loading image")
                }
            }
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        shareButton.layer.cornerRadius = shareButton.frame.size.width/2
        scrollView.maximumZoomScale = 1.25
        scrollView.minimumZoomScale = 0.1
        guard let fullImageURL else { return }
        UIBlockingProgressHUD.show()
        let url = URL(string: fullImageURL)
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                print("SingleImageViewController: Error loading image")
            }
        }
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let shareImage = imageView.image else { return }
        let shareController = UIActivityViewController(
            activityItems: [shareImage],
            applicationActivities: nil
        )
        present(shareController, animated: true)
    }
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImageAfterZooming(_ scrollView: UIScrollView) {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let x = (visibleRectSize.width - newContentSize.width) / 2
        let y = (visibleRectSize.height - newContentSize.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageAfterZooming(scrollView)
    }
}
