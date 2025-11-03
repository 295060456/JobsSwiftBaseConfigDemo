//
//  MetalRenderer.swift
//  PNPlayer
//
//  Created by linghugoogle on 2025/10/11.
//

import UIKit
import Metal
import MetalKit
import simd

struct Uniforms { var modelViewProjectionMatrix: float4x4 }

class MetalRenderer: NSObject {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var depthStencilState: MTLDepthStencilState?
    private var samplerState: MTLSamplerState?
    private var uniformBuffer: MTLBuffer?
    private let sphere: SphereGeometry
    private let cameraController = CameraController()
    private let videoTextureManager: VideoTextureManager
    // 可选：持有 view，用于像素格式/采样同步
    private weak var boundView: MTKView?

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.sphere = SphereGeometry(device: device, radius: 1.0, segments: 128)
        self.videoTextureManager = VideoTextureManager(device: device)
        super.init()
        setupMetal()
        setupBuffers()
    }
    /// 供外部传入 MTKView，以匹配像素格式/采样数（建议在外部创建 MTKView 后调用）
    @discardableResult
    func attach(view: MTKView) -> Self {
        self.boundView = view
        // 若 pipeline 已存在但像素格式不匹配，可在此重建（简单处理：直接重建）
        setupMetal()
        return self
    }

    private func setupMetal() {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not create Metal library")
        }
        let vertexFunction   = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")

        // 顶点描述（⚠️ 避免 “Vertex function has input attributes but no vertex descriptor was set.”）
        let vDesc = MTLVertexDescriptor()
        vDesc.attributes[0].format = .float3
        vDesc.attributes[0].offset = 0
        vDesc.attributes[0].bufferIndex = 0

        vDesc.attributes[1].format = .float2
        vDesc.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vDesc.attributes[1].bufferIndex = 0

        vDesc.layouts[0].stride = MemoryLayout<Vertex>.stride
        vDesc.layouts[0].stepFunction = .perVertex

        // Render Pipeline（全链式 by-DSL）
        let rpDesc = MTLRenderPipelineDescriptor()
            .byLabel("PNPlayer.Pipeline")
            .byVertexFunction(vertexFunction)
            .byFragmentFunction(fragmentFunction)
            .byVertexDescriptor(vDesc)
            .byRasterSampleCount(boundView?.sampleCount ?? 4)
            .byColorAttachment(0, pixelFormat: boundView?.colorPixelFormat ?? .bgra8Unorm)
            .byDepthPixelFormat(boundView?.depthStencilPixelFormat ?? .depth32Float)

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: rpDesc)
        } catch {
            fatalError("Could not create render pipeline state: \(error)")
        }

        // Depth/Stencil（内球只渲染天空，可禁写深度减少闪烁）
        let dsDesc = MTLDepthStencilDescriptor()
            .byLabel("PNPlayer.Depth")
            .byDepthCompare(.less)
            .byDepthWriteEnabled(false) // 内部天空盒通常关闭写入，避免偶发闪烁
        depthStencilState = device.makeDepthStencilState(descriptor: dsDesc)
        // 采样器
        samplerState = device.makeSamplerState(
            descriptor: MTLSamplerDescriptor()
                .byLabel("PNPlayer.Sampler")
                .byMinFilter(.linear)
                .byMagFilter(.linear)
                .byMipFilter(.linear)
                .bySAddressMode(.clampToEdge)
                .byTAddressMode(.clampToEdge)
                .byMaxAnisotropy(16)
        )
    }

    private func setupBuffers() {
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: [])
    }
    // MARK: - Video
    func loadVideo(url: URL) { videoTextureManager.loadVideo(url: url) }
    func playVideo() { videoTextureManager.play() }
    func pauseVideo() { videoTextureManager.pause() }
    func togglePlayPause() { videoTextureManager.togglePlayPause() }

    @discardableResult
    func bySeekToTime(_ time: TimeInterval) -> Self { videoTextureManager.seek(to: time); return self }

    @discardableResult
    func byVideoTextureManagerDelegate(_ delegate: VideoTextureManagerDelegate) -> Self {
        videoTextureManager.delegate = delegate; return self
    }
    // MARK: - Interaction
    func handlePan(_ gesture: UIPanGestureRecognizer, in view: UIView) {
        cameraController.handlePan(gesture, in: view)
    }
}
// MARK: - MTKViewDelegate
extension MetalRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // 如需根据分辨率重建投影，可写在这里
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let rpd = view.currentRenderPassDescriptor,
              let pso = pipelineState,
              let cmd = commandQueue.makeCommandBuffer(),
              let enc = cmd.makeRenderCommandEncoder(descriptor: rpd) else { return }

        updateUniforms(viewSize: view.drawableSize)

        enc.setRenderPipelineState(pso)
        enc.setDepthStencilState(depthStencilState)

        // 内球渲染建议：不开启剔除或剔除背面；视具体球面顶点绕序
        enc.setCullMode(.none)               // inside sphere 更安全
        enc.setFrontFacing(.counterClockwise)

        enc.setVertexBuffer(sphere.vertexBuffer, offset: 0, index: 0)
        enc.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        enc.setFragmentSamplerState(samplerState, index: 0)
        if let tex = videoTextureManager.currentTexture {
            enc.setFragmentTexture(tex, index: 0)
        }

        if let ib = sphere.indexBuffer {
            enc.drawIndexedPrimitives(type: .triangle,
                                      indexCount: sphere.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: ib,
                                      indexBufferOffset: 0)
        }

        enc.endEncoding()
        cmd.present(drawable)
        cmd.commit()
    }

    private func updateUniforms(viewSize: CGSize) {
        let aspect = Float(viewSize.width / viewSize.height)
        let proj = float4x4(perspectiveProjectionFov: Float.pi / 3, aspectRatio: aspect, nearZ: 0.1, farZ: 100.0)
        let viewM = cameraController.viewMatrix
        let model = float4x4(1.0)
        let mvp = proj * viewM * model

        var u = Uniforms(modelViewProjectionMatrix: mvp)
        memcpy(uniformBuffer?.contents(), &u, MemoryLayout<Uniforms>.stride)
    }
}
// MARK: - Helpers
extension float4x4 {
    init(_ v: Float) {
        self.init(
            SIMD4<Float>(v, 0, 0, 0),
            SIMD4<Float>(0, v, 0, 0),
            SIMD4<Float>(0, 0, v, 0),
            SIMD4<Float>(0, 0, 0, v)
        )
    }
}
