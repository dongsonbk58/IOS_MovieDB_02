//
//  MovieDetailUseCase.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/30/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol MovieDetailUseCaseType {
    func getDetailMovie(movie: Movie) -> Observable<Movie>
    func getCast(movieId id: Int) -> Observable<[Cast]>
    func getCrew(movieId id: Int) -> Observable<[Crew]>
    func getTrailer(movieId id: Int) -> Observable<String>
    func checkAvailable(movie: Movie) -> Observable<Bool>
    func addToFavorite(movie: Movie) -> Observable<DatabaseResultState>
    func deleteFromFavorite(movie: Movie) -> Observable<DatabaseResultState>
    func getFirstReview(movieId id: Int) -> Observable<Review>
}

struct MovieDetailUseCase: MovieDetailUseCaseType {
    func getDetailMovie(movie: Movie) -> Observable<Movie> {
        let request = MovieDetailRequest(movieId: movie.id)
        let repository = MovieRepositoryImp(api: APIService.share)
        return repository.getMovieDetail(input: request)
    }
    
    func getCast(movieId id: Int) -> Observable<[Cast]> {
        let request = MovieCreditRequest(movieId: id)
        let repository = CreditRepositoryImp(api: APIService.share)
        return repository.getCredit(input: request)
            .map { creditResponse in
                return Array(creditResponse.casts.prefix(10))
            }
    }
    
    func getCrew(movieId id: Int) -> Observable<[Crew]> {
        let request = MovieCreditRequest(movieId: id)
        let repository = CreditRepositoryImp(api: APIService.share)
        return repository.getCredit(input: request)
            .map { creditResponse in
                return Array(creditResponse.crews.prefix(10))
            }
    }
    
    func getTrailer(movieId id: Int) -> Observable<String> {
        let request = TrailerRequest(movieId: id)
        let repository = TrailerRepositoryImp(api: APIService.share)
        return repository.getTrailers(input: request)
            .filter { trailers in
                trailers.count != 0
            }
            .map { trailers in
                return trailers[0].key
            }
    }
    
    func checkAvailable(movie: Movie) -> Observable<Bool> {
        let databaseManager = DatabaseManager.sharedInstance()
        return databaseManager.checkAvailable(movie:movie)
    }
    
    func addToFavorite(movie: Movie) -> Observable<DatabaseResultState> {
        let databaseManager = DatabaseManager.sharedInstance()
        return databaseManager.insert(movie: movie)
    }
    
    func deleteFromFavorite(movie: Movie) -> Observable<DatabaseResultState> {
        let databaseManager = DatabaseManager.sharedInstance()
        return databaseManager.delete(movie:movie)
    }
    
    func getFirstReview(movieId id: Int) -> Observable<Review> {
        let request = ReviewRequest(movieID: id, page: 1)
        let repository = ReviewRepositoryImp(api: APIService.share)
        return repository.getReviews(input: request)
            .filter { reviews in
                reviews.count > 0
            }
            .map { reviews in
                return reviews[0]
            }
    }
}
