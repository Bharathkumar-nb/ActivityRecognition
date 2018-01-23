//
//  ViewController.swift
//  ActivityRecognition
//
//  Created by Bharath on 12/17/17.
//  Copyright © 2017 Bharath. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var stationaryLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var runningLabel: UILabel!
    @IBOutlet weak var automativeLabel: UILabel!
    @IBOutlet weak var cyclingLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!

    let activityManager = CMMotionActivityManager()
    
    var timer: Timer?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopTimer()
        self.activityManager.stopActivityUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: {
                [weak self] (data: CMMotionActivity?) in
                DispatchQueue.main.async (
                    execute: {
                        if let data = data {
                            self?.stationaryLabel.text = "Stationary: \(data.stationary)"
                            self?.walkingLabel.text = "Walking: \(data.walking)"
                            self?.runningLabel.text = "Running: \(data.running)"
                            self?.automativeLabel.text = "Automative: \(data.automotive)"
                            self?.cyclingLabel.text = "Cycling: \(data.cycling)"
                            self?.confidenceLabel.text = "Confidence: \(data.confidence.rawValue)"
                        }
                    }
                )
            })
            
        }
        self.startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startTimer() {
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func loop() {
        var request = URLRequest(url: URL(string: "http://128.223.4.35/~bharathk/activityrecognition.php")!)
        request.httpMethod = "POST"
        
        let postString = "readings=" + self.stationaryLabel.text!
            + ", "  + self.walkingLabel.text!
            + ", "  + self.runningLabel.text!
            + ", "  + self.automativeLabel.text!
            + ", "  + self.cyclingLabel.text!
            + ", "  + self.confidenceLabel.text!
        // print(postString)
        // NSLog(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }

}

