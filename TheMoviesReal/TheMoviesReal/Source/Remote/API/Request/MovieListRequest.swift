//
//  MovieListRequest.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/23/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import Foundation

enum MovieListType: String{
    case nowPlaying = "Now Playing Movies"
    case popular = "Popular Movies"
    case topRated = "Top Rated Movies"
    case upComing = "Up Coming Movies"
    
    var url: String {
        switch self {
        case .nowPlaying:
            return URLs.APIMovieNowPlayingURL
            
        case .popular:
            return URLs.APIMoviePopularURL
            
        case .topRated:
            return URLs.APIMovieTopRatedURL
            
        case .upComing:
            return URLs.APIMovieUpcomingURL
        }
    }
}

class MovieListRequest: BaseRequest {
    required init(listType: MovieListType, page: Int) {
        let body: [String: Any]  = [
            "api_key": APIKey.key,
            "language": "en-US",
            "page": page
        ]
        super.init(url: listType.url, requestType: .get, body: body)
    }
}
