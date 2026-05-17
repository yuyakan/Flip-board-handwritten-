//
//  TextOverlayView.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2024/01/01.
//

import SwiftUI

// MARK: - FocusedValueKey（ツールバーの＋ボタン制御用）

struct MyFocusedDataKey: FocusedValueKey {
    typealias Value = Bool
}

extension FocusedValues {
    var myBoolData: MyFocusedDataKey.Value? {
        get { self[MyFocusedDataKey.self] }
        set { self[MyFocusedDataKey.self] = newValue }
    }
}

// MARK: - TextElementModel

struct TextElementModel: Identifiable {
    let id = UUID()
    var text: String = ""
    var color: Color = .yellow
    var fontSelection: Int = 1
    var position: CGPoint = CGPoint(x: 150, y: 150)
    var scale: CGFloat = 1.0
}

// MARK: - TextOverlayView

struct TextOverlayView: View {
    @Binding var element: TextElementModel
    var isInteractive: Bool
    var onDelete: () -> Void

    @FocusState private var isActive: Bool
    @State private var lastMagnification: CGFloat = 1.0
    @State private var location: CGPoint = .zero

    private let fonts: [Font.Design] = [.default, .rounded, .serif, .monospaced]
    private let weights: [Font.Weight] = [.light, .black, .regular, .bold]
    private let baseSize: CGFloat = 60.0

    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $element.text)
                .focused($isActive, equals: true)
                .focusedValue(\.myBoolData, isActive)
                .font(.system(size: baseSize, weight: weights[element.fontSelection], design: fonts[element.fontSelection]))
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(element.color)
                .disabled(!isInteractive)

            if isInteractive && isActive {
                editingControls
                    .transition(.opacity)
            }
        }
        .scaleEffect(element.scale)
        .position(location)
        .highPriorityGesture(dragGesture)
        .gesture(magnificationGesture)
        .allowsHitTesting(isInteractive)
        .onAppear {
            location = element.position
            if isInteractive {
                isActive = true
            }
        }
    }

    // MARK: Editing controls (visible when active in text mode)
    private var editingControls: some View {
        HStack(spacing: 8) {
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.red)
            }
            Spacer()
            ColorPicker("", selection: $element.color)
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
        let isSelected = element.fontSelection == index
        return Button(action: { element.fontSelection = index }) {
            Text("Aa")
                .font(.system(size: 20, weight: fontWeights[index], design: fontDesigns[index]))
                .foregroundColor(isSelected ? .white : element.color)
                .frame(width: 30, height: 30)
                .background(isSelected ? element.color : Color.clear)
                .cornerRadius(5)
        }
    }

    // MARK: Gestures
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                location = value.location
            }
            .onEnded { value in
                location = value.location
                element.position = value.location
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastMagnification
                element.scale = max(0.3, element.scale * delta)
                lastMagnification = value
            }
            .onEnded { _ in
                lastMagnification = 1.0
            }
    }
}
