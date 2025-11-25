//
//  StrongSelfBootcamp13.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 25.11.2025.
//

import SwiftUI

final class StrongSelfDataService {
    
    func getdata() async -> String {
        "Updated data"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    
    @Published var data: String = "Some title"
    
    private let dataService = StrongSelfDataService()
    
    var someTask: Task<Void, Never>? = nil
    var myTasks: [Task<Void, Never>] = []
    
    func cancelTask() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach { $0.cancel() }
        myTasks = []
    }
    
    // это подразумевает сильную ссылку
    func updateData() {
        Task {
            data = await dataService.getdata()
        }
    }
    
    // это подразумевает слабую ссылку
    func updateData2() {
        Task { [weak self] in
            if let data = await self?.dataService.getdata() {
                self?.data = data
            }
        }
    }
    
    // нам не нужно управлять weak/swtrong
    // мы можем управлять Task
    func updateData3() {
        someTask = Task {
            data = await dataService.getdata()
        }
    }
    
    func updateData4() {
        let task1 = Task {
            data = await dataService.getdata()
        }
        
        let task2 = Task {
            data = await dataService.getdata()
        }
        
        myTasks.append(contentsOf: [task1, task2])
    }
}

struct StrongSelfBootcamp13: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear{
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTask()
            }
    }
}
