//
//  MVVMBootcamp14.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 26.11.2025.
//

import SwiftUI
import Combine

final class MyManagerClass: ObservableObject {
    func getData() async throws -> String {
        "Some data"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some data"
    }
}

final class MVVMBootcampViewModel: ObservableObject {
    
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    @MainActor @Published private(set) var myData: String = "Starting text"
    
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach { $0.cancel() }
        tasks = []
    }
    
    func onCallToActionButtonPressed() {
        let task = Task { @MainActor in
            do {
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
}

struct MVVMBootcamp14: View {
    
    @StateObject private var viewModel = MVVMBootcampViewModel()
    
    var body: some View {
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

#Preview {
    MVVMBootcamp14()
}
