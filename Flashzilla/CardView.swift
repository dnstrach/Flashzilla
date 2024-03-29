//
//  CardView.swift
//  Flashzilla
//
//  Created by Dominique Strachan on 1/13/24.
//

import SwiftUI

// extension func instead of ternary within ternary
extension Shape {
    func fill(using offset: CGSize) -> some View {
        if offset.width == 0 {
            return self.fill(.white)
        } else if offset.width < 0 {
            return self.fill(.red)
        } else {
            return self.fill(.green)
        }
    }
}

struct CardView: View {
    let card: Card
    // added bool param to track whether card is correct and should be removed
    var removal: ((Bool) -> Void)? = nil
    // var removal: (() -> Void)? = nil
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                    ? .white
                    : .white
                    // one red or green is shown immediately when dragging
                        .opacity(1 - Double(abs(offset.width / 50))))
                .background(
                    differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(using: offset)
                    // too ternary --> confusing reading code
                    //.fill(offset.width == 0 ? .white : offset.width > 0 ? .green : .red)
                    // bug - when springing back into place card is red when supposed to be green
                    //.fill(offset.width > 0 ? .green : .red)
                )
                .shadow(radius: 10)
            
            VStack {
                if voiceOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.question)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                } else {
                    Text(card.question)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        // smallest iphone has landscape of 480 points
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width/5)))
        .offset(x: offset.width * 5, y: 0)
        // absolute value since we don't care if value is + or -
        // subtracting from 2 so that opacity isn't show right away when dragging
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    feedback.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        if offset.width > 0 {
                            feedback.notificationOccurred(.success)
                            removal?(false)
                        } else {
                            feedback.notificationOccurred(.error)
                            removal?(true)
                            offset = .zero
                        }
                        
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.spring(), value: offset)
    }
}

#Preview {
    CardView(card: Card.example)
}
