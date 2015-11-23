//
//  ViewController.swift
//  OnDemandResourceSample
//
//  Created by 鈴木 慎吾 on 2015/11/23.
//  Copyright © 2015年 JPOP-NEWS.net. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var resourceRequest: NSBundleResourceRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onButton(sender: AnyObject) {
        let tags = NSSet(array: ["Sample1"])
        resourceRequest = NSBundleResourceRequest(tags: tags as! Set<String>)
        resourceRequest?.conditionallyBeginAccessingResourcesWithCompletionHandler() {
            resourceAvailable in
            
            if resourceAvailable {
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageView.image = UIImage(named: "mydog")
                }
            } else {
                // 優先度は0.0-1.0の間で指定できる。
                //self.resourceRequest?.loadingPriority = 0.8
                
                // 進捗監視したい場合
                self.resourceRequest?.progress.addObserver(self, forKeyPath: "fractionCompleted", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer())

                self.resourceRequest?.beginAccessingResourcesWithCompletionHandler() {
                    error in
                    if error == nil {
                        // 進捗監視解除。本番は異常系も考慮するように
                        self.resourceRequest?.progress.removeObserver(self, forKeyPath: "fractionCompleted", context: UnsafeMutablePointer())
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.imageView.image = UIImage(named: "mydog")
                        }
                    }
                }
            }
        }
    }
    
    // 進捗管理用
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if ((object as! NSProgress == resourceRequest!.progress) &&
            (keyPath! == "fractionCompleted")) {
                // Get the current progress as a value between 0 and 1
                let progressSoFar = resourceRequest!.progress.fractionCompleted;
                print(progressSoFar)
        }
    }

}

