//
//  SearchViewController.swift
//  Project1
//
//  Created by Laptop on 14.04.2022.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var APIResponseValues: Response?
    var lineOfPressedButton = -1 {
        didSet{
            sendDataToTVShowsViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TVShowsTableViewCell", bundle: nil)
        
        searchBar.delegate = self
        tableView.register(nib, forCellReuseIdentifier: "TVShowsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /*func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == ""{
            APIResponseValues = nil
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }*/
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var text = searchBar.text!
        text = text.replacingOccurrences(of: " ", with: "%20")
        
        let url = "https://imdb-api.com/en/API/SearchSeries/k_cs38invw/\(text)"
        getDataFromAPI(from: url)
        
        /*if searchBar.text == "" {
            APIResponseValues = nil
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trailerSearchSegue"{
            let vc = segue.destination as? TrailerSearchViewController
            vc?.id = (APIResponseValues?.results[sender as! Int].id)!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "trailerSearchSegue", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if APIResponseValues == nil{
            return 0
        }else {
            return APIResponseValues!.results.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TVShowsTableViewCell", for: indexPath) as! TVShowsTableViewCell
        cell.title.text = APIResponseValues?.results[indexPath.row].title
        cell.year.text = getYearFromString((APIResponseValues?.results[indexPath.row].description)!)
        cell.infoImage.loadFrom(URLAddress: (APIResponseValues?.results[indexPath.row].image)!)
        cell.configure(indexPath.row, APIResponseValues?.results[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    private func getDataFromAPI(from url: String)
    {
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else{
                print("Error")
                return
            }
            
            var result: Response?
            do {
                result = try JSONDecoder().decode(Response.self, from: data)
            }
            catch {
                print("Eroare convertire \(error)")
            }
            
            guard let json = result else {
                return
            }
            self.APIResponseValues = json
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }).resume()
    }
    
    private func sendDataToTVShowsViewController(){
        let showsViewController = storyboard?.instantiateViewController(withIdentifier: "showsViewController") as! TVShowsViewController
        showsViewController.receiveDataFromSearchViewController(APIResponseValues!.results[lineOfPressedButton])
    }
}

extension SearchViewController: TVShowsTableViewCellDelegate{
    func tapSaveButton(with line: Int) {
        lineOfPressedButton = line
    }
}
