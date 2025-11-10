//
//  TaskGroupBootcamp6.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 10.11.2025.
//  https://www.youtube.com/watch?v=epBbbysk5cU

import SwiftUI

final class TaskGroupBootcampDataManager {
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/200")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/200")
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200"
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count) // - pезервирует достаточно места для хранения указанного количества элементов.
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.fetchImage(urlString: "https://picsum.photos/200")
//            }
            
            for try await image in group {
                if let image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

final class TaskGroupBootcampViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
    
    let manager = TaskGroupBootcampDataManager()
    
    func fetchImages() async {
        do {
            let fetchedImages = try await manager.fetchImagesWithTaskGroup()
            await MainActor.run {
                images.append(contentsOf: fetchedImages)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

struct TaskGroupBootcamp6: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    
    private let colums = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colums) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    }
                }
            }
            .navigationTitle("TaskGroup")
            .task {
                await viewModel.fetchImages()
            }
        }
    }
}

#Preview {
    TaskGroupBootcamp6()
}
