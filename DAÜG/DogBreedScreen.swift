//
//  DogBreedScreen.swift
//  DAÜG
//
//  Created by Tommy Mallow on 3/27/18.
//  Copyright © 2018 Marshmallow. All rights reserved.
//

import UIKit

class DogBreedScreen: UIViewController {
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallTitleLabel: UIStackView!
    @IBOutlet weak var largeTitleLabel: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    //Declare variables used for header animation
    let maxHeaderHeight: CGFloat = 110
    let minHeaderHeight: CGFloat = 55
    var previousScrollOffset: CGFloat = 0
    
    //Declare Decodable variables and give them temporary values
    var breeds: Breed = Breed(status: "", message: ["Loading..."])
    var images = [Image?](repeating: nil, count: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.smallTitleLabel.alpha = 0
        
        //Download dog breed names, then use names to download dog breed images
        downloadJSON {
            self.tableView.reloadData()
            self.downloadImage(){
                if (self.images[79] != nil) {
                    self.tableView.reloadData()
                }
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerHeightConstraint.constant = self.maxHeaderHeight
    }
    
    /*
     Function to download JSON data for dog breed names
     */
    func downloadJSON(completed: @escaping () -> ()) {
        
        let url = URL(string: "https://dog.ceo/api/breeds/list")
        
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            if error == nil {
                do {
                    self.breeds = try JSONDecoder().decode(Breed.self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("JSON Error: Data")
                }
            }
            }.resume()
        
    }
    
    /*
     Function to download JSON data for dog breed image URLs
     */
    func downloadImage(completed: @escaping () -> ()) {
        
        for i in 0...breeds.message.count-1 {
            
            let urlString = "https://dog.ceo/api/breed/\(breeds.message[i])/images/random"
            let url = URL(string: urlString)
            
            URLSession.shared.dataTask(with: url!) {(data, response, error) in
                
                if error == nil {
                    do {
                        self.images[i] = try JSONDecoder().decode(Image.self, from: data!)
                        DispatchQueue.main.async {
                            completed()
                        }
                    } catch {
                        print("JSON Error: Image")
                    }
                }
                }.resume()
        }
    }
    
}


extension DogBreedScreen: UITableViewDataSource, UITableViewDelegate {
    
    /*
     Function to manage the header title as user scrolls
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.smallTitleLabel.alpha = 1
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            // Calculate new header height
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.updateHeader()
                self.setScrollPosition(self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    /*
     Function to expand or collapse header depending on users scrolling
     */
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    /*
     Function to prevent header from animating when user reaches end of tableview
     */
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    /*
     Function to collapse header
     */
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    /*
     Function to expand header
     */
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    /*
     Function to set the current scroll position and offset as the user scrolls
     */
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    /*
     Function to update the header as the user scrolls
     */
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        self.titleTopConstraint.constant = -openAmount + 10
        self.largeTitleLabel.alpha = percentage
        self.logoImageView.alpha = percentage
    }
    
    /*
     Function to delegate the number of rows needed in the UITableView
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.breeds.message.count
    }
    
    /*
     Function to set the content in each cell of UITableView
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let breed = self.breeds.message[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell") as! BreedCell
        var imageURL = ""
        if (self.images[78] != nil) {
            imageURL = (self.images[indexPath.row]?.message)!
        }
        cell.setCellStyle();
        cell.setBreed(breed: breed, imageURL: imageURL)
        return cell
        
    }
    
    /*
     Function to animate each cell in UITableView
     */
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0;
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        
        UIView.animate(withDuration: 0.8){
            cell.alpha = 1;
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
}



