//
//  MovieDetailNavigator.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/30/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import UIKit
import Foundation

protocol MovieDetailNavigatorType {
    func toMovieDetail(movie: Movie)
    func toReviewDetail(movie: Movie)
    func toPerson(personId: Int)
}

struct MovieDetailNavigator: MovieDetailNavigatorType {
    unowned let navigationController: UINavigationController
    
    func toMovieDetail(movie: Movie) {
        let viewController = MovieDetailViewController.instantiate()
        let useCase = MovieDetailUseCase()
        let viewModel = MovieDetailViewModel(navigator: self, useCase: useCase, movie: movie)
        viewController.bindViewModel(to: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func toReviewDetail(movie: Movie) {
        let navigator = ReviewNavigator(navigationController: navigationController)
        navigator.toReviewDetail(movie: movie)
    }
	
    func toPerson(personId: Int) {
        let navigator = PersonNavigator(navigationController: navigationController)
        navigator.toPerson(personId: personId)
    }
}
