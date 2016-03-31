//
//  PhotoAlbumCellCollectionViewCell.swift
//  VirtualTourist4U
//
//  Created by ZZZZeran on 3/23/16.
//  Copyright © 2016 Z Latte. All rights reserved.
//

import UIKit

class PhotoAlbumCellCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRectZero)
        self.contentView.addSubview(imageView)
        imageView.frame = bounds
       
    }
    
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
