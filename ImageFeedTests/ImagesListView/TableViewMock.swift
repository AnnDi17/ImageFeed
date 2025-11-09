//
//  TableViewMock.swift
//  ImageFeed
//

@testable import ImageFeed
import XCTest

final class TableViewMock: UITableView {
    var insertedRows: [IndexPath] = []
    var reloadedRows: [IndexPath] = []
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertedRows.append(contentsOf: indexPaths)
        super.insertRows(at: indexPaths, with: animation)
    }
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadedRows.append(contentsOf: indexPaths)
        super.reloadRows(at: indexPaths, with: animation)
    }
}
