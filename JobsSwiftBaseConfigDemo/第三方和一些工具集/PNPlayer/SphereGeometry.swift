//
//  SphereGeometry.swift
//  PNPlayer
//
//  Created by linghugoogle on 2025/10/11.
//

import Metal
import simd

struct Vertex {
    let position: SIMD3<Float>
    let texCoord: SIMD2<Float>
}

class SphereGeometry {
    private let device: MTLDevice
    private(set) var vertexBuffer: MTLBuffer?
    private(set) var indexBuffer: MTLBuffer?
    private(set) var indexCount: Int = 0

    init(device: MTLDevice, radius: Float = 1.0, segments: Int = 64) {
        self.device = device
        generateSphere(radius: radius, segments: segments)
    }

    private func generateSphere(radius: Float, segments: Int) {
        var vertices: [Vertex] = []
        var indices: [UInt16] = []

        for i in 0...segments {
            let lat = Float(i) / Float(segments) * Float.pi
            let sinLat = sin(lat)
            let cosLat = cos(lat)

            for j in 0...segments {
                let lon = Float(j) / Float(segments) * 2.0 * Float.pi
                let sinLon = sin(lon)
                let cosLon = cos(lon)

                let x = cosLon * sinLat
                let y = cosLat
                let z = sinLon * sinLat

                let u = Float(j) / Float(segments)
                let v = Float(i) / Float(segments)

                vertices.append(Vertex(
                    position: SIMD3<Float>(x * radius, y * radius, z * radius),
                    texCoord: SIMD2<Float>(u, v)
                ))
            }
        }

        for i in 0..<segments {
            for j in 0..<segments {
                let first = UInt16(i * (segments + 1) + j)
                let second = UInt16(first + UInt16(segments + 1))

                indices.append(first)
                indices.append(second)
                indices.append(first + 1)

                indices.append(second)
                indices.append(second + 1)
                indices.append(first + 1)
            }
        }

        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.stride, options: [])
        indexCount = indices.count
    }
}
