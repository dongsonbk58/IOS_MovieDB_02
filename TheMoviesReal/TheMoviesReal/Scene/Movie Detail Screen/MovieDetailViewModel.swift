//
//  MovieDetailViewModel.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/30/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MovieDetailViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let seeMoreTrigger: Driver<Void>
        let favoriteTrigger: Driver<Void>
        let reviewDetailTrigger: Driver<Void>
    }
    
    struct Output {
        let error: Driver<Error>
        let activityIndicator: Driver<Bool>
        let youtubeViewOutput: Driver<String>
        let movieName: Driver<String>
        let movieRate: Driver<Float>
        let movieStatus: Driver<String>
        let movieDuration: Driver<String>
        let moviePoster: Driver<String>
        let movieOverview: Driver<String>
        let castList: Driver<[Cast]>
        let crewList: Driver<[Crew]>
        let overviewState: Driver<Bool>
        let favoriteState: Driver<Bool>
        let favoriteAction: Driver<DatabaseResultState>
        let genreDetail: Driver<String>
        let firstReviewAuthor: Driver<String>
        let firstReviewContent: Driver<String>
        let reviewRate: Driver<String>
        let voteCount: Driver<String>
        let reviewDetailClicked: Driver<Void>
    }
    
    let navigator: MovieDetailNavigatorType
    let useCase: MovieDetailUseCaseType
    let movie: Movie
    
    func transform(_ input: MovieDetailViewModel.Input) -> MovieDetailViewModel.Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        let stateSeeMore = BehaviorRelay(value: false)
        
        let overviewState = input.seeMoreTrigger
            .withLatestFrom(stateSeeMore.asDriver())
            .map { state -> Bool in
                stateSeeMore.accept(!state)
                return !state
            }
        
        let favoriteState = input.loadTrigger
            .flatMapLatest {_ in
                return self.useCase.checkAvailable(movie: self.movie)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        let favoriteAction = input.favoriteTrigger
            .flatMapLatest { _ in
                return self.useCase.checkAvailable(movie: self.movie)
                    .asDriverOnErrorJustComplete()
            }
            .flatMap { isAvailable -> Driver<DatabaseResultState> in
                if isAvailable {
                    return self.useCase.deleteFromFavorite(movie: self.movie)
                        .trackError(errorTracker)
                        .asDriverOnErrorJustComplete()
                } else {
                    return self.useCase.addToFavorite(movie: self.movie)
                        .trackError(errorTracker)
                        .asDriverOnErrorJustComplete()
                }
            }
        
        let youtubeView = input.loadTrigger
            .flatMapLatest {
                return self.useCase.getTrailer(movieId: self.movie.id)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        let castList = input.loadTrigger
            .flatMapLatest { _ in
                return self.useCase.getCast(movieId: self.movie.id)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        let crewList = input.loadTrigger
            .flatMapLatest { _ in
                return self.useCase.getCrew(movieId: self.movie.id)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        let detail = input.loadTrigger
            .flatMapLatest { _ in
                return self.useCase.getDetailMovie(movie: self.movie)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: { movie in
                self.movie.posterPath = movie.posterPath
                self.movie.popularity = movie.popularity
                self.movie.voteAverage = movie.voteAverage
                self.movie.voteCount = movie.voteCount
                self.movie.posterPath = movie.posterPath
            })
        
        let movieName = input.loadTrigger
            .map { movie in
                return self.movie.title
            }
        
        let movieRate = detail
            .map { movie in
                return movie.voteAverage
            }
        
        let movieStatus = detail
            .map { movie in
                return movie.status
            }
        
        let movieDuration = detail
            .map { movie in
                return "\(movie.runtime) min"
            }
        
        let moviePoster = detail
            .map { movie in
                return movie.posterPath
            }
        
        let movieOverview = detail
            .map { movie in
                return movie.overview
            }
        
        let genreDetail = detail
            .map { movie in
                return movie.getGenreString()
            }
        
        let firstReview = input.loadTrigger
            .flatMapLatest { _ in
                return self.useCase.getFirstReview(movieId: self.movie.id)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        let firstReviewAuthor = firstReview
            .map { review in
                return "Author: \(review.author)"
            }
        
        let firstReviewContent = firstReview
            .map { review in
                return review.content
            }
        
        let reviewRate = detail
            .map { movie in
                return "\(movie.voteAverage)"
        }
        
        let voteCount = detail
            .map { movie in
                return "\(movie.voteCount) vote"
            }
        
        let reviewButtonClicked = input.reviewDetailTrigger
            .do(onNext: { _ in
                self.navigator.toReviewDetail(movie: self.movie)
            })
            .mapToVoid()
        
        return Output(
            error: errorTracker.asDriver(),
            activityIndicator: activityIndicator.asDriver(),
            youtubeViewOutput: youtubeView,
            movieName: movieName,
            movieRate: movieRate,
            movieStatus: movieStatus,
            movieDuration: movieDuration,
            moviePoster: moviePoster,
            movieOverview: movieOverview,
            castList: castList,
            crewList: crewList,
            overviewState: overviewState.asDriver(),
            favoriteState: favoriteState,
            favoriteAction: favoriteAction,
            genreDetail: genreDetail,
            firstReviewAuthor: firstReviewAuthor,
            firstReviewContent: firstReviewContent,
            reviewRate: reviewRate,
            voteCount: voteCount,
            reviewDetailClicked: reviewButtonClicked
        )
    }
}
