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
        jobsSetupGKNav(
            title: "PicLoad Demo"
        )
        view.backgroundColor = .systemBackground
        // MARK: - 加载本地图片
        UIImageView()
            .byImage("Ani".img)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10.h)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(180)
            }
        // MARK: - 加载网络图片（async/await）
        Task {
            do {
                UIImageView()
                    .byContentMode(.scaleAspectFill)
                    .byClipsToBounds()
                    .byAddTo(view) { [unowned self] make in
                        make.top.equalTo(view.safeAreaLayoutGuide).offset(260)
                        make.left.right.equalToSuperview().inset(20)
                        make.height.equalTo(180)
                    }.byImage(try await "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5V57u3uwX8dGkmezFuaB0DJZAKZ96WSqkIESLbqA9tDovtwHMenRqkZSgnU53po0D848OguVoTqzxzzGaUusl-OorK_miHQ3p4c6gjrJI9w".kfLoadImage())
                print("✅ 加载成功 (async)")
            } catch {
                print("❌ 加载失败 (async)：\(error)")
            }
        }
        // MARK: - ✅ 使用自定义封装 setImage(from:placeholder:)
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(480)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(180)
            }
            .setImage(from: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5V57u3uwX8dGkmezFuaB0DJZAKZ96WSqkIESLbqA9tDovtwHMenRqkZSgnU53po0D848OguVoTqzxzzGaUusl-OorK_miHQ3p4c6gjrJI9w", placeholder: "Ani".img)
    }
}
