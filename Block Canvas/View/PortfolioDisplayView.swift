//
//  PortfolioDisplayView.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import SwiftUI
import Combine
import Foundation
import Kingfisher

struct PortfolioDisplay: View {
    
    var nftInfoForDisplay: [NFTInfoForDisplay]
    var onARButtonTap: ((URL) -> Void)?
    @State private var selectedImageURL: URL?
    
    var body: some View {
        GeometryReader { outerGeometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 330) {
                    ForEach(nftInfoForDisplay, id: \.url) { nftInfo in
                        GeometryReader { geometry in
                            VStack(alignment: .leading, spacing: 12) {
                                Button(action: {
                                    selectedImageURL = nftInfo.url
                                    onARButtonTap?(nftInfo.url)
                                }) {
                                    HStack {
                                        Image(systemName: "eye.fill")
                                        Text("View in AR")
                                            .font(.body)
                                    }
                                }
                                .frame(width: 140, height: 16, alignment: .center)
                                .foregroundColor(Color(uiColor: .secondary))
                                
                                KFImage(nftInfo.url)
                                    .placeholder {
                                        Image(systemName: "circle.dotted")
                                            .font(.largeTitle)
                                            .opacity(0.5)
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 400, alignment: .center)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
                                    .rotation3DEffect(Angle(degrees: (Double(geometry.frame(in: .global).minX) - 210) / -18), axis: (x: 0, y: 1.0, z: 0))
                                
                                ScrollView(showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(nftInfo.title)
                                            .frame(width: 300, alignment: .leading)
                                            .font(.headline)
                                            .font(.system(size: 20))
                                            .lineLimit(nil)
                                            .foregroundColor(Color(uiColor: .tertiary))
                                        
                                        Text(nftInfo.artist)
                                            .frame(width: 300, alignment: .leading)
                                            .font(.subheadline)
                                            .font(.system(size: 18))
                                            .lineLimit(nil)
                                            .foregroundColor(Color(uiColor: .secondaryBlur))
                                        
                                        Text(nftInfo.description)
                                            .frame(width: 300, alignment: .leading)
                                            .font(.caption)
                                            .font(.system(size: 14))
                                            .lineLimit(nil)
                                            .foregroundColor(Color(uiColor: .secondary))
                                        
                                        Text(nftInfo.contract)
                                            .frame(width: 300, alignment: .leading)
                                            .font(.footnote)
                                            .font(.system(size: 14))
                                            .lineLimit(nil)
                                            .foregroundColor(Color(uiColor: .secondary))
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(width: (outerGeometry.size.width / 2) - 150)
                }
                .padding(.horizontal, 150)
                .padding(.top, 10)
            }
            .background(Color.init(uiColor: .primary))
        }
    }
}
