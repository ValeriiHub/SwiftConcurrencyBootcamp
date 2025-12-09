//
//  AsyncStreamBootcamp18.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 07.12.2025.
//

import SwiftUI

final class AsyncStreamDataManager {
    
    func getFakeData(newValue: @escaping (_ value: Int) -> Void,
                     onFinish: @escaping (_ error: Error?) -> Void) {
        let items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)) {
                newValue(item)
                
                if item == items.last {
                    onFinish(nil)
                }
            }
        }
    }
    
    func getAsyncSgream() -> AsyncThrowingStream<Int, Error> {
//        AsyncStream(Int.self) { [weak self] continuation in
//            self?.getFakeData { value in
//                continuation.yield(value)
//            }
//        }
        
//        AsyncStream(Int.self) { [weak self] continuation in
//            self?.getFakeData { value in
//                continuation.yield(value)
//            } onFinish: {
//                continuation.finish()
//            }
//
//        }
        
        AsyncThrowingStream (Int.self) { [weak self] continuation in
            self?.getFakeData { value in
                continuation.yield(value)
            } onFinish: { error in
                continuation.finish(throwing: error)
            }

        }
    }
}

@MainActor final class AsyncStreamViewModel: ObservableObject {
    
    @Published private(set) var currentNumber = 0
    
    private let manager = AsyncStreamDataManager()
    
    func onViewAppear() {
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }
        
        Task {
//            for await value in manager.getAsyncSgream() {
//                currentNumber = value
//            }
            do {
                for try await value in manager.getAsyncSgream() {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
    }
}

struct AsyncStreamBootcamp18: View {
    
    @StateObject private var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    AsyncStreamBootcamp18()
}
