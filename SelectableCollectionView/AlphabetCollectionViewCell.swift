//
//  AlphabetCollectionViewCell.swift
//  SelectableCollectionView
//
//  Created by Hayoung Park on 2020/04/25.
//  Copyright © 2020 Hayoung Park. All rights reserved.
//

import UIKit

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
        orderLabel.clipsToBounds = true
        orderLabel.backgroundColor = .black
        orderLabel.textColor = .white
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(orderLabel)
        
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        orderLabel.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.top.trailing.equalToSuperview().inset(2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        orderLabel.layer.cornerRadius = 12
    }
    
    func configure(_ vm: ViewModel) {
        titleLabel.text = vm.title
        orderLabel.text = String(1+(vm.order ?? 0))
        orderLabel.isHidden = vm.order == nil
    }
    
    struct ViewModel {
        var title: String
        var order: Int?
    }
}
