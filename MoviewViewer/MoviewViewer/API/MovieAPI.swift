//
//  MovieAPI.swift
//  MoviewViewer
//
//  Created by Amiel Reyes on 2/28/18.
//  Copyright © 2018 Amiel Reyes. All rights reserved.
//

import UIKit

extension WebServiceAPI {

    
    func getMovieDetail(completion: @escaping Completion ){
        getRequest(movie_api_movies, completion: completion)
    }

    func getSeatMap(completion: @escaping Completion ){
        getRequest(movie_api_seatMap, completion: completion)

    }
    
    func getSchedule(completion: @escaping Completion ){
        getRequest(movie_api_schedule, completion: completion)

    }

    
}
