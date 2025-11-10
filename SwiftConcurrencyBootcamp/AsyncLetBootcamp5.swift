//
//  AsyncLetBootcamp5.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 09.11.2025.
//  https://youtu.be/1OmJJwVF7uQ?si=VpqaLwheeRN5N0-5

import SwiftUI

struct AsyncLetBootcamp5: View {
    
    @State private var images: [UIImage] = []
    @State private var title = "Async Let 🥳"
    
    let colums = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colums) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    }
                }
            }
            .navigationTitle(title)
            .onAppear {
                Task {
                    do {
                        async let fetchImage1 = fetchImage()
                        async let fetchTitle = fetchTitle()
                        
                        let (image, title) = await (try fetchImage1, fetchTitle)
                        images.append(image)
                        self.title = title
                        
//                        async let fetchImage2 = fetchImage()
//                        async let fetchImage3 = fetchImage()
//                        async let fetchImage4 = fetchImage()
                        
//                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                        images.append(contentsOf: [image1, image2, image3, image4])
                        
//                        let image1 = try await fetchImage()
//                        images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        images.append(image2)
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        "New title"
    }
    
    func fetchImage() async throws -> UIImage {
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

#Preview {
    AsyncLetBootcamp5()
}
