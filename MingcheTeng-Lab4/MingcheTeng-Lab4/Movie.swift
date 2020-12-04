//
//  Movie.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 10/23/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import Foundation

/*
 Quoted from lab 4 instructions.
 */
struct Movie: Decodable {
    let id: Int!
    let poster_path: String?
    let title: String
    let release_date: String
    let vote_average: Double
    let overview: String
    let vote_count:Int!
}
