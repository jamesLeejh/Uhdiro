//
//  URLLoadImageView.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 29/10/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import UIKit

class URLLoadImageView: UIImageView {
    
    func loadURLImage(imageUrlStr : String)  {
      
        let imageURL: URL = URL(string: imageUrlStr)!
                if let image = UIImage(data: try! Data(contentsOf: imageURL)){
            
            self.image = image
            
        }
    }
    

    
    func setPaddingImage(image: UIImage){
        let resizeResult = image.imageWithInsets(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))

        self.image = resizeResult
    }

    func loadURLImageWithPadding(imageUrlStr: String) {
        
        let imageURL: URL = URL(string: imageUrlStr)!

        if let image = UIImage(data: try! Data(contentsOf: imageURL)){

            let resizeResult = image.imageWithInsets(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))

            self.image = resizeResult
        }
    }

}

extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}

