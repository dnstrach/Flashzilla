//
//  ContentView.swift
//  Flashzilla
//
//  Created by Dominique Strachan on 1/11/24.
//

import CoreHaptics
import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    
    @State private var cards = DataManager.load()
    //@State private var cards = [Card]()
    // 10 instances of example card
   // @State private var cards = [Card](repeating: Card.example, count: 10)
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    @State private var showingEditView = false
    
    @State private var answerIsCorrect = false
    @State private var answerIsIncorrect = false
    
    var body: some View {
        // CardView(card: Card.example)
        
        ZStack {
            Color(.yellow)
                .ignoresSafeArea()
            
            VStack {
                
                Text("Time \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                ZStack {
                    ForEach(cards) { card in
                        // find card through indices
                   // ForEach(0..<cards.count, id: \.self) { index in
                        //find card by giving its index
                        let index = cards.firstIndex(of: card)!
                        
                        CardView(card: cards[index]) { reinsert in
                            withAnimation {
                                removeCards(at: index, reinsert: reinsert)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibilityHidden(index < cards.count - 1)
                    }
                    .allowsHitTesting(timeRemaining > 0)
                    
                    if cards.isEmpty {
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                        
                    }
                }
                
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditView = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || voiceOverEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            answerIsIncorrect = true
                            
                            withAnimation {
                                removeCards(at: cards.count - 1, reinsert: true)
                            }
                            
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect")
                        .sensoryFeedback(.error, trigger: answerIsIncorrect)
                        
                        
                        Spacer()
                        
                        Button {
                            answerIsCorrect = true
                            
                            withAnimation {
                                removeCards(at: cards.count - 1, reinsert: false)
                            }
                            
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct")
                        .sensoryFeedback(.success, trigger: answerIsCorrect)
                        
                        /* // before voice over enabled
                         Image(systemName: "xmark.circle")
                         .padding()
                         .background(.black.opacity(0.7))
                         .clipShape(Circle())
                         Spacer()
                         Image(systemName: "checkmark.circle")
                         .padding()
                         .background(.black.opacity(0.7))
                         .clipShape(Circle())
                         */
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if !cards.isEmpty {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditView, onDismiss: resetCards, content: EditCards.init)
        /*
        .sheet(isPresented: $showingEditView, onDismiss: resetCards) {
            EditCards()
        }
         */
        .onAppear(perform: resetCards)
    }
    
//    func loadData() {
//        if let data = UserDefaults.standard.data(forKey: "Cards") {
//            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
//                cards = decoded
//            }
//        }
//    }
    
    func removeCards(at index: Int, reinsert: Bool) {
        guard index >= 0 else { return }
        
        if reinsert {
            cards.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
        } else {
            cards.remove(at:  index)
        }
        
        //cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
        
        answerIsCorrect = false
        answerIsIncorrect = false
    }
    
    func resetCards() {
        // cards = [Card](repeating: Card.example, count: 10)
        timeRemaining = 100
        isActive = true
        cards = DataManager.load()
        //loadData()
    }
}

#Preview {
    ContentView()
}
