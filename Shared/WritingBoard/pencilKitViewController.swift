//
//  pencilKitViewController.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2022/05/17.
//

import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var pkcanvasview: PKCanvasView
    @Binding var isInteractionEnabled: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        pkcanvasview.isOpaque = false
        pkcanvasview.backgroundColor = .clear
        pkcanvasview.drawingPolicy = .anyInput
        pkcanvasview.isScrollEnabled = false
        pkcanvasview.panGestureRecognizer.isEnabled = false
        pkcanvasview.pinchGestureRecognizer?.isEnabled = false
        pkcanvasview.drawingGestureRecognizer.isEnabled = isInteractionEnabled
        clearBackground(pkcanvasview)
        pkcanvasview.becomeFirstResponder()
        return pkcanvasview
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isOpaque = false
        uiView.backgroundColor = .clear
        uiView.drawingPolicy = .anyInput
        uiView.isScrollEnabled = false
        uiView.panGestureRecognizer.isEnabled = false
        uiView.pinchGestureRecognizer?.isEnabled = false
        uiView.drawingGestureRecognizer.isEnabled = isInteractionEnabled
        clearBackground(uiView)
        uiView.isUserInteractionEnabled = isInteractionEnabled
    }

    private func clearBackground(_ view: UIView) {
        view.isOpaque = false
        view.backgroundColor = .clear
        view.subviews.forEach { clearBackground($0) }
    }
}

enum PenKind: CaseIterable {
    case pen, fountainPen, monoline, pencil, crayon, marker, watercolor, eraser

    var iconName: String {
        switch self {
        case .pen: return "pencil.tip"
        case .fountainPen: return "pencil.and.outline"
        case .monoline: return "line.diagonal"
        case .pencil: return "pencil"
        case .crayon: return "scribble"
        case .marker: return "highlighter"
        case .watercolor: return "drop.fill"
        case .eraser: return "eraser"
        }
    }

    func makeTool(color: UIColor, width: CGFloat) -> PKTool {
        switch self {
        case .pen:
            return PKInkingTool(.pen, color: color, width: width)
        case .marker:
            return PKInkingTool(.marker, color: color, width: width)
        case .pencil:
            return PKInkingTool(.pencil, color: color, width: width)
        case .fountainPen:
            return PKInkingTool(.fountainPen, color: color, width: width)
        case .monoline:
            return PKInkingTool(.monoline, color: color, width: width)
        case .watercolor:
            return PKInkingTool(.watercolor, color: color, width: width)
        case .crayon:
            return PKInkingTool(.crayon, color: color, width: width)
        case .eraser:
            return PKEraserTool(.vector)
        }
    }
}

class PencilKitViewController: ObservableObject {
    var pkCanvasView: PKCanvasView?

    func register(_ pkCanvasView: PKCanvasView) {
        self.pkCanvasView = pkCanvasView
        pkCanvasView.becomeFirstResponder()
    }

    func unregister() {
        self.pkCanvasView = nil
    }

    func apply(kind: PenKind, color: UIColor, width: CGFloat) {
        pkCanvasView?.tool = kind.makeTool(color: color, width: width)
    }
}
