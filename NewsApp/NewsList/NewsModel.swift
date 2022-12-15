//
//  NewsModel.swift
//  NewsApp
//
//  Created by Nathaniel Andrian on 15/12/22.
//

import Foundation

struct ArticleList: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let title: String
    let description: String?
}
