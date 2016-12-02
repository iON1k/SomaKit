//
//  ViewController.swift
//  SomaKitExample
//
//  Created by Anton on 21.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import UIKit
import SomaKit
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageLoader = ImageLoader(imageSource: NetworkImageSource<String>())
        
        _ = imageView.loadImage(key: "YourImageURL", loader: imageLoader)
            .round()
            .blur(blurType: .gaussian(radius: 10))
            .subscribe()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

