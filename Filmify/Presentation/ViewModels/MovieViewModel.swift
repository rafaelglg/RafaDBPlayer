//
//  MovieViewModel.swift
//  Filmify
//
//  Created by Rafael Loggiodice on 6/11/24.
//

import Foundation
import Combine

@Observable
final class MovieViewModel {
    let movieUsesCase: MovieUsesCases
    
    var nowPlayingMovies: [MovieResultResponse] = []
    var topRatedMovies: [MovieResultResponse] = []
    var upcomingMovies: [MovieResultResponse] = []
    var trendingMoviesByDay: [MovieResultResponse] = []
    var trendingMoviesByWeek: [MovieResultResponse] = []
    var detailMovie: MovieDetails?
    var recommendations: [MovieResultResponse] = []
    
    var selectedMovie: MovieResultResponse?
    var recommendationSelected: MovieResultResponse?

    @ObservationIgnored var cancellable = Set<AnyCancellable>()
    var searchText = CurrentValueSubject<String, Never>("")
    var filteredMovies: [MovieResultResponse] = []
    var noSearchResult: Bool = false
    
    var isLoading: Bool = false
    var isLoadingDetailView: Bool = false
    var alertMessage: String = ""
    var showingAlert: Bool = false
    
    init(movieUsesCase: MovieUsesCases) {
        self.movieUsesCase = movieUsesCase
        addSubscribers()
    }
    
    var isSearching: Bool {
        !searchText.value.isEmpty
    }
    
    func getNowPlayingMovies() {
        isLoading = true
        movieUsesCase.executeNowPlayingMovies()
            .receive(on: DispatchQueue.main)
            .map(\.results)
            .sink { [weak self] completion in
                
                defer {
                    self?.isLoading = false
                }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.alertMessage = error.localizedDescription
                    self?.showingAlert = true
                }
            } receiveValue: { [weak self] movieResponse in
                self?.nowPlayingMovies = movieResponse
            }.store(in: &cancellable)
    }
    
    func getTopRatedMovies() {
        isLoading = true
        movieUsesCase.executeTopRatedMovies()
            .receive(on: DispatchQueue.main)
            .map(\.results)
            .sink { [weak self] completion in
                
                defer {
                    self?.isLoading = false
                }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.alertMessage = error.localizedDescription
                    self?.showingAlert = true
                }
            } receiveValue: { [weak self] ratedMovies in
                self?.topRatedMovies = ratedMovies
            }.store(in: &cancellable)
    }
    
    func getUpcomingMovies() {
        isLoading = true
        movieUsesCase.executeUpcomingMovies()
            .receive(on: DispatchQueue.main)
            .map(\.results)
            .sink { [weak self] completion in
                
                defer {
                    self?.isLoading = false
                }
                
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.alertMessage = error.localizedDescription
                    self?.showingAlert = true
                }
            } receiveValue: { [weak self] upcoming in
                self?.upcomingMovies = upcoming
            }
            .store(in: &cancellable)
    }
    
    func getTrendingMovies(timePeriod: MovieEndingPath) {
        isLoading = true
        do {
            guard timePeriod.isTrendingAllow else {
                throw ErrorManager.badChosenTimePeriod
            }
        } catch {
            self.alertMessage = error.localizedDescription
            self.showingAlert = true
            return
        }
        
        movieUsesCase.executeTrendingMovies(timePeriod: timePeriod)
            .receive(on: DispatchQueue.main)
            .map(\.results)
            .sink { [weak self] completion in
                
                defer {
                    self?.isLoading = false
                }
                
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.alertMessage = error.localizedDescription
                    self?.showingAlert = true
                }
            } receiveValue: { [weak self] moviesByTimePeriod in
                
                if timePeriod == MovieEndingPath.day {
                    self?.trendingMoviesByDay = moviesByTimePeriod
                } else if timePeriod == MovieEndingPath.week {
                    self?.trendingMoviesByWeek = moviesByTimePeriod
                }
            }
            .store(in: &cancellable)
    }
    
    func getMovieDetails(id: String?) {
        isLoadingDetailView = true
        
        movieUsesCase.executeDetailMovies(id: id ?? "0")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                
                defer {
                    self.isLoadingDetailView = false
                }
                
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                }
            } receiveValue: { [weak self] detailMovieResponse in
                self?.detailMovie = detailMovieResponse
            }
            .store(in: &cancellable)
    }
    
    func getRecommendations(id: String) {
        isLoadingDetailView = true
        movieUsesCase.executeRecommendations(id: id)
            .receive(on: DispatchQueue.main)
            .map(\.results)
            .sink { [weak self] completion in
                
                defer {
                    self?.isLoadingDetailView = false
                }
                
                switch completion {
                    
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.alertMessage = error.localizedDescription
                    self?.showingAlert = true
                }
            } receiveValue: { [weak self] response in
                self?.recommendations = response
            }.store(in: &cancellable)
    }
    
    func getSearch(query: String) {
        movieUsesCase.executeSearch(query: query)
            .receive(on: DispatchQueue.main)
            .map(\.results)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.alertMessage = error.localizedDescription
                    self?.showingAlert = true
                }
            } receiveValue: { [weak self] searchedMovies in
                self?.filteredMovies = searchedMovies
                self?.noSearchResult = searchedMovies.isEmpty
            }.store(in: &cancellable)
    }
    
    func getDashboard() {
        getNowPlayingMovies()
        getTopRatedMovies()
        getUpcomingMovies()
        getTrendingMovies(timePeriod: .day)
        getTrendingMovies(timePeriod: .week)
    }
}

extension MovieViewModel {
    func addSubscribers() {
        searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchedText in
                if !searchedText.isEmpty {
                    self?.getSearch(query: searchedText)
                }
            }
            .store(in: &cancellable)
    }
}
