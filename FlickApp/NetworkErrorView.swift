//
//  NetworkErrorView.swift
//  FlickApp
//
//  Created by Hoang Trung Hieu on 3/13/16.
//  Copyright © 2016 Hoang Trung Hieu. All rights reserved.
//

import UIKit

class NetworkErrorView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // init network error
        self.frame = CGRect(x: 0, y: 0, width: 320, height: 21)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 21))
        errorLabel.textAlignment = .Center
        errorLabel.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        errorLabel.text = "Network Error"
        self.addSubview(errorLabel)
        self.hidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
