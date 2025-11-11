//
//  LiveMsg.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//

// ============================== Model ==============================
struct LiveMsg: Hashable {
    let id = UUID()
    let text: String
    let time = Date()
}
