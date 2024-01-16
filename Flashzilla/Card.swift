//
//  Card.swift
//  Flashzilla
//
//  Created by Dominique Strachan on 1/13/24.
//

import Foundation

struct Card: Codable, Identifiable, Equatable {
    var id = UUID()
    let question: String
    let answer: String
    
    static let example = Card(question: "Who played the 13th doctor in Doctor Who?", answer: "Jodie Whittaker")
}
