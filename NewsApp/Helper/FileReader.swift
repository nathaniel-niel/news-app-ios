//
//  FileReader.swift
//  NewsApp
//
//  Created by Nathaniel Andrian on 15/12/22.
//

import Foundation

var apiKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
      fatalError("Couldn't find file 'Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'nfo.plist'.")
    }
    return value
  }
}
