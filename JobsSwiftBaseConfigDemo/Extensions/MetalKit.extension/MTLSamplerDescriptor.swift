//
//  MTLSamplerDescriptor.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/30/25.
//

import Metal

public extension MTLSamplerDescriptor {
    // 统一入口：链式配置
    @discardableResult
    func dsl(_ make: (MTLSamplerDescriptor) -> Void) -> Self {
        make(self); return self
    }
    // 标识
    @discardableResult
    func byLabel(_ text: String?) -> Self { self.label = text; return self }
    // 过滤
    @discardableResult
    func byMinFilter(_ f: MTLSamplerMinMagFilter) -> Self { self.minFilter = f; return self }

    @discardableResult
    func byMagFilter(_ f: MTLSamplerMinMagFilter) -> Self { self.magFilter = f; return self }

    @discardableResult
    func byMipFilter(_ f: MTLSamplerMipFilter) -> Self { self.mipFilter = f; return self }
    // 采样各向异性（Metal 最大 16，顺手夹一下）
    @discardableResult
    func byMaxAnisotropy(_ n: Int) -> Self {
        self.maxAnisotropy = max(1, min(16, n)); return self
    }
    // 环绕模式
    @discardableResult
    func bySAddressMode(_ m: MTLSamplerAddressMode) -> Self { self.sAddressMode = m; return self }

    @discardableResult
    func byTAddressMode(_ m: MTLSamplerAddressMode) -> Self { self.tAddressMode = m; return self }

    @discardableResult
    func byRAddressMode(_ m: MTLSamplerAddressMode) -> Self { self.rAddressMode = m; return self }
    // 边框色（iOS 14+）
    @available(iOS 14.0, *)
    @discardableResult
    func byBorderColor(_ c: MTLSamplerBorderColor) -> Self { self.borderColor = c; return self }
    // 归一化坐标 / LOD
    @discardableResult
    func byNormalizedCoordinates(_ on: Bool) -> Self { self.normalizedCoordinates = on; return self }

    @discardableResult
    func byLodMinClamp(_ v: Float) -> Self { self.lodMinClamp = v; return self }

    @discardableResult
    func byLodMaxClamp(_ v: Float) -> Self { self.lodMaxClamp = v; return self }

    @available(iOS 9.0, *)
    @discardableResult
    func byLodAverage(_ on: Bool) -> Self { self.lodAverage = on; return self }

    @available(iOS 26.0, *)
    @discardableResult
    func byLodBias(_ v: Float) -> Self { self.lodBias = v; return self }
    // Shadow compare
    @available(iOS 9.0, *)
    @discardableResult
    func byCompareFunction(_ f: MTLCompareFunction) -> Self { self.compareFunction = f; return self }

    @available(iOS 11.0, *)
    @discardableResult
    func bySupportArgumentBuffers(_ on: Bool) -> Self { self.supportArgumentBuffers = on; return self }
    // 🔧 常用预设：视频/全景纹理（线性过滤 + clamp + 各向异性）
    static func videoLinearClamp(aniso: Int = 16, mip: MTLSamplerMipFilter = .linear) -> MTLSamplerDescriptor {
        MTLSamplerDescriptor()
            .byLabel("Jobs.Sampler.Video")
            .byMinFilter(.linear)
            .byMagFilter(.linear)
            .byMipFilter(mip)
            .bySAddressMode(.clampToEdge)
            .byTAddressMode(.clampToEdge)
            .byRAddressMode(.clampToEdge)
            .byMaxAnisotropy(aniso)
            .byNormalizedCoordinates(true)
    }
}
