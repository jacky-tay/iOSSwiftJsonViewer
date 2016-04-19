//
//  ViewController.swift
//  TestingApp
//
//  Created by Jacky Tay on 9/04/16.
//  Copyright © 2016 Jacky Tay. All rights reserved.
//
import JSONViewer
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let path = NSBundle.mainBundle().pathForResource("testing", ofType: "json"),
            content = try? String(contentsOfFile: path),
            viewController = JSONViewerViewController.getViewController(content) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

