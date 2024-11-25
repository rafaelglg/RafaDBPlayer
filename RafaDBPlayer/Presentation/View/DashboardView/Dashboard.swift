//
//  Dashboard.swift
//  RafaDBPlayer
//
//  Created by Rafael Loggiodice on 6/11/24.
//

import SwiftUI

struct Dashboard: View {
    
    @Environment(MovieViewModel.self) var movieVM
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    
                    MediaSectionView(title: "Now in Cines", movie: movieVM.nowPlayingMovies)
                    MediaSectionView(title: "Top rated", movie: movieVM.topRatedMovies)
                    MediaSectionView(title: "Upcoming", movie: movieVM.upcomingMovies)
                    MediaSectionView(title: "Trending by day", movie: movieVM.trendingMoviesByDay)
                    MediaSectionView(title: "Trending by week", movie: movieVM.trendingMoviesByWeek)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.spring) {
                                movieVM.showProfile.toggle()
                            }
                        } label: {
                            Text("Rafa")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.label))
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.white)
                                .fontWeight(.bold)
                        }
                        
                    }
                }
                .onAppear {
                    movieVM.getDashboard()
                }
                .preferredColorScheme(.dark)
                
                if movieVM.isLoading {
                    Color.black.opacity(0.5) // Fondo oscuro semitransparente
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .padding(.bottom, 10)
                        
                        Text("Please wait...")
                            .font(.callout)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    Dashboard()
        .environment(MovieViewModel())
}
