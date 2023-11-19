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
    @State var isShowBoardView = [false, false, false, false, false, false, false, false, false, false, false, false]
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    var body: some View {
        let selectImage = ["selectwhite", "brackboard", "manga", "book", "sky", "star", "brick", "brackboard2", "color", "brick2", "wall", "sky2"]
        let backImage = ["selectwhite", "brackboard", "manga", "book", "sky", "star", "brick", "brackboard2", "color", "brick2", "wall", "sky2"]
        NavigationView{
            ZStack {
                HStack {
                    AdView().frame(width: 320, height: 50).rotationEffect(Angle(degrees: 90))
                    Text("").frame(width: width - 90)
                }
                HStack{
                    Spacer()
                    Text("").frame(width: 50)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(0...10, id: \.self) { index in
                                GeometryReader { geometry in
                                    NavigationLink(destination:
                                                    WritingBoardView(imageName: backImage[index])
                                                        .navigationBarTitleDisplayMode(.inline)
                                                        .navigationBarHidden(true)
                                                        .navigationBarBackButtonHidden(true),
                                                   isActive: $isShowBoardView[index]
                                    ) { EmptyView() }
                                    Image("\(selectImage[index])")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.height / 1.4)
                                        .rotation3DEffect(Angle(degrees: (Double(geometry.frame(in: .global).minY) - height/2.4) / -8), axis: (x: -5, y: 0, 0))
                                        .onTapGesture {
                                            interstitial.presentInterstitial(isShow: &isShowBoardView[index])
                                        }
                                    
                                }
                                .frame(height: width/2)
                            }
                        }.padding(.leading, 10)
                    }
                    .frame(width: width/2)
                    Text(LocalizedStringKey("choose"))
                        .fixedSize(horizontal: true, vertical: false)
                        .lineLimit(1)
                        .frame(width: width / 10)
                        .font(.largeTitle)
                        .rotationEffect(Angle.degrees(90))
                        .padding(.trailing, 10)
                    Text("").frame(width: 30)
                    Spacer()
                }
                .onAppear() {
                    interstitial.loadInterstitial()
                }
                .navigationBarHidden(true)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
