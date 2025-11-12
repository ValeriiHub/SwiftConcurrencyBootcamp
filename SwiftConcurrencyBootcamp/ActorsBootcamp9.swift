//
//  ActorsBootcamp9.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 11.11.2025.
//

import SwiftUI

class MyDataManager {
    
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
        
    private let queue = DispatchQueue(label: "com.myapp.dataManagerQueue")
    
//    func getRandomData() -> String? {
//        self.data.append(UUID().uuidString)
//        print(Thread.current)
//        return data.randomElement()
//    }
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    nonisolated let randomText = "random text"
        
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
    
    // nonisolated - позволяет вызывать метод актора синхронно, без await
    // Используется для методов, которые не обращаются к изолированному состоянию актора (var data)
    // Метод выполняется вне изоляции актора и может быть вызван из любого контекста
    nonisolated func getNewData() -> String {
        return "New data"
    }
}

struct HomeView: View {
    
    @State private var text: String = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    let manager = MyDataManager.instance
    let manager = MyActorDataManager.instance
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8)
                .ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
            let newData = manager.getNewData()
            let randomText = manager.randomText
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .background).async {
//                if let data = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        text = data
//                    }
//                }
//            }
            
//            manager.getRandomData { title in
//                if let data = title {
//                    DispatchQueue.main.async {
//                        text = data
//                    }
//                }
//            }
            
            Task {
                if let data = await self.manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct BrowseView: View {
    
    @State private var text: String = ""
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
//    let manager = MyDataManager.instance
    let manager = MyActorDataManager.instance
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8)
                .ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .default).async {
//                if let data = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        text = data
//                    }
//                }
//            }
            
//            manager.getRandomData { title in
//                if let data = title {
//                    DispatchQueue.main.async {
//                        text = data
//                    }
//                }
//            }
            
            Task {
                if let data = await self.manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct ActorsBootcamp9: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorsBootcamp9()
}
