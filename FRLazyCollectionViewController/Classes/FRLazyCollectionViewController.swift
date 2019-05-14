//
//  CategoryViewController.swift
//  vidzulu
//
//  Created by Nikola Ristic on 3/27/19.
//  Copyright © 2019 fr. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LazyCell"
private let minimumItemNumber = 10

protocol FRLazyCollectionViewControllerDelegate: class {
    func registerCellType()
    func loadCollectionData<Item>(page: Int, callback: (([Item]) -> Void))
    func loadDataInCell<Item>(_ cell: UICollectionViewCell, value: Item)
}

class FRLazyCollectionViewController<Item>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    var itemsList: [Placeholder<Item>] = []
    weak var lazyCollectionDelegate: FRLazyCollectionViewControllerDelegate?

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        lazyCollectionDelegate!.registerCellType()
        collectionView.delegate = self
        collectionView.dataSource = self
        for _ in 0 ..< 2 * minimumItemNumber {
            itemsList.append(.empty)
        }
        loadPageData(0)
    }

    // MARK: - Infinite loader methods

    @objc func addEmptyPlaceholders() {
        var insertPaths: [IndexPath] = []
        for _ in 0 ..< minimumItemNumber {
            insertPaths.append(IndexPath(row: itemsList.count, section: 0))
            itemsList.append(.empty)
        }
        collectionView.insertItems(at: insertPaths)
    }

    func replaceEmptyPlaceholders(_ values: [Item]) {
        var reloadPaths: [IndexPath] = []
        let emptyIndex = self.itemsList.firstIndex(where: { $0 == .empty }) ?? self.itemsList.count
        for index in 0 ..< values.count {
            let row = emptyIndex + index
            if self.itemsList.count > row {
                self.itemsList[row] = Placeholder.value(values[index])
                reloadPaths.append(IndexPath(row: row, section: 0))
            } else {
                print("An error occured")
            }
        }
        self.collectionView.reloadItems(at: reloadPaths)
    }

    func loadPageData(_ page: Int = 0) {
        let callback: ([Item]) -> Void = { items in
            self.replaceEmptyPlaceholders(items)
        }
        lazyCollectionDelegate?.loadCollectionData(page: page, callback: callback)
    }

    func loadData() {
        if self.isLastCellVisible() {
            self.addEmptyPlaceholders()
        }
        if self.itemsList.contains(Placeholder.empty) {
            loadPageData(0)
        }
    }

    func isLastCellVisible() -> Bool {
        let maxRow = collectionView.indexPathsForVisibleItems.max(by: { $0.row < $1.row})?.row ?? 0
        return maxRow > itemsList.count - 10
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsList.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let video = itemsList[indexPath.row].value() {
            lazyCollectionDelegate?.loadDataInCell(cell, value: video)
        }
        return cell
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadData()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadData()
    }
}
