//
//  ViewController.swift
//  SelectableCollectionView
//
//  Created by Hayoung Park on 2020/04/22.
//  Copyright © 2020 Hayoung Park. All rights reserved.
//

import UIKit
import Then
import SnapKit

final class ViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
//    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        let length = floor((UIScreen.main.bounds.width-2)/3)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: length, height: length)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    let vm = ViewModel()
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0
            ? .init(width: UIScreen.main.bounds.width, height: CGFloat.leastNonzeroMagnitude)
            : .init(width: UIScreen.main.bounds.width, height: 88)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vm.numberOfSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.id, for: indexPath) as? SectionHeaderView else { return .init() }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        return cell
    }
}

final class ViewModel {
    let numberOfSection = 2
    func numberOfItems(in section: Int) -> Int {
        return section == 0 ? 6 : items.count
    }
    
    var selectedItems: [Int] = []
    var items: [Int] = [0,1,2,3,4,5,6,7,8,9]
}

final class SectionHeaderView: UICollectionReusableView {
    static let id = "SectionHeaderView"
}
