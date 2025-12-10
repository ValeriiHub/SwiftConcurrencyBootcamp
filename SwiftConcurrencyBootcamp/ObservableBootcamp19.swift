//
//  ObservableBootcamp19.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 10.12.2025.
//

import SwiftUI

actor TitleDatabase {
    
    func getNewTitle() -> String {
        return "Some new title"
    }
}

@Observable final class ObservableViewModel {
    
    @ObservationIgnored let database = TitleDatabase()
    var title: String = "Starting title"
    
    func updateTitle() async {
        let title = await database.getNewTitle()
        await MainActor.run {
            self.title = title
        }
    }
}

struct ObservableBootcamp19: View {
    
    @State private var viewModel = ObservableViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .task {
                await viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableBootcamp19()
}
