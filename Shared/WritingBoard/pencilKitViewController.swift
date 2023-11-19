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
    let pktoolpicker = PKToolPicker()
 
    func makeUIView(context: Context) -> PKCanvasView {
        self.pkcanvasview.isOpaque = false
        self.pkcanvasview.backgroundColor = .clear
        self.pkcanvasview.overrideUserInterfaceStyle = .light
        self.pktoolpicker.addObserver(pkcanvasview)
        self.pktoolpicker.setVisible(true, forFirstResponder: pkcanvasview)
        self.pkcanvasview.becomeFirstResponder()
        return pkcanvasview
    }
     
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}
 
class PencilKitViewController: ObservableObject {
    var pkCanvasView: PKCanvasView?
    let pkToolPicker = PKToolPicker()
 
    func register(_ pkCanvasView: PKCanvasView) {
        self.pkCanvasView = pkCanvasView
        pkToolPicker.setVisible(true, forFirstResponder: pkCanvasView)
        pkToolPicker.addObserver(pkCanvasView)
    }

    func unregister() {
        guard let canvasView = self.pkCanvasView else { return }
        pkToolPicker.setVisible(false, forFirstResponder: canvasView)
        pkToolPicker.removeObserver(canvasView)
        self.pkCanvasView = nil
    }
}
