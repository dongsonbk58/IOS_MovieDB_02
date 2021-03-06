//
//  URLs.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/23/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import Foundation

struct URLs {
    private static let APIBaseUrl = "https://api.themoviedb.org/3"
    
    static let APIMovieNowPlayingURL = APIBaseUrl + "/movie/now_playing"
    
    static let APIMoviePopularURL = APIBaseUrl + "/movie/popular"
    
    static let APIMovieTopRatedURL = APIBaseUrl + "/movie/top_rated"
    
    static let APIMovieUpcomingURL = APIBaseUrl + "/movie/upcoming"
    
    static let APIGenreListURL = APIBaseUrl + "/genre/movie/list"
    
    static let APIMovieDetailURL = APIBaseUrl + "/movie/"
    
    static let APIMoviePosterPath = "https://image.tmdb.org/t/p/w300_and_h450_bestv2"
    
    static let APIPersonProfilePath = "https://image.tmdb.org/t/p/w500_and_h282_face"
    
    static let APIMovieByGenreURL = APIBaseUrl + "/genre/"
    
    static let APICreditURL = APIBaseUrl + "/movie/"
    
    static let APITrailerURL = APIBaseUrl + "/movie/"

    static let APIMovieSearch = APIBaseUrl + "/search/movie"
    
    static let HomePageURL = "https://www.themoviedb.org"
    
    static let APIReviewURL = APIBaseUrl + "/movie/"

    static let APIPerson = APIBaseUrl + "/person/"
    
    static let APIMovieBackdropPath = "https://image.tmdb.org/t/p/w500"
}
