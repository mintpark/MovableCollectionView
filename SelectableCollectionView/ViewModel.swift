//
//  ViewModel.swift
//  SelectableCollectionView
//
//  Created by Hayoung Park on 2020/04/25.
//  Copyright © 2020 Hayoung Park. All rights reserved.
//

import UIKit

final class ViewModel {
    let numberOfSection = 2
    func numberOfItems(in section: Int) -> Int {
        return section == 0 ? 6 : items.count
    }
    
    private(set) var items: [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    private(set) var selectedItems: [String] = []
    let maxSize = 6
    
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
    
    func removeOrdered(at: Int) {
        selectedItems.remove(at: at)
    }
    
    func insertOrdered(_ item: String, at: Int) {
        selectedItems.insert(item, at: at)
    }
    
    func clear() {
        selectedItems = []
    }
    
    func isSelectable(at indexPath: IndexPath) -> Bool {
        return maxSize > selectedItems.count || selectedItems.contains(items[indexPath.row])
    }
}
