//
//  pencilKitViewController.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2022/05/17.
//

import SwiftUI
import PencilKit
 
struct PencilKitViewControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PencilKitViewController {
        return PencilKitViewController()
    }
 
    func updateUIViewController(_ controller: PencilKitViewController, context: Context) {}
}
 
class PencilKitViewController: UIViewController {
    var pkcanvasview: PKCanvasView?
    let pktoolpicker = PKToolPicker()
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.pkcanvasview = PKCanvasView(frame: .zero)
        if let view = self.pkcanvasview {
            view.isOpaque = false
            view.backgroundColor = .clear
            view.overrideUserInterfaceStyle = .light
            self.pktoolpicker.addObserver(view)
            self.pktoolpicker.setVisible(true, forFirstResponder: view)
            view.becomeFirstResponder()
            self.view = view
        }
    }
}
