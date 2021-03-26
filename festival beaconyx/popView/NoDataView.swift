//
//  NoDataView.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 18/11/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

class NoDataView: UIView {
    private let xibName = "NoDataView"
    
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.mainTextLabel.text = appDelegate.languageDic["common_no_data"]
        self.subTextLabel.text = appDelegate.languageDic["list_no_more_data"]
        
        self.addSubview(view)
    }
}
