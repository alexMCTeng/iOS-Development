//
//  APIResults.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 10/23/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import Foundation

/*
 Quoted from lab 4 instructions.
 */

struct APIResults: Decodable {
    let page: Int
    let total_results: Int
    let total_pages:Int
    let results: [Movie]
}
