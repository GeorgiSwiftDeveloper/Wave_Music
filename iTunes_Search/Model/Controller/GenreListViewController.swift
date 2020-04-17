//
//  GenreListViewController.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/16/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import Alamofire

class GenreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var topGenreLabelText: UILabel!
    
    var genreTitle: GenreModel?
    var videoArray = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        topGenreLabelText.text  = "Top \(genreTitle!.genreTitle) Song's"
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchMusicCell", for: indexPath) as? GenreVideoTableViewCell {
                   return cell
               }else {
                   return GenreVideoTableViewCell()
               }
    }
    

}
