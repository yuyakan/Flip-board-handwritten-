//
//  WritingBoardView.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2023/11/17.
//

import SwiftUI
import PencilKit
import StoreKit

// MARK: - Board Mode

enum BoardMode {
    case draw, text, display
}

// MARK: - WritingBoardView

struct WritingBoardView: View {
    @Environment(\.undoManager) private var undoManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var pencilKitViewController = PencilKitViewController()
    @State private var pkCanvasView: PKCanvasView = {
        let canvas = PKCanvasView()
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        return canvas
    }()
    @State private var boardMode: BoardMode = .draw
    @State private var textElements: [TextElementModel] = []
    @State private var customBackground: UIImage?
    @State private var isShowingPhotoPicker = false
    @State private var penKind: PenKind = .monoline
    @State private var penColor: Color = .black
    @State private var penWidth: CGFloat = 5
    @State private var isPenKindExpanded: Bool = false

    private let imageName: String?
    private let initialCustomBackground: UIImage?

    init(imageName: String) {
        self.imageName = imageName
        self.initialCustomBackground = nil
    }

    init(customBackground: UIImage) {
        self.imageName = nil
        self.initialCustomBackground = customBackground
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            if isLandscape {
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        sideToolbar
                            .padding(.leading, geo.safeAreaInsets.leading)
                        canvasArea(isLandscape: true)
                    }
                    Group {
                        switch boardMode {
                        case .draw:
                            penPalette
                        case .text:
                            addTextButton
                        case .display:
                            EmptyView()
                        }
                    }
                    .padding(.trailing, max(geo.safeAreaInsets.trailing, 8))
                }
                .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                       height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom)
                .offset(x: -geo.safeAreaInsets.leading, y: -geo.safeAreaInsets.top)
            } else {
                VStack(spacing: 0) {
                    topToolbar
                    canvasArea(isLandscape: false)
                }
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .onAppear {
            customBackground = initialCustomBackground
            pencilKitViewController.register(pkCanvasView)
            applyPenTool()
        }
        .onDisappear {
            pencilKitViewController.unregister()
        }
        .onChange(of: boardMode) { _, newMode in
            switch newMode {
            case .draw:
                pencilKitViewController.register(pkCanvasView)
                applyPenTool()
            case .text, .display:
                pencilKitViewController.unregister()
            }
        }
        .onChange(of: penKind) { applyPenTool() }
        .onChange(of: penColor) { applyPenTool() }
        .onChange(of: penWidth) { applyPenTool() }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPickerView(selectedImage: $customBackground)
        }
    }

    private func applyPenTool() {
        pencilKitViewController.apply(
            kind: penKind,
            color: UIColor(penColor),
            width: penWidth
        )
    }

    // MARK: - Top Toolbar（縦向き・上部水平）

    private var topToolbar: some View {
        HStack(spacing: 4) {
            Button(action: { dismiss() }) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 22))
                    .rotationEffect(.degrees(90))
            }
            .padding(.leading, 8)

            Divider().frame(height: 22).padding(.horizontal, 4)

            Button(action: { undoManager?.undo() }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 20))
                    .rotationEffect(.degrees(90))
            }
            .disabled(boardMode == .display)

            Button(action: { undoManager?.redo() }) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 20))
                    .rotationEffect(.degrees(90))
            }
            .disabled(boardMode == .display)

            Spacer()

            HStack(spacing: 0) {
                modeButton(icon: "pencil.tip", mode: .draw, rotation: 90)
                modeButton(icon: "character.cursor.ibeam", mode: .text, rotation: 90)
                modeButton(icon: "eye", mode: .display, rotation: 90)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())

            Spacer()

            Button(action: { isShowingPhotoPicker = true }) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 22))
                    .rotationEffect(.degrees(90))
            }

            if boardMode == .text {
                Button(action: addTextElement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .rotationEffect(.degrees(90))
                }
                .padding(.trailing, 8)
            } else {
                Color.clear.frame(width: 30, height: 30).padding(.trailing, 8)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(.ultraThinMaterial)
        .foregroundStyle(Color(.label))
    }

    // MARK: - Side Toolbar（横向き・左端縦置き）

    private var sideToolbar: some View {
        VStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 22))
            }
            .padding(.top, 8)

            Divider().frame(width: 22)

            Button(action: { undoManager?.undo() }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 20))
            }
            .disabled(boardMode == .display)

            Button(action: { undoManager?.redo() }) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 20))
            }
            .disabled(boardMode == .display)

            Spacer()

            VStack(spacing: 0) {
                modeButton(icon: "pencil.tip", mode: .draw)
                modeButton(icon: "character.cursor.ibeam", mode: .text)
                modeButton(icon: "eye", mode: .display)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())

            Spacer()

            Button(action: { isShowingPhotoPicker = true }) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 22))
            }

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, 8)
        .frame(width: 60)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .foregroundStyle(Color(.label))
    }

    // MARK: - Canvas Area

    @ViewBuilder
    private func canvasArea(isLandscape: Bool) -> some View {
        GeometryReader { geo in
            ZStack {
                if isLandscape {
                    if let img = customBackground {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .offset(x: -50)
                    } else if let name = imageName {
                        Image("\(name)_landscape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .offset(x: -50)
                    }
                } else {
                    let canvasHeight: CGFloat = geo.size.width > 700 ? geo.size.width : geo.size.width * 1.5
                    if let img = customBackground {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: canvasHeight)
                            .clipped()
                    } else if let name = imageName {
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: canvasHeight)
                    }
                }

                CanvasView(
                    pkcanvasview: $pkCanvasView,
                    isInteractionEnabled: .constant(boardMode == .draw)
                )
                .allowsHitTesting(boardMode == .draw)

                ForEach(textElements) { element in
                    let elementID = element.id
                    TextOverlayView(
                        id: elementID,
                        isInteractive: boardMode == .text,
                        onDelete: {
                            DispatchQueue.main.async {
                                textElements.removeAll { $0.id == elementID }
                            }
                        }
                    )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea(edges: isLandscape ? .all : [])
    }

    // MARK: - Add Text Button（横向き・右端、textモード時のみ）

    private var addTextButton: some View {
        Button(action: addTextElement) {
            VStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                Text("追加")
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .foregroundStyle(Color(.label))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    // MARK: - Pen Palette（横向き・右端、drawモード時のみ）

    private var penPalette: some View {
        HStack(alignment: .top, spacing: 8) {
            if isPenKindExpanded {
                penKindList
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            VStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPenKindExpanded.toggle()
                    }
                } label: {
                    Image(systemName: penKind.iconName)
                        .font(.system(size: 20))
                        .padding(8)
                        .foregroundStyle(Color(.systemBackground))
                        .background(Color(.label))
                        .clipShape(Circle())
                }

                Divider().frame(width: 28)

                ColorPicker("", selection: $penColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 32, height: 32)
                    .disabled(penKind == .eraser)
                    .opacity(penKind == .eraser ? 0.3 : 1)

                VStack(spacing: 4) {
                    ForEach([CGFloat(2), 5, 10, 18], id: \.self) { w in
                        Button {
                            penWidth = w
                        } label: {
                            Circle()
                                .fill(penKind == .eraser ? Color(.systemGray) : penColor)
                                .frame(width: w + 6, height: w + 6)
                                .padding(6)
                                .background(
                                    Circle()
                                        .fill(penWidth == w ? Color(.label).opacity(0.15) : Color.clear)
                                )
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(width: 56)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .foregroundStyle(Color(.label))
    }

    private var penKindList: some View {
        VStack(spacing: 12) {
            ForEach(PenKind.allCases, id: \.self) { kind in
                penKindButton(kind)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(width: 48)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func penKindButton(_ kind: PenKind) -> some View {
        let isActive = penKind == kind
        return Button {
            penKind = kind
            withAnimation(.easeInOut(duration: 0.2)) {
                isPenKindExpanded = false
            }
        } label: {
            Image(systemName: kind.iconName)
                .font(.system(size: 18))
                .padding(6)
                .foregroundStyle(isActive ? Color(.systemBackground) : Color(.label))
                .background(isActive ? Color(.label) : Color.clear)
                .clipShape(Circle())
        }
    }

    // MARK: - Mode Button

    private func modeButton(icon: String, mode: BoardMode, rotation: Double = 0) -> some View {
        let isActive = boardMode == mode
        return Button(action: { boardMode = mode }) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .rotationEffect(.degrees(rotation))
                .padding(10)
                .foregroundStyle(isActive ? Color(.systemBackground) : Color(.label))
                .background(isActive ? Color(.label) : Color.clear)
                .clipShape(Circle())
        }
    }

    // MARK: - Helpers

    private func addTextElement() {
        textElements.append(TextElementModel())
    }
}
