//
//  PicLoadDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

import UIKit
import SnapKit
import Kingfisher

final class PicLoadDemoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PicLoad Demo"
        view.backgroundColor = .systemBackground

        setupLocalImage()
        setupRemoteImageByAsync()
        setupRemoteImageByKFSet()
    }

    // ================================== 本地图片 ==================================
    private func setupLocalImage() {
        let localImageView = UIImageView()
            .byImage("Ani".img)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()

        view.addSubview(localImageView)
        localImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }
    }

    // ================================== 网络图片（async/await） ==================================
    private func setupRemoteImageByAsync() {
        let urlImageView = UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()

        view.addSubview(urlImageView)
        urlImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(260)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }

        // ✅ 使用 Kingfisher async/await 异步加载
        let remoteURL = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5V57u3uwX8dGkmezFuaB0DJZAKZ96WSqkIESLbqA9tDovtwHMenRqkZSgnU53po0D848OguVoTqzxzzGaUusl-OorK_miHQ3p4c6gjrJI9w"

        Task {
            do {
                let image = try await remoteURL.kfLoadImage()
                urlImageView.image = image
                print("✅ 加载成功 (async)：\(remoteURL)")
            } catch {
                print("❌ 加载失败 (async)：\(error)")
            }
        }
    }

    // ================================== 网络图片（setImage 封装） ==================================
    private func setupRemoteImageByKFSet() {
        let kfImageView = UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()

        view.addSubview(kfImageView)
        kfImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(480)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }

        // ✅ 使用自定义封装 setImage(from:placeholder:)
        let fakeURL = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5V57u3uwX8dGkmezFuaB0DJZAKZ96WSqkIESLbqA9tDovtwHMenRqkZSgnU53po0D848OguVoTqzxzzGaUusl-OorK_miHQ3p4c6gjrJI9w"
        kfImageView.setImage(from: fakeURL, placeholder: "Ani".img)
    }
}
