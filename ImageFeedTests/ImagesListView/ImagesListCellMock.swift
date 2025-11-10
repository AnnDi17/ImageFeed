//
//  ImagesListCellMock.swift
//  ImageFeed
//

@testable import ImageFeed
import XCTest

final class ImagesListCellMock: ImagesListCell {
    var setIsLikedCalled: Bool?
    override func setIsLiked(_ isLiked: Bool) {
        setIsLikedCalled = isLiked
    }
}
