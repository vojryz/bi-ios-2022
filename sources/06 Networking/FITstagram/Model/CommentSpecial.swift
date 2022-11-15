//
//  CommentSpecial.swift
//  FITstagram
//
//  Created by Vojtech Ryznar on 14.11.2022.
//

import Foundation

struct CommentSpecial: Identifiable, Hashable {
    let id: String
    let text: String
    let likes: Int
    let author: Author
}

extension CommentSpecial: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        let likes = try container.decode([String].self, forKey: .likes)
        self.likes = likes.count
        text = try container.decode(String.self, forKey: .text)
        author = try container.decode(Author.self, forKey: .author)
        
    }
    
    
}

