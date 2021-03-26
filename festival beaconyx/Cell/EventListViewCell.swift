//
//  EventListViewCell.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 01/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

class EventListViewCell: UITableViewCell {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var proceedView: UIView!
    @IBOutlet weak var snsView: UIView!
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var proceedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var readcountLabel: UILabel!
    
    @IBOutlet weak var subTitleViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var scrapButton: UIButton!
    @IBOutlet weak var naverButton: UIButton!
    @IBOutlet weak var scrapImageView: UIImageView!
        
    @IBOutlet weak var scrapView: UIView!
    
    var link: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.selectedLanguage == "Kor" {
            scrapView.isHidden = false
        } else {
            scrapView.isHidden = true
        }
        
        self.bannerView.layer.shadowColor = UIColor.black.cgColor
        self.bannerView.layer.shadowOffset = CGSize(width: 0, height: 3.5)
        self.bannerView.layer.shadowRadius = 5
        self.bannerView.layer.shadowOpacity = 0.8
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
