//
//  UploadAvatarRequest.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import YTKNetwork
import AFNetworking
/// 上传图片：POST /post，httpbin 会把表单字段回显在 "files"/"form"
final class UploadAvatarRequest: YTKRequest {

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init()
    }

    override func requestUrl() -> String {
        return "/post"
    }

    override func requestMethod() -> YTKRequestMethod {
        return .POST
    }

    override func requestSerializerType() -> YTKRequestSerializerType {
        return .HTTP
    }

    override func responseSerializerType() -> YTKResponseSerializerType {
        return .JSON
    }
    /// Multipart 构造
    func constructingBodyBlock() -> ((AFMultipartFormData) -> Void)? {
        return { [weak self] formData in
            guard let self = self else { return }
            guard let data = self.image.jpegData(compressionQuality: 0.9) else { return }
            let fileName = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
            formData.appendPart(
                withFileData: data,
                name: "avatar",                // 这里换成你后端给的字段名
                fileName: fileName,
                mimeType: "image/jpeg"
            )
        }
    }

    func uploadProgressBlock() -> AFURLSessionTaskProgressBlock! {
        return { progress in
            print("upload progress:", progress.fractionCompleted)
        }
    }
}
