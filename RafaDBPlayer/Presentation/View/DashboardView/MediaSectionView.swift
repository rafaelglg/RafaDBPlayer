//
//  MediaSectionView.swift
//  RafaDBPlayer
//
//  Created by Rafael Loggiodice on 7/11/24.
//

import SwiftUI

struct MediaSectionView: View {
    
    @Environment(MovieViewModel.self) private var movieVM
    @State private var movieReviewVM = MovieReviewViewModel()
    
    let title: String
    let movie: [MovieResultResponse]
    
    var body: some View {
        @Bindable var movieVM = movieVM
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 3) {
                    ForEach(movie) { movie in
                        MovieCell(movie: movie, imageURL: movie.posterURLImage)
                            .onTapGesture {
                                movieVM.selectedMovie = movie
                            }
                    }
                }
            }
            .sheet(item: $movieVM.selectedMovie) { movie in
                MediaDetailView(movie: movie, movieReviewVM: movieReviewVM)
            }
            .presentationCornerRadius(15)
            .scrollIndicators(.hidden)
        }
        .padding(.leading)
        .padding(.top)
    }
}

#Preview {
    MediaSectionView(title: "Movies", movie: [.preview])
        .environment(MovieViewModel())
}
