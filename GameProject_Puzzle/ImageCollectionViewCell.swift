//
//  ImageCollectionViewCell.swift
//  GameProject_Puzzle
//
//  Created by Ihor on 04.01.2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
     	
    var puzzleImage: UIImageView?
    
    override func awakeFromNib() {
        self.frame = puzzleImage?.frame ?? .zero
    }
    
}
