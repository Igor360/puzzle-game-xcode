//
//  Puzzle.swift
//  GameProject_Puzzle
//
//  Created by Ihor on 04.01.2021.
//

class Puzzle: Codable {
    
    var title : String
    
    var resultImages : [String]
    
    var unresolvedImages : [String]
    
    init(title: String, resImages : [String]) {
        self.title = title;
        self.resultImages = resImages;
        self.unresolvedImages = self.resultImages.shuffled();
    }
    
}
