//
//  ImagesListViewTests.swift
//  ImageFeed
//

@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    
    func testViewControllerCallsPresenter() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testTableViewDelegate_HeightForRow_CallsPresenter() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        let tableView = TableViewMock(frame: CGRect(x: 0, y: 0, width: 300, height: 700), style: .plain)
        tableView.dataSource = viewController
        tableView.delegate = viewController
        viewController.setValue(tableView, forKey: "tableView")
        
        //when
        _ = viewController.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        
        //then
        XCTAssertTrue(presenter.getHeightForViewCalled)
    }
    
    func testPhotosCountDidUpdateInsertsRows() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        let tableView = TableViewMock(frame: CGRect(x: 0, y: 0, width: 300, height: 700), style: .plain)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = viewController
        tableView.delegate = viewController
        viewController.setValue(tableView, forKey: "tableView")
        
        presenter.photos = (0..<2).map { i in
            Photo(id: "\(i)", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false, isLoaded: false, thumbImageSize: .zero)
        }
        viewController.photosCountDidUpdate()
        tableView.layoutIfNeeded()
        tableView.insertedRows.removeAll()
        
        //when
        let newPhotos = (2..<4).map { i in
            Photo(id: "\(i)", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false, isLoaded: false, thumbImageSize: .zero)
        }
        presenter.photos.append(contentsOf: newPhotos)
        viewController.photosCountDidUpdate()
        tableView.layoutIfNeeded()
        
        //then
        XCTAssertEqual(tableView.insertedRows, [IndexPath(row: 2, section: 0), IndexPath(row: 3, section: 0)])
    }
    
    func testImageListCellDidTapLikeCallsPresenterAndSetsLike() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        let tableView = TableViewMock(frame: CGRect(x: 0, y: 0, width: 300, height: 700), style: .plain)
        tableView.register(ImagesListCellMock.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = viewController
        tableView.delegate = viewController
        viewController.setValue(tableView, forKey: "tableView")
        
        presenter.photos = [
            Photo(id: "0", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false, isLoaded: true, thumbImageSize: CGSize(width: 17, height: 17))
        ]
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        
        let indexPath = IndexPath(row: 0, section: 0)
        _ = viewController.tableView(tableView, cellForRowAt: indexPath)
        tableView.layoutIfNeeded()
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCellMock else {
            XCTFail("Failed to obtain ImagesListCellMock from tableView")
            return
        }
        
        //when
        viewController.imageListCellDidTapLike(cell)
        
        //then
        XCTAssertTrue(presenter.didChangeLikeCalled)
        XCTAssertEqual(cell.setIsLikedCalled, true)
    }
    
    func testDidUpdateCellReloadsRows() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        let tableView = TableViewMock(frame: CGRect(x: 0, y: 0, width: 300, height: 700), style: .plain)
        tableView.register(ImagesListCellMock.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = viewController
        tableView.delegate = viewController
        viewController.setValue(tableView, forKey: "tableView")
        
        let idx = IndexPath(row: 0, section: 0)
        
        //when
        viewController.didUpdateCell(at: idx)
        
        //then
        XCTAssertTrue(tableView.reloadedRows.contains(idx))
    }
    
    func testPrepareForSegueSetsFullImageURL() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        let singleImageViewController = SingleImageViewController()
        let indexPath = IndexPath(row: 0, section: 0)
        presenter.photos = [
            Photo(id: "A", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "url", isLiked: false, isLoaded: false, thumbImageSize: .zero)
        ]
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: viewController, destination: singleImageViewController)
        
        //when
        viewController.prepare(for: segue, sender: indexPath)
        
        //then
        XCTAssertEqual(singleImageViewController.fullImageURL, "url")
    }
    
}
