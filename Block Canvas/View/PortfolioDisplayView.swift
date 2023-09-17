//
//  PortfolioDisplayView.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    
    func load(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct ImageView: View {
    @StateObject private var loader = ImageLoader()
    let url: URL
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loader.load(from: url)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

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
                                Button("View in AR") {
                                                selectedImageURL = nftInfo.url
                                                onARButtonTap?(nftInfo.url)
                                }.frame(width: 120, alignment: .center)
                                    .foregroundColor(.gray)
                                ImageView(url: nftInfo.url)
                                    .frame(width: 300, height: 450, alignment: .center)
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
                                        
                                        Text("Artist: \(nftInfo.artist)")
                                            .frame(width: 300, alignment: .leading)
                                            .font(.subheadline)
                                            .font(.system(size: 16))
                                            .lineLimit(nil)
                                        
                                        Text(nftInfo.description)
                                            .frame(width: 300, alignment: .leading)
                                            .font(.caption)
                                            .font(.system(size: 12))
                                            .lineLimit(nil)
                                        
                                        Text("Contract: \(nftInfo.contract)")
                                            .frame(width: 300, alignment: .leading)
                                            .font(.footnote)
                                            .font(.system(size: 12))
                                            .lineLimit(nil)
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
        }
    }
}
