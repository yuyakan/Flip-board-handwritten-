//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/28.
//

import SwiftUI
import GoogleMobileAds

struct SelectView: View {
    var body: some View {
        let upperImage = ["whiteboard", "brackboard", "manga", "book", "sky", "star"]
        let lowerImage = ["brick", "brackboard2", "color", "brick2", "wall", "sky2"]
        NavigationView{
            VStack{
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0...5, id: \.self) { index in
                                    GeometryReader { geometry in
                                        NavigationLink(destination: WritingBoardView(imageName: upperImage[index])) {
                                            Image("\(upperImage[index])")
                                            .rotation3DEffect(Angle(degrees: (Double(geometry.frame(in: .global).minX) - 150) / -8), axis: (x: 0, y: 10, 0))
                                        }
                                    }
                                    .frame(width: 180, height: 300)
                                }
                            }
                            .padding(40)
                        }
                Spacer()
                Text("Please select background").font(.largeTitle)
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0...5, id: \.self) { index in
                                    GeometryReader { geometry in
                                        NavigationLink(destination: WritingBoardView(imageName: lowerImage[index])) {
                                            Image("\(lowerImage[index])")
                                            .rotation3DEffect(Angle(degrees: (Double(geometry.frame(in: .global).minX) - 150) / -8), axis: (x: 0, y: 10, 0))
                                        }
                                    }
                                    .frame(width: 180, height: 300)
                                }
                            }
                            .padding(40)
                        }
                Spacer()
            }.navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
