//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/28.
//

import SwiftUI
import GoogleMobileAds

struct SelectView: View {
    @ObservedObject var interstitial = Interstitial()
    @State var isShowBoardView = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]

    private let selectImage = ["selectwhite", "brackboard", "manga", "book", "sky", "brick", "brackboard2", "brick2", "wall", "moon", "winter", "star", "sky2", "color", "sand"]

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let screenHeight = geo.size.height
                let bannerWidth: CGFloat = 320
                let bannerHeight: CGFloat = 50
                let titleTopPadding = clamp(screenHeight * 0.10, min: 20, max: 60)
                let titleBottomPadding = clamp(screenHeight * 0.07, min: 14, max: 40)
                let bannerTopPadding = clamp(screenHeight * 0.04, min: 8, max: 24)

                VStack(spacing: 0) {
                    Text(LocalizedStringKey("choose"))
                        .font(.largeTitle)
                        .lineLimit(1)
                        .padding(.top, titleTopPadding)
                        .padding(.bottom, titleBottomPadding)

                    GeometryReader { contentGeo in
                        let contentWidth = contentGeo.size.width
                        let contentHeight = contentGeo.size.height
                        let imageHeight = contentHeight * 0.95
                        let imageWidth = imageHeight * 1.6
                        let cellSpacing = contentWidth * 0.025
                        let cellWidth = imageWidth + cellSpacing

                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: cellSpacing) {
                                    ForEach(0..<selectImage.count, id: \.self) { index in
                                        GeometryReader { itemGeo in
                                            let center = itemGeo.frame(in: .named("scroll")).midX
                                            let offset = center - contentWidth / 2
                                            let angle = max(-20, min(20, offset / -30))

                                            NavigationLink(
                                                destination:
                                                    WritingBoardView(imageName: selectImage[index])
                                                        .navigationBarTitleDisplayMode(.inline)
                                                        .navigationBarHidden(true)
                                                        .navigationBarBackButtonHidden(true),
                                                isActive: $isShowBoardView[index]
                                            ) { EmptyView() }

                                            Image("\(selectImage[index])_landscape")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: imageWidth, height: imageHeight)
                                                .rotation3DEffect(
                                                    Angle(degrees: angle),
                                                    axis: (x: 0, y: 1, z: 0)
                                                )
                                                .frame(width: itemGeo.size.width, height: itemGeo.size.height)
                                                .onTapGesture {
                                                    interstitial.presentInterstitial {
                                                        isShowBoardView[index] = true
                                                    }
                                                }
                                        }
                                        .frame(width: cellWidth, height: contentHeight)
                                        .id(index)
                                    }
                                }
                                .padding(.horizontal, (contentWidth - cellWidth) / 2)
                            }
                            .coordinateSpace(name: "scroll")
                            .onAppear {
                                proxy.scrollTo(1, anchor: .center)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)

                    AdView()
                        .frame(width: bannerWidth, height: bannerHeight)
                        .padding(.top, bannerTopPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    interstitial.loadInterstitial()
                }
                .navigationBarHidden(true)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
