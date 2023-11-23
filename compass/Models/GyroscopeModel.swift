//
//  GyroscopeModel.swift
//  compass
//
//  Created by Massimo Paloscia on 21/11/23.
//

import Foundation
import CoreMotion
import SwiftUI


class GyroscopeModel: ObservableObject {
    let motionManager = CMMotionManager()
    let deviceMotion = CMDeviceMotion()
    
    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    @Published var degrees: Double = 0
 
    init() {
        if motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 100.0
            self.motionManager.showsDeviceMovementDisplay = true
            
            self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { (data, error) in
                
                if let validData = data {
                    
                    self.roll = validData.attitude.roll
                    self.pitch = validData.attitude.pitch
                    //self.yaw = validData.attitude.yaw
                    //self.yaw = validData.heading
                    //self.degrees = ((self.yaw * (180.0/Double.pi))+360).truncatingRemainder(dividingBy: 360.0)
                    self.degrees = validData.heading
                
                    
                            
                    }
                        
                }
                
            }
        }
    }

