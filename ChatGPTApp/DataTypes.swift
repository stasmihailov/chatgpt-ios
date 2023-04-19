//
//  DataTypes.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

enum ChatMessageRoleData {
    case USER, ASSISTANT;
}

struct ChatThreadData {
    var id: String;
    var name: String;
    var model: String;
    var messages: [ChatMessageData];
    var pinned: Bool;
}

struct ChatMessageData {
    var id: String;
    var source: ChatMessageRoleData;
    var time: String;
    var text: String;
}
