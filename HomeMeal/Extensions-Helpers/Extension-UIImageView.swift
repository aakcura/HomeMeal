//
//  Extension-UIImageView.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import SDWebImage

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String, defaultImage: UIImage = AppIcons.addPhoto) {
        self.image = nil
        if urlString.isEmpty{
            self.image = defaultImage
        }else{
            self.sd_setImage(with: URL(string: urlString)) { (image, error, cacheType, url) in
                if error != nil {
                    self.image = defaultImage
                }
            }
        }
    }
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
