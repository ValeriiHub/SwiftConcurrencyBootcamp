//
//  AsyncAwaitBootcamp3.swift
//  SwiftConcurrencyBootcamp
//
//  Created by User03 on 01.05.2023.
//  https://youtu.be/-5kIzkBqAzc?si=0UTox1d9uCxYIEEH

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title2 : \(Thread.current)"
            
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "Title3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 : \(Thread.current)"

        await MainActor.run {
            self.dataArray.append(author2)

            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        }
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something1 : \(Thread.current)"

        await MainActor.run {
            self.dataArray.append(something1)

            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        }
    }
}

struct AsyncAwaitBootcamp3: View {
    
    @StateObject var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            viewModel.addTitle1()
            viewModel.addTitle2()
            
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomething()
                
                let finalText = "FINAL TEXT : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwaitBootcamp3_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp3()
    }
}
