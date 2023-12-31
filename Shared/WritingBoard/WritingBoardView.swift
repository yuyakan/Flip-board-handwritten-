//
//  WritingBoardView.swift
//  Flip board -handwritten-
//
//  Created by 上別縄祐也 on 2023/11/17.
//

import SwiftUI
import PencilKit
import StoreKit

struct WritingBoardView: View {
    @Environment(\.undoManager) private var undoManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var pencilKitViewController = PencilKitViewController()
    @State var pkCanvasView = PKCanvasView()
    @State var isEditModeVisible = false
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let width = Double(bounds.width)
            
        VStack(spacing: 0){
            Spacer()
            HStack{
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName:"square.stack.3d.up")
                        .font(.system(size: 24))
                        .rotationEffect(Angle.degrees(180))
                        .padding(.leading, 6)
                })
                Spacer()
                Button(action: {
                    undoManager?.undo()
                }, label: {
                    Image(systemName:"arrow.uturn.backward.circle")
                        .font(.system(size: 26))
                        .rotationEffect(Angle.degrees(90))
                })
                Button(action: {
                    undoManager?.redo()
                }, label: {
                    Image(systemName:"arrow.uturn.forward.circle")
                        .font(.system(size: 26))
                        .rotationEffect(Angle.degrees(90))
                })
                if isEditModeVisible {
                    Button(action: {
                        pencilKitViewController.register(pkCanvasView)
                        requestReview()
                        isEditModeVisible = false
                    }, label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24))
                            .frame(width: 34)
                            .rotationEffect(Angle.degrees(90))
                            .padding(.trailing, 6)
                    })
                } else {
                    Button(action: {
                        pencilKitViewController.unregister()
                        isEditModeVisible = true
                    }, label: {
                        Image(systemName: "display")
                            .font(.system(size: 24))
                            .rotationEffect(Angle.degrees(90))
                            .padding(.trailing, 6)
                    })
                }
            }
            .padding(.top, 10)
            Spacer()
            ZStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: width > 700 ? width : width * 1.5)
                CanvasView(pkcanvasview: self.$pkCanvasView)
                    .frame(height: width > 700 ? width : width * 1.5)
            }
            Spacer()
            Text("").frame(height: 50)
        }
        .onAppear {
            pencilKitViewController.register(pkCanvasView)
        }
        .onDisappear {
            pencilKitViewController.unregister()
        }
    }
}
