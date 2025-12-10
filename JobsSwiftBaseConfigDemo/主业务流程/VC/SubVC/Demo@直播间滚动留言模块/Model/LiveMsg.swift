//
//  LiveMsg.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//
import Foundation
// ============================== Model ==============================
struct LiveMsg: Hashable {
    let id = UUID()
    let time = Date()
    let text: String
}
