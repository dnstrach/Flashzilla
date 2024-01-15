//
//  ContentView.swift
//  Flashzilla
//
//  Created by Dominique Strachan on 1/11/24.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}

struct ContentView: View {
    // 10 instances of example card
    @State private var cards = [Card](repeating: Card.example, count: 10)
    
    var body: some View {
        // CardView(card: Card.example)
        
        ZStack {
            Color(.yellow)
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCards(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                    }
                }
            }
        }
    }
    
    func removeCards(at index: Int) {
        cards.remove(at: index)
    }
}

#Preview {
    ContentView()
}
