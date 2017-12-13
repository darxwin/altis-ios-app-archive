//
//  FirstViewController.swift
//  Altis
//
//  Created by Hunter Ray on 6/2/17.
//  Copyright © 2017 Judge2020. All rights reserved.
//

import UIKit
import Alamofire
import SystemConfiguration
import CoreTelephony
import Foundation


class FirstViewController: UIViewController {

    @IBOutlet weak var LabelStatus: UILabel!
    @IBOutlet var OurActivity: UIActivityIndicatorView!
    
    var OurTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LabelStatus.text = "checking..."
        LabelStatus.textColor = UIColor.black
        
        OurActivity.hidesWhenStopped = true
        // Do any additional setup after loading the view, typically from a nib.
        IsOnline()
        
        OurTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.IsOnline), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func IsOnline() {
        if(!Reachability.isInternetAvailable()){
            LabelStatus.text = "unavailable"
            LabelStatus.textColor = UIColor.gray
            return
        }
        OurActivity.startAnimating()
        let req = Alamofire.request("https://projectaltis.com/api/status")
        req.validate()
        req.responseString(completionHandler: { response in
            if(response.value!.contains("gs1.projectaltis.com is up")){
                self.LabelStatus.text = "ONLINE"
                self.LabelStatus.textColor = UIColor.green
                
                self.OurActivity.stopAnimating()
            }
            else {
                self.LabelStatus.text = "OFFLINE"
                self.LabelStatus.textColor = UIColor.red
                
                self.OurActivity.stopAnimating()
            }
        })
    }
    
}
public class Reachability {
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}

