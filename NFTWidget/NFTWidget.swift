//
//  NFTWidget.swift
//  NFTWidget
//
//  Created by Renee Hsu on 2023/9/18.
//

import WidgetKit
import SwiftUI
import Intents

struct NFTInfoForWidget: Codable {
    let url: URL
    let title: String
    let artist: String
    let description: String
}

struct Provider: IntentTimelineProvider {
    typealias Intent = SelectNFTIntent
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SelectNFTIntent(), nftInfo: NFTInfoForWidget(url: URL(string: "https://lh3.googleusercontent.com/drive-viewer/AK7aPaCru5HIxcDvIP6ZAwrIzApQE6xa0axyrB4hUfJWxHavNENmYbG86LQa9BFNKEZ94-yk7c8UuOFEetY0x0j_7pxXQ3HqZw=s1600")!, title: "", artist: "", description: ""))
    }
    
    func getSnapshot(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, nftInfo: NFTInfoForWidget(url: URL(string: "https://lh3.googleusercontent.com/drive-viewer/AK7aPaCru5HIxcDvIP6ZAwrIzApQE6xa0axyrB4hUfJWxHavNENmYbG86LQa9BFNKEZ94-yk7c8UuOFEetY0x0j_7pxXQ3HqZw=s1600")!, title: "", artist: "", description: ""))
        completion(entry)
    }
    
    func getTimeline(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.CML8K54JBW.reneehsu.Block-Canvas")
        print(sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data)
        if let savedData = sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data {
            print(savedData)
            let decoder = JSONDecoder()
            if let loadedNFTInfo = try? decoder.decode([NFTInfoForWidget].self, from: savedData) {
                let selectedNFT = configuration.NFTName?.identifier
                let filteredNFTInfo = loadedNFTInfo.filter { String(describing: $0.url) == selectedNFT }
                
                let entry = SimpleEntry(date: Date(), configuration: configuration, nftInfo: filteredNFTInfo.first)
                let timeline = Timeline(entries: [entry], policy: .never)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: SelectNFTIntent
    let nftInfo: NFTInfoForWidget?
}

struct NFTWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if let nftInfo = entry.nftInfo {
            if nftInfo.url.absoluteString == "https://lh3.googleusercontent.com/drive-viewer/AK7aPaCru5HIxcDvIP6ZAwrIzApQE6xa0axyrB4hUfJWxHavNENmYbG86LQa9BFNKEZ94-yk7c8UuOFEetY0x0j_7pxXQ3HqZw=s1600" {
                Image("placeholder")
                    .resizable()
                    .scaledToFill()
            } else if let imageData = try? Data(contentsOf: nftInfo.url),
                      let originalImage =  UIImage(data: imageData) {
                let targetWidth: CGFloat = 220
                let scaleFactor = targetWidth / originalImage.size.width
                let targetHeight = originalImage.size.height * scaleFactor
                
                let newSize = CGSize(width: targetWidth, height: targetHeight)
                let renderer = UIGraphicsImageRenderer(size: newSize)
                
                let resizedImageData = renderer.image { (context) in
                    originalImage.draw(in: CGRect(origin: .zero, size: newSize))
                }
                
                Image(uiImage: resizedImageData)
                    .resizable()
                    .scaledToFill()
            } else {
                Text("Choose an NFT to display")
            }
        } else {
            Text("Choose an NFT to display")
        }
    }
}

struct NFTWidget: Widget {
    let kind: String = "NFTWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectNFTIntent.self, provider: Provider()) { entry in
            NFTWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NFT Widget")
        .description("Choose an NFT to display.")
    }
}

struct NFTWidget_Previews: PreviewProvider {
    static var previews: some View {
        NFTWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: SelectNFTIntent(), nftInfo: NFTInfoForWidget(url: URL(string: "https://lh3.googleusercontent.com/drive-viewer/AK7aPaCru5HIxcDvIP6ZAwrIzApQE6xa0axyrB4hUfJWxHavNENmYbG86LQa9BFNKEZ94-yk7c8UuOFEetY0x0j_7pxXQ3HqZw=s1600")!, title: "", artist: "", description: "")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
