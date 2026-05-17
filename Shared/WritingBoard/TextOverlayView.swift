//
//  TextOverlayView.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2024/01/01.
//

import SwiftUI

// MARK: - TextElementModel

struct TextElementModel: Identifiable {
    let id = UUID()
}

// MARK: - TextOverlayView

struct TextOverlayView: View, Identifiable {
    let id: UUID
    var isInteractive: Bool
    var onDelete: () -> Void

    @State private var location: CGPoint = CGPoint(x: 200, y: 150)
    @State private var text: String = ""
    @State private var color: Color = .yellow
    @State private var fontSelection: Int = 1
    @State private var scale: CGFloat = 1.0
    @State private var lastMagnification: CGFloat = 1.0
    @FocusState private var isActive: Bool

    private let fonts: [Font.Design] = [.default, .rounded, .serif, .monospaced]
    private let weights: [Font.Weight] = [.light, .black, .regular, .bold]
    private let baseSize: CGFloat = 60.0

    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $text)
                .focused($isActive, equals: true)
                .font(.system(size: baseSize, weight: weights[fontSelection], design: fonts[fontSelection]))
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(color)
                .disabled(!isInteractive)
                .onTapGesture {
                    if isInteractive {
                        isActive = true
                    }
                }

            editingControls
                .opacity(isInteractive && isActive ? 1 : 0)
                .allowsHitTesting(isInteractive && isActive)
        }
        .scaleEffect(scale)
        .position(location)
        .highPriorityGesture(dragGesture)
        .simultaneousGesture(magnificationGesture)
        .allowsHitTesting(isInteractive)
        .onAppear {
            if isInteractive {
                isActive = true
            }
        }
    }

    // MARK: Editing controls
    private var editingControls: some View {
        HStack(spacing: 8) {
            Button {
                isActive = false
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.red)
            }
            Spacer()
            ColorPicker("", selection: $color)
                .labelsHidden()
                .frame(width: 32, height: 32)
            fontButton(index: 0)
            fontButton(index: 1)
            fontButton(index: 2)
            fontButton(index: 3)
        }
        .padding(.top, 6)
        .frame(width: 220)
    }

    private func fontButton(index: Int) -> some View {
        let fontDesigns: [Font.Design] = [.default, .rounded, .serif, .monospaced]
        let fontWeights: [Font.Weight] = [.light, .black, .regular, .bold]
        let isSelected = fontSelection == index
        return Button(action: { fontSelection = index }) {
            Text("Aa")
                .font(.system(size: 20, weight: fontWeights[index], design: fontDesigns[index]))
                .foregroundColor(isSelected ? .white : color)
                .frame(width: 30, height: 30)
                .background(isSelected ? color : Color.clear)
                .cornerRadius(5)
        }
    }

    // MARK: Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                location = value.location
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastMagnification
                scale = max(0.3, scale * delta)
                lastMagnification = value
            }
            .onEnded { _ in
                lastMagnification = 1.0
            }
    }
}
