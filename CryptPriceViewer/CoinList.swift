//
//  ContentView.swift
//  CryptPriceViewer
//
//  Created by jc on 2020-09-03.
//  Copyright © 2020 jc. All rights reserved.
//

import SwiftUI
import Combine

struct CoinList: View {
    @ObservedObject private var viewModel = CoinListViewModel()
    
    var body: some View {
        Text("\(viewModel.coinViewModels.description)")
            .onAppear {
                self.viewModel.fetchCoins()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CoinList()
    }
}

class CoinListViewModel : ObservableObject {
    private let cryptoService = CryptoService()
    
    @Published var coinViewModels = [CoinViewModel]()
    
    var cancellable: AnyCancellable?
    
    func fetchCoins() {
        cancellable = cryptoService.fetchCoins().sink(receiveCompletion: { (_) in
            
        }, receiveValue: { (response) in
            self.coinViewModels = response.data.coins.map { CoinViewModel(model: $0)}
        })
    }
    
}

struct CoinViewModel {
    let name: String
    let price: String
    
    init(model: Coin) {
        self.name = model.name
        self.price = model.price
    }
}


class CryptoService {
    func fetchCoins() -> AnyPublisher<CryptoResponse, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://api.coinranking.com/v1/public/coins?base=USD&timePeriod=24h")!)
            .map{ $0.data }
            .decode(type: CryptoResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct CryptoResponse : Codable {
    let data: CryptoData
    let status: String
}

struct CryptoData : Codable {
    let coins: [Coin]
}

struct Coin : Codable {
    let name: String
    let price: String
}
