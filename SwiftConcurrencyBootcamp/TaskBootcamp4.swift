//
//  TaskBootcamp4.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 09.11.2025.
//  https://www.youtube.com/watch?v=fTtaEYo14jI

import SwiftUI

final class TaskBootcampViewModel: ObservableObject {
        
    @Published var image: UIImage?
    @Published var image2: UIImage?
        
    func fetchImage() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            await MainActor.run {
                self.image = image
                print("Image return!")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            await MainActor.run {
                self.image2 = image
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("Click me!🥸") {
                    TaskBootcamp4()
                }
            }
        }
    }
}

struct TaskBootcamp4: View {
    
    @StateObject private var viewModel = TaskBootcampViewModel()
    
    @State private var fetchImageTask: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear {
            fetchImageTask = Task {
//                print(Thread.current)
//                print(Task.currentPriority)
                await viewModel.fetchImage()
            }
//            Task {
//                await viewModel.fetchImage2()
//                print(Thread.current)
//                print(Task.currentPriority)
//            }
            
            // Task.yield() - приостанавливает выполнение текущей задачи и передает управление планировщику
            // Позволяет другим задачам с таким же или более высоким приоритетом выполниться первыми
            // Используется для предотвращения блокировки потока длительными операциями
            
//            Task(priority: .high) {
//                try? await  Task.yield()
//                print("high : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
//            }
//            
//            
//            Task(priority: .medium) {
//                print("medium : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("utility : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority)")
//            }
//           
//            
//            Task(priority: .background) {
//                print("background : \(Thread.current) : \(Task.currentPriority)")
//            }
            
            
            /* Обычный Task наследует контекст от родителя (приоритет, actor, task-local values). Task.detached создает полностью независимую задачу:
             - НЕ наследует приоритет родительской задачи (будет .medium по умолчанию)
             - НЕ наследует actor context (не привязана к MainActor)
             - НЕ наследует task-local values
             - НЕ отменяется автоматически при отмене родительской задачи
             Используйте detached когда задача действительно независима от контекста
             
            Task(priority: .low) {
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
            
                Task.detached {
                    print("detached : \(Thread.current) : \(Task.currentPriority)")
                }
            }
             */
        }
        .onDisappear {
            fetchImageTask?.cancel()
        }
//        .task {
//            await viewModel.fetchImage()
//        }
    }
}

#Preview {
    TaskBootcampHomeView()
}
