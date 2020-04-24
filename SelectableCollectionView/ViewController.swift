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
    
    private let vm = ViewModel()

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
        collectionView.contentInset = .init(top: 1, left: 0, bottom: 1, right: 0)
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AlphabetCollectionViewCell.self, forCellWithReuseIdentifier: AlphabetCollectionViewCell.id)
    }
}

extension ViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.section == 0,
            indexPath.row < vm.selectedItems.count else { return [] }
        
        let item = vm.selectedItems[indexPath.row]
        let provider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return collectionView.hasActiveDrag
            ? UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            : UICollectionViewDropProposal(operation: .cancel)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let item = coordinator.items.first else { return }
        let sourceIndexPath = item.sourceIndexPath!
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            destinationIndexPath = IndexPath(
                item: collectionView.numberOfItems(inSection: 0),
                section: 0)
        }
        
        switch coordinator.proposal.operation {
        case .move:
            collectionView.performBatchUpdates({
                move(at: sourceIndexPath.row, to: destinationIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            
        default:
            ()
        }
        
    }
        
    private func move(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        let item = vm.selectedItems[sourceIndex]
        vm.selectedItems.remove(at: sourceIndex)
        vm.selectedItems.insert(item, at: destinationIndex)
    }
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlphabetCollectionViewCell.id, for: indexPath) as? AlphabetCollectionViewCell else { return .init() }
        let title = vm.title(at: indexPath)
        let order = vm.order(at: indexPath)
        
        cell.configure(.init(title: title, order: order))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        vm.updateStackState(at: indexPath)
        collectionView.reloadData()
    }
}

final class ViewModel {
    let numberOfSection = 2
    func numberOfItems(in section: Int) -> Int {
        return section == 0 ? 6 : items.count
    }
    
    var items: [String] = ["A","B","C","D","E","F","G"]
    var selectedItems: [String] = []
    
    func title(at indexPath: IndexPath) -> String {
        if indexPath.section == 0 {
            return indexPath.row < selectedItems.count ? selectedItems[indexPath.row] : ""
        } else {
            return items[indexPath.row]
        }
    }
    
    func order(at indexPath: IndexPath) -> Int? {
        let order: Int? = {
            switch indexPath.section {
            case 1: return selectedItems.enumerated().filter { $0.element == items[indexPath.row] }.first?.offset
            default: return nil
            }
        }()
        return order
    }
    
    func updateStackState(at indexPath: IndexPath) {
        let item = items[indexPath.row]
        let selectedIndex = selectedItems.enumerated().filter { $0.element == item }.first?.offset ?? 0
        selectedItems.contains(item)
            ? selectedItems.removeSubrange(selectedIndex...selectedIndex)
            : selectedItems.append(item)
    }
}

final class SectionHeaderView: UICollectionReusableView {
    static let id = "SectionHeaderView"
}

final class AlphabetCollectionViewCell: UICollectionViewCell {
    static let id = "AlphabetCollectionViewCell"
    
    private let titleLabel = UILabel(frame: .zero)
    private let orderLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        titleLabel.textAlignment = .center
        orderLabel.textAlignment = .center
        orderLabel.isHidden = true
        orderLabel.backgroundColor = .black
        orderLabel.textColor = .white
        orderLabel.layer.cornerRadius = 20
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(orderLabel)
        
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        orderLabel.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.top.trailing.equalToSuperview()
        }
    }
    
    func configure(_ vm: ViewModel) {
        titleLabel.text = vm.title
        orderLabel.text = String(vm.order ?? 0)
        orderLabel.isHidden = vm.order == nil
    }

    struct ViewModel {
        var title: String
        var order: Int?
    }
}
