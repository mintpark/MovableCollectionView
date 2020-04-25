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
    
    private let gesture = UIPanGestureRecognizer()
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
        layout.sectionHeadersPinToVisibleBounds = true
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .lightGray
        collectionView.contentInset = .init(top: 1, left: 0, bottom: 1, right: 0)
        collectionView.alwaysBounceVertical = false
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AlphabetCollectionViewCell.self, forCellWithReuseIdentifier: AlphabetCollectionViewCell.id)
    }
}

extension ViewController: SectionHeaderViewDelegate {
    
    func headerViewHide() {
        collectionView.scrollToSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: .init(row: 0, section: 1), at: .top, animated: true)
    }
    
    func headerViewShow() {
        collectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
    
    func headerViewClear() {
        vm.clear()
        collectionView.reloadData()
        headerViewShow()
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
            }, completion: { _ in
                collectionView.reloadSections(.init(integer: 1))
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            
        default:
            ()
        }
        
    }
        
    private func move(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        let item = vm.selectedItems[sourceIndex]
        vm.removeOrdered(at: sourceIndex)
        vm.insertOrdered(item, at: destinationIndex)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0
            ? .init(width: UIScreen.main.bounds.width, height: CGFloat.leastNonzeroMagnitude)
            : .init(width: UIScreen.main.bounds.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 0
            ? .init(width: UIScreen.main.bounds.width, height: 44)
            : .init(width: UIScreen.main.bounds.width, height: CGFloat.leastNonzeroMagnitude)
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
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? SectionHeaderView else { break }
            header.delegate = self
            return header
            
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionFooterView", for: indexPath)
            
        default:
            return .init()
        }
        
        return .init()
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
        
        guard vm.isSelectable(at: indexPath) else {
            let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
            let alert = UIAlertController(title: "선택 가능한 아이템은 최대 6개입니다", message: nil, preferredStyle: .alert)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        
        vm.updateStackState(at: indexPath)
        collectionView.reloadData()
    }
}

protocol SectionHeaderViewDelegate: class {
    func headerViewHide()
    func headerViewShow()
    func headerViewClear()
}

final class SectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var hideLabel: UILabel!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var clearLabel: UILabel!
    
    weak var delegate: SectionHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapHide = UITapGestureRecognizer(target: self, action: #selector(didTapHide))
        let tapShow = UITapGestureRecognizer(target: self, action: #selector(didTapShow))
        let tapClear = UITapGestureRecognizer(target: self, action: #selector(didTapClear))
        hideLabel.addGestureRecognizer(tapHide)
        showLabel.addGestureRecognizer(tapShow)
        clearLabel.addGestureRecognizer(tapClear)
    }
    
    @objc private func didTapHide() {
        delegate?.headerViewHide()
    }
    @objc private func didTapShow() {
        delegate?.headerViewShow()
    }
    @objc private func didTapClear() {
        delegate?.headerViewClear()
    }
}
