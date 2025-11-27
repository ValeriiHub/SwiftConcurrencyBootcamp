//
//  RefreshableBootcamp15.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 27.11.2025.
//

import SwiftUI

final class RefreshableDataService {
    
    func getData() async throws -> [String] {
        ["Apple", "Banana", "Orange", "Pineapple"].shuffled()
    }
}

@MainActor
final class RefreshableBootcampViewModel: ObservableObject {
    
    @Published private(set) var items: [String] = []
    
    private let manager = RefreshableDataService()
    
    func loadData() async {
        do {
            items = try await manager.getData()
        } catch  {
            print(error)
        }
    }
}

struct RefreshableBootcamp15: View {
    
    @StateObject private var viewModel = RefreshableBootcampViewModel()
    
    
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.items, id: \.self) { item in
                    Text(item)
                        .font(.headline)
                }
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    RefreshableBootcamp15()
}
