//
//  CheckedContinuationBootcamp7.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 10.11.2025.
//  https://www.youtube.com/watch?v=Tw_WLMIfEPQ

import SwiftUI

final class CheckedContinuationBootcampNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        let data = try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data, error == nil {
                    continuation.resume(returning: data)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        }
        
        return data
    }
    
    private func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        let image = await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
        
        return image
    }
}

final class CheckedContinuationBootcampViewModel: ObservableObject {
        
    @Published var image: UIImage?
    
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func fetchImages() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func getHeartImage() {
//        networkManager.getHeartImageFromDatabase { [weak self] image in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
//    }
    
    func getHeartImage() async {
        let heartImage = await networkManager.getHeartImageFromDatabase()
        await MainActor.run {
            self.image = heartImage
        }
    }
}


struct CheckedContinuationBootcamp7: View {
    
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let images = viewModel.image {
                Image(uiImage: images)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .task {
//            await viewModel.fetchImages()
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    CheckedContinuationBootcamp7()
}
