//
//  BreedCell.swift
//  DAÜG
//
//  Created by Tommy Mallow on 3/27/18.
//  Copyright © 2018 Marshmallow. All rights reserved.
//

import UIKit


extension UIImageView {
    /*
     Function to download image from URL and set to UIImageView
     */
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


class BreedCell: UITableViewCell {
    
    @IBOutlet weak var breedImageView: UIImageView!
    @IBOutlet weak var breedTitleLabel: UILabel!
    
    /*
     Function to round the corners of the dog breed images
     */
    func setCellStyle(){
        breedImageView.layer.cornerRadius = breedImageView.frame.size.width / 2;
        breedImageView.clipsToBounds = true;
    }
    
    /*
     Function to set the label and image in UITableView cells
     */
    func setBreed(breed: String, imageURL: String) {
        breedTitleLabel.text = breed
        let url = URL(string: imageURL)
        
        if (imageURL != ""){
            breedImageView.downloadedFrom(url: url!)
        }
    }
    
    
    
}
