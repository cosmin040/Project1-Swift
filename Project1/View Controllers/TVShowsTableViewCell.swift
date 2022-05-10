//
//  TVShowsTableViewCell.swift
//  Project1
//
//  Created by Laptop on 15.04.2022.
//

import UIKit

protocol TVShowsTableViewCellDelegate: AnyObject{
    func tapSaveButton(with line: Int)
}

class TVShowsTableViewCell: UITableViewCell {
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: TVShowsTableViewCellDelegate?
    private var line: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(_ line: Int, _ showsList: MyResult?){
        self.line = line
        saveButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        
        if firestoreShows.count != 0{
            for i in 0..<firestoreShows.count {
                if(firestoreShows[i]?.title == showsList?.title && firestoreShows[i]?.year == getYearFromString(showsList!.description))
                {
                    saveButton.setImage(UIImage.checkmark, for: .normal)
                }
            }
        }
        
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        if saveButton.image(for: .normal) != UIImage.checkmark{
            saveButton.setImage(UIImage.checkmark, for: .normal)
            delegate?.tapSaveButton(with: line)
        }
    }
}

