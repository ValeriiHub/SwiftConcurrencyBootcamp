//
//  AsyncPublisherBootcamp12.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 21.11.2025.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Cherry")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
    }
}

final class AsyncPublisherBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    private let dataManager = AsyncPublisherDataManager()
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        addSubscribers()
    }
    
    /* standart Combine
     
    func addSubscribers() {
        dataManager.$myData
            .receive(on: DispatchQueue.main)
            .sink { dataArray in
                self.dataArray = dataArray
            }
            .store(in: &cancellables)
    }
     */
    
    func addSubscribers() {
        Task {
            for await value in dataManager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
        // для другого подписчика нужно создавать отдельную Task
//        Task {
//            for await value in dataManager.$myData.values {
//                await MainActor.run {
//                    self.dataArray = value
//                }
//            }
//        }
    }
    
    func start() async {
        await dataManager.addData()
    }
}

struct AsyncPublisherBootcamp12: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { text in
                    Text(text)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp12()
}
