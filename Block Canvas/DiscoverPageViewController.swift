//
//  ViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/13.
//

import UIKit
import Apollo

class DiscoverPageViewController: UIViewController {
    let apolloClient = ApolloClient(url: URL(string: "https://api.fxhash.xyz/graphql")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        apolloClient.fetch(query: GetTrending.GetTrendingQuery()) { result in
            guard let data = try? result.get().data else { return }
            print(data.randomTopGenerativeToken.displayUri)
            print(data.randomTopGenerativeToken.author.name)
            print(data.randomTopGenerativeToken.name)
        }
    }

}
