//
//  DoCatchTryBootcamp1.swift
//  SwiftConcurrencyBootcamp
//
//  Created by User03 on 01.05.2023.
//  https://youtu.be/ss50RX7F7nE?si=LTRRoLKKWOWLCY_c

import SwiftUI

class DoCatchTryThrowBootcampDataManager {
    
    let isActive = false
    
    // 1 вариант с тюплом
    func getTitle() -> (title:String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    // 2 вариант с Result
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    // 3 вариант через throws
    func getTitle3() throws -> String {
        if isActive {
            return "NEW TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowBootcampViewModel: ObservableObject {
    @Published var text: String = "Starting text"
    
    let dataManager = DoCatchTryThrowBootcampDataManager()
    
    func fetchTitle() {
        // 1 вариант с тюплом
        /*
        let returnedValue = dataManager.getTitle()
        
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
        */
        
        // 2 вариант с Result
        /*
        let returnedValue = dataManager.getTitle2()
         
        switch returnedValue {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
        */
        
        // 3 вариант через throws
        // 3.1
        let newTitle = try? dataManager.getTitle3()
        if let newTitle = newTitle {
            self.text = newTitle
        }
        
        // 3.2
        do {
            let newTitle = try dataManager.getTitle3()
            self.text = newTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
}


struct DoCatchTryThrowBootcamp1: View {
    
    @StateObject var viewModel = DoCatchTryThrowBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrowBootcamp1_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowBootcamp1()
    }
}
