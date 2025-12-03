//
//  SearchableBootcamp16.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 30.11.2025.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}
    
enum CuisineOption: String {
    case american, italian, japanese
}

enum SearchScopeOption: Hashable {
    case all
    case cuisine(option: CuisineOption)
    
    var title: String {
        switch self {
        case .all:
            "All"
        case .cuisine(let option):
            option.rawValue.capitalized
        }
    }
}

final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        [Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
         Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
         Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
         Restaurant (id: "4", title: "Local Market", cuisine: .american),
         ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let manager = RestaurantManager()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var isShowSearchSuggestions: Bool {
        searchText.count < 4
    }
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        // filter on search scope
        var reataurantInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(option: let cuisineOption):
            reataurantInScope = allRestaurants.filter { $0.cuisine == cuisineOption }
        }
        
        // filter o search text
        let search = searchText.lowercased()
        
        filteredRestaurants = reataurantInScope.filter{ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainsSearch
        }
        
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            let allCuisinesSet = Set(allRestaurants.map { $0.cuisine })
            let allCuisines = allCuisinesSet.map { SearchScopeOption.cuisine(option: $0) }
            allSearchScopes = [.all] + allCuisines
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        guard isShowSearchSuggestions else {
            return []
        }
        
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        if search.contains ("bu") {
            suggestions.append("Burger")
        }
        
        suggestions.append( "Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestaurantSuggestions() -> [Restaurant] {
        guard isShowSearchSuggestions else {
            return []
        }
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        
        if search.contains("ita") {
            let italianRestaurants = allRestaurants.filter { $0.cuisine == .italian }
            suggestions.append(contentsOf: italianRestaurants)
        }
        if search.contains("jap") {
            let japaneseRestaurants = allRestaurants.filter { $0.cuisine == .japanese }
            suggestions.append(contentsOf: japaneseRestaurants)
        }
        return suggestions
    }
}

struct SearchableBootcamp16: View {
    
    @StateObject private var viewModel = SearchableViewModel()
        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack( spacing: 20) {
                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                        NavigationLink(value: restaurant) {
                            restaurantRow(restaurant: restaurant)
                        }
                    }
                }
                .padding()
                
                Text("ViewModel is searching: \(viewModel.isSearching.description)")
                SearchChildView()
            }
            .navigationTitle("Restaurants")
            // .searchable() - добавляет строку поиска в навигационную панель с привязкой к searchText
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restaurants...")
            // .searchScopes() - добавляет области поиска (scope tabs) для фильтрации результатов по категориям
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                    Text(scope.title)
                        .tag(scope)
                }
            })
            // .searchSuggestions - предоставляет пользовательские подсказки для поиска, которые появляются при вводе текста
            .searchSuggestions {
                ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                }
                
                ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { restaurantSuggestion in
                    NavigationLink(value: restaurantSuggestion) {
                        Text(restaurantSuggestion.title)
                    }
                }
            }
            .task {
                await viewModel.loadRestaurants()
            }
            .navigationDestination(for: Restaurant.self) { restaurant in
                Text(restaurant.title.uppercased())
            }
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundStyle(.red)
            
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
                .tint(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.05))
    }
}

struct SearchChildView: View {
    
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        // isSearching - это специальное Environment значение, которое автоматически обновляется при использовании модификатора .searchable().
        Text("ViewModel is searching: \(isSearching.description)")
    }
}

#Preview {
    SearchableBootcamp16()
}
