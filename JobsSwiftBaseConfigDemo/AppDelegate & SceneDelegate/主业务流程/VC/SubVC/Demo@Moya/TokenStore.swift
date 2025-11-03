//
//  TokenStore.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation

public final class TokenStore {
    public static let shared = TokenStore()
    private init() {}

    public var accessToken: String? = nil
    public var refreshToken: String? = nil
}
