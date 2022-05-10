//
//  TVShowsViewController.swift
//  Project1
//
//  Created by Laptop on 08.04.2022.
//

import UIKit
import Firebase

var firestoreShows: [ShowsList?] = []

class TVShowsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tvShowsTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TVShowsTableViewCell", bundle: nil)
        tvShowsTableView.register(nib, forCellReuseIdentifier: "TVShowsTableViewCell")
        tvShowsTableView.delegate = self
        tvShowsTableView.dataSource = self
        
        queryExistentShowsInFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tvShowsTableView.reloadData()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        searchButton.alpha = 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchButton.alpha = 0.3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trailerHomeSegue" {
            let vc = segue.destination as? TrailerSearchViewController
            vc?.id = firestoreShows[sender as! Int]!.id
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "trailerHomeSegue", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firestoreShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TVShowsTableViewCell", for: indexPath) as! TVShowsTableViewCell
        cell.title.text = firestoreShows[indexPath.row]?.title
        cell.year.text = firestoreShows[indexPath.row]?.year
        cell.infoImage.loadFrom(URLAddress: (firestoreShows[indexPath.row]?.image)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                
                let db = Firestore.firestore()
                db.collection(uid).document("\(firestoreShows[indexPath.row]!.title)\(firestoreShows[indexPath.row]!.year)").delete { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    }else {
                        firestoreShows.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    func uploadDataToFirestore(_ info: MyResult) throws {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            let db = Firestore.firestore()
            db.collection(uid).document("\(info.title)\(getYearFromString(info.description))").setData(["title": info.title, "year": getYearFromString(info.description), "image": info.image, "id": info.id])
        }
    }
    
    func retrieveDataFromFirestore(_ tvShow: MyResult)
    {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            let db = Firestore.firestore()
            db.collection(uid).document("\(tvShow.title)\(getYearFromString(tvShow.description))").getDocument { document, error in
                if let document = document, document.exists {
                    firestoreShows.append(document.data().map {data in
                        return ShowsList(id: data["id"] as? String ?? "", title: data["title"] as? String ?? "", year: data["year"] as? String ?? "", image: data["image"] as? String ?? "")
                    }!)
                }else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func queryExistentShowsInFirestore()
    {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            let db = Firestore.firestore()
            db.collection(uid).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                }else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let year = data["year"] as? String ?? ""
                        let image = data["image"] as? String ?? ""
                        let id = data["id"] as? String ?? ""
                        firestoreShows.append(ShowsList(id: id, title: title, year: year, image: image))
                        
                        DispatchQueue.main.async {
                            self.tvShowsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func receiveDataFromSearchViewController(_ info: MyResult)
    {
        do {
            try uploadDataToFirestore(info)
            retrieveDataFromFirestore(info)
        }catch {
            print("Unable to upload Show on Firebase Firestore")
        }
    }
    
    func signOutUser(){
        do{
            try Auth.auth().signOut()
            
            let loginNavigationController = storyboard?.instantiateViewController(withIdentifier: "loginNavigationController") as? UINavigationController
            view.window?.rootViewController = loginNavigationController
            view.window?.makeKeyAndVisible()
        }catch {
            print("Already logged out")
        }
    }
    
    @IBAction func tapSignOutButton(_ sender: UIButton) {
        signOutUser()
    }
}
