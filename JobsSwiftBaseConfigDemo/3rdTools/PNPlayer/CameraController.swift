//
//  CameraController.swift
//  PNPlayer
//
//  Created by linghugoogle on 2025/10/11.
//

import simd
import UIKit

class CameraController {
    private var rotationX: Float = 0.0
    private var rotationY: Float = 0.0
    private var lastPanPoint: CGPoint = .zero
    
    var viewMatrix: float4x4 {
        let rotationXMatrix = float4x4(rotationX: rotationX)
        let rotationYMatrix = float4x4(rotationY: rotationY)
        return rotationXMatrix * rotationYMatrix
    }
    
    func handlePan(_ gesture: UIPanGestureRecognizer, in view: UIView) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            lastPanPoint = translation
        case .changed:
            let deltaX = Float(translation.x - lastPanPoint.x) * 0.01
            let deltaY = Float(translation.y - lastPanPoint.y) * 0.01
            
            rotationY += deltaX
            rotationX += deltaY
            
            rotationX = max(-Float.pi/2, min(Float.pi/2, rotationX))
            
            lastPanPoint = translation
        case .ended, .cancelled:
            break
        default:
            break
        }
    }
}

extension float4x4 {
    init(rotationX angle: Float) {
        let c = cos(angle)
        let s = sin(angle)
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, c, s, 0),
            SIMD4<Float>(0, -s, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
    init(rotationY angle: Float) {
        let c = cos(angle)
        let s = sin(angle)
        self.init(
            SIMD4<Float>(c, 0, -s, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(s, 0, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
    init(perspectiveProjectionFov fov: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
        let yScale = 1 / tan(fov * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = farZ - nearZ
        let zScale = -(farZ + nearZ) / zRange
        let wzScale = -2 * farZ * nearZ / zRange
        
        self.init(
            SIMD4<Float>(xScale, 0, 0, 0),
            SIMD4<Float>(0, yScale, 0, 0),
            SIMD4<Float>(0, 0, zScale, -1),
            SIMD4<Float>(0, 0, wzScale, 0)
        )
    }
}
