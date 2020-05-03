//
//  ContactTableViewCell.swift
//  ContactListExample
//
//  Created by Vivatum on 12/04/2020.
//  Copyright © 2020 com.vivatum. All rights reserved.
//

import UIKit
import CocoaLumberjack
import RealmSwift


final class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
        
    var contactData: Contact? {
        didSet {
            populateCellContent()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.picImageView.makeRoundView()
    }
    
    
    // MARK: - Favorite Status Action
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        DDLogInfo("Favorite button pressed")
        guard let contact = self.contactData else { return }
        let contactRef = ThreadSafeReference(to: contact)
        RealmService.shared.updateFavoritedStatus(contactRef, !contact.isFavorited)
    }
    
    // MARK: - Cell content
    
    private func populateCellContent() {
        guard let contact = self.contactData else { return }
        self.nameLabel.text = contact.lastName + " " + contact.firstName
        self.populateThumbImage(with: contact.thumbnailPic)
        self.updateFavoriteButton(with: contact.isFavorited)
    }
    
    private func populateThumbImage(with path: String) {
        guard let url = URL(string: path) else {
            DDLogError("Can't get pic URL")
            return
        }
        
        DispatchQueue.main.async {
            if let placeholderImage = UIImage(named: "placeholder_pic") {
                self.picImageView?.image = placeholderImage
            }
        }
        
        ImageLoader.shared.getImageData(url) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.picImageView?.image = UIImage(data: data)
                }
            case .failure(let error):
                DDLogError("Can't get contact image data: \(error.localizedDescription)")
            }
        }
    }

    private func updateFavoriteButton(with status: Bool) {
        let buttonImage: UIImage? = status ? UIImage(named: "starFavorited") : UIImage(named: "star")
        if let image = buttonImage {
            DispatchQueue.main.async {
                self.favoriteButton.setImage(image, for: .normal)
            }
        }
    }
}
