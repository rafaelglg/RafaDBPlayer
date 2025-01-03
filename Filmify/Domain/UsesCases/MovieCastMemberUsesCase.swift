//
//  MovieCastMemberUsesCase.swift
//  Filmify
//
//  Created by Rafael Loggiodice on 17/11/24.
//

import Combine

protocol MovieCastMemberUsesCase {
    func executeCastMembers(from path: MovieEndingPath) -> AnyPublisher<CastModel, Error>
    func executePersonDetail(from path: MovieEndingPath) -> AnyPublisher<PersonDetailModel, Error>
}

final class MovieCastMemberUsesCaseImpl: MovieCastMemberUsesCase {
    private let repository: CastMembersService
    
    init(repository: CastMembersService) {
        self.repository = repository
    }
    
    func executeCastMembers(from path: MovieEndingPath) -> AnyPublisher<CastModel, Error> {
        return repository.fetchMovieCastMembers(from: path)
    }
    
    func executePersonDetail(from path: MovieEndingPath) -> AnyPublisher<PersonDetailModel, Error> {
        return repository.fetchPersonDetailInfo(from: path)
    }
}
