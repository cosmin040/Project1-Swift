//
//  Utilities.swift
//  Project1
//
//  Created by Laptop on 02.05.2022.
//

import UIKit

struct Response: Codable{
    let searchType: String
    let expression: String
    var results: [MyResult] = []
    let errorMessage: String
}

struct MyResult: Codable{
    let id: String
    let resultType: String
    let image: String
    let title: String
    let description: String
}

struct ShowsList: Codable {
    let id: String
    let title: String
    let year: String
    let image: String
}

struct TrailerAPI: Codable{
    let imDbId: String
    let title: String
    let fullTitle: String
    let type: String
    let year: String
    let videoId: String
    let videoUrl: String
    let errorMessage: String
}

func getYearFromString(_ value: String) -> String{
    var year = ""
    for char in value{
        if char.asciiValue! >= 48 && char.asciiValue! <= 57{
            year.append(char)
        }
    }
    return year
}

extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}
