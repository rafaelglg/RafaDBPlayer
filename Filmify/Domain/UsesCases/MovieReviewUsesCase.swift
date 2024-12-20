//
//  MovieReviewUsesCase.swift
//  Filmify
//
//  Created by Rafael Loggiodice on 14/11/24.
//

import Combine

protocol MovieReviewUsesCase {
    func execute(from path: MovieEndingPath) -> AnyPublisher<MovieReviewModel, Error>
}

final class MovieReviewUsesCaseImpl: MovieReviewUsesCase {
    
    private let repository: MovieReviewService
    
    init(repository: MovieReviewService) {
        self.repository = repository
    }
    
    func execute(from path: MovieEndingPath) -> AnyPublisher<MovieReviewModel, Error> {
        return repository.fetchMovieReviews(from: path)
    }
}