//
//  TrailerSearchViewController.swift
//  Project1
//
//  Created by Laptop on 03.05.2022.
//

import UIKit
import YouTubeiOSPlayerHelper

class TrailerSearchViewController: UIViewController {
    
    @IBOutlet weak var videoPlayer: YTPlayerView!
    
    var trailer = TrailerAPI(imDbId: "", title: "", fullTitle: "", type: "", year: "", videoId: "", videoUrl: "", errorMessage: "")
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "https://imdb-api.com/en/API/YouTubeTrailer/k_cs38invw/\(id)"
        getIdFromAPI(url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.videoPlayer.load(withVideoId: self.trailer.videoId)
        }
    }
    
    func getIdFromAPI(_ url: String) {
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else{
                print("Error")
                return
            }
            
            var result: TrailerAPI?
            do {
                result = try JSONDecoder().decode(TrailerAPI.self, from: data)
            }
            catch {
                print("Eroare convertire \(error)")
            }
            
            guard let json = result else {
                return
            }
            
            self.trailer = json
        }).resume()
    }
}
