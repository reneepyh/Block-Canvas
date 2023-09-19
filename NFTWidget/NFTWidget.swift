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
    let contract: String
}

struct Provider: IntentTimelineProvider {
    typealias Intent = SelectNFTIntent
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SelectNFTIntent(), nftInfo: NFTInfoForWidget(url: URL(string: "https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=1024x1024&w=is&k=20&c=5aen6wD1rsiMZSaVeJ9BWM4GGh5LE_9h97haNpUQN5I=")!, title: "", artist: "", description: "", contract: ""))
    }
    
    func getSnapshot(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, nftInfo: NFTInfoForWidget(url: URL(string: "https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=1024x1024&w=is&k=20&c=5aen6wD1rsiMZSaVeJ9BWM4GGh5LE_9h97haNpUQN5I=")!, title: "", artist: "", description: "", contract: ""))
        completion(entry)
    }
    
    func getTimeline(for configuration: SelectNFTIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.reneehsu.Block-Canvas")
        print(sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data)
        if let savedData = sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data {
            print(savedData)
            let decoder = JSONDecoder()
            if let loadedNFTInfo = try? decoder.decode([NFTInfoForWidget].self, from: savedData) {
                let filteredNFTInfo: [NFTInfoForWidget]
                print(loadedNFTInfo)
                if let nftName = configuration.NFTName {
                    filteredNFTInfo = loadedNFTInfo.filter { $0.title == nftName }
                } else {
                    filteredNFTInfo = []
                }
                
                let entry = SimpleEntry(date: Date(), configuration: configuration, nftInfo: filteredNFTInfo.first)
                print(configuration)
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
        if let nftInfo = entry.nftInfo,
           let imageData = try? Data(contentsOf: nftInfo.url),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Text("Please select an NFT to display")
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
        .description("This widget shows NFTs.")
    }
}

struct NFTWidget_Previews: PreviewProvider {
    static var previews: some View {
        NFTWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: SelectNFTIntent(), nftInfo: NFTInfoForWidget(url: URL(string: "https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=1024x1024&w=is&k=20&c=5aen6wD1rsiMZSaVeJ9BWM4GGh5LE_9h97haNpUQN5I=")!, title: "", artist: "", description: "", contract: "")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
