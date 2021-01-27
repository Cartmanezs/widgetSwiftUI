//
//  BatteryViewModel.swift
//  widget
//
//  Created by Ingvar on 28.01.2021.
//

import SwiftUI

class BatteryViewModel: ObservableObject {
    @Published var status: UIDevice.BatteryState = .unknown
    @Published var remain = ""
    
    func startMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelChanged(notification:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateChanged(notification:)), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        UIDevice.current.isBatteryMonitoringEnabled = true
        remain = String(format: "%0.1f", UIDevice.current.batteryLevel * 100)
        status = UIDevice.current.batteryState
    }
    
    func stopMonitor() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    
    @objc func batteryLevelChanged(notification: Notification) {
        remain = String(format: "%0.1f", UIDevice.current.batteryLevel * 100)
    }
    
    @objc func batteryStateChanged(notification: Notification) {
        status = UIDevice.current.batteryState
    }
}

