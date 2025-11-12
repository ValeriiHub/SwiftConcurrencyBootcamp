//
//  GlobalActorBootcamp10.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 12.11.2025.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
    
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    
    func getDataFromDataBase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five"]
    }
}

final class GlobalActorBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    private let dataManager = MyFirstGlobalActor.shared
        
    @MyFirstGlobalActor func getData() {
        
        // do something
        
//        let data = await dataManager.getDataFromDataBase()
//        await MainActor.run {
//            dataArray = data
//        }
        
        Task {
            let data = await dataManager.getDataFromDataBase()
            dataArray = data
        }
    }
}

struct GlobalActorBootcamp10: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { text in
                    Text(text)
                        .font(.headline)
                }
            }
        }
//        .task {
//            await viewModel.getData()
//        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorBootcamp10()
}
