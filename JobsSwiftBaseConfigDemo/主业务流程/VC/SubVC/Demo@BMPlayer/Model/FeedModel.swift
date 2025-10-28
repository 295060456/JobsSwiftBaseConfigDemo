//
//  FeedModel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
/// 解析 CommentData.json
struct FeedItem: Decodable {
    let id: String
    let nickname: String
    let content: String
    let headImg: URL?
    let videoURL: URL
}

private struct _CommentListResponse: Decodable {
    struct DataObj: Decodable {
        struct RawItem: Decodable {
            let id: String
            let nickname: String
            let content: String
            let headImg: String
        }
        let list: [RawItem]
    }
    let data: DataObj
}

enum FeedModel {
    // 稳定公开示例视频（可替换为业务直链）
    private static let samples: [URL] = [
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!,
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!,
    ]

    static func loadAll() -> [FeedItem] {
        guard
            let url = Bundle.main.url(forResource: "CommentData", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(_CommentListResponse.self, from: data)
        else { return [] }

        return decoded.data.list.enumerated().map { (idx, r) in
            .init(id: r.id,
                  nickname: r.nickname,
                  content: r.content,
                  headImg: URL(string: r.headImg),
                  videoURL: samples[idx % samples.count])
        }
    }
    // 本地分页（模拟网络）
    static func page(all: [FeedItem], page: Int, pageSize: Int) -> [FeedItem] {
        guard page > 0 && pageSize > 0 else { return [] }
        let start = (page - 1) * pageSize
        let end = min(all.count, start + pageSize)
        return start < end ? Array(all[start..<end]) : []
    }
}
