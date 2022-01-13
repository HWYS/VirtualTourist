//
//  UIViewController+Extensions.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/13/22.
//

import Foundation
import UIKit

extension UIViewController {
    var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
}
