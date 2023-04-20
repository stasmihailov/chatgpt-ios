//
//  Data.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

var threads: TChats = TChats(chats: [
    TChat(
        id: "75f0d964-9e6c-4816-ba5a-7f1dfaf142dd",
        name: "📱 iOS App Development",
        model: "chatgpt-4",
        messages: [
            TChatMsg(
                id: "8e53e83a-1ceb-4029-a056-cac71361367b",
                source: .USER,
                time: "17:31",
                text: "You are a world-class iOS developer. you have developed multiple award-winning apps. You know exactly what it takes to develop a perfect app, including design development, marketing legal terms and pricing."
            ),
            TChatMsg(
                id: "421a513f-a9b8-4953-bb27-9496d5031501",
                source: .ASSISTANT,
                time: "17:31",
                text: """
                As an AI language model, I don't have personal experience as an iOS developer, but I can provide you with some general insights and recommendations based on industry best practices and research.
                
                When it comes to developing a perfect iOS app, there are several key factors to consider.
                """
            ),
            TChatMsg(
                id: "dfe5f42d-d837-4871-9e07-f77e6b407123",
                source: .USER,
                time: "17:34",
                text: "Are you running on GPT 3.5?"
            ),
            TChatMsg(
                id: "b0289953-50a3-4e06-938a-de6f55850cf2",
                source: .ASSISTANT,
                time: "17:34",
                text: """
                I apologize for the confusion. As an AI language model, I don't actually "run" on any specific version of the GPT architecture. Rather, my underlying architecture and capabilities are based on a combination of several different language models, including GPT-3, as well as additional training data and algorithms developed by OpenAI. The specific version or versions of the GPT architecture that were used in my training and development are not publicly disclosed by OpenAI.
                """
            ),
            TChatMsg(
                id: "c1525c47-eed5-4434-8318-b94ffa49564e",
                source: .USER,
                time: "17:46",
                text: "What does it take to develop an app which looks and feels like a native iOS app, yeah, resembles the UI of chatgpt?"
            ),
            TChatMsg(
                id: "7faa85ce-9637-43bd-b447-4bfe370f09f2",
                source: .ASSISTANT,
                time: "17:34",
                text: """
                Developing an app that looks and feels like a native iOS app requires careful attention to detail and adherence to Apple's Human Interface Guidelines. Here are some tips to help you create an app with a UI similar to ChatGPT:
                """
            ),
            TChatMsg(
                id: "e189df8f-941c-4d2d-83b4-dc6e6b64f6b1",
                source: .USER,
                time: "17:51",
                text: "How to render a text input, which is used in messaging apps, in a swift app?"
            ),
            TChatMsg(
                id: "dbb50391-6873-443e-a499-6029a1192c66",
                source: .ASSISTANT,
                time: "17:51",
                text: """
                In order to render a text input in a Swift app that resembles the text input used in messaging apps, you can use a UITextField or UITextView control.

                Here are the steps to create a basic text input using a UITextField control:
                """
            ),
            TChatMsg(
                id: "57644052-5eb1-492b-adc7-e977ecbd1759",
                source: .USER,
                time: "18:26",
                text: "Write a text field in swift which would visually and technically resemble the text code with a button which is used for sending text in telegram"
            ),
            TChatMsg(
                id: "88a20e2e-94c3-4e64-951a-62a7ed88c0dd",
                source: .ASSISTANT,
                time: "18:26",
                text: """
                To create a text field in Swift that resembles the text input field in Telegram, you can use a combination of a UITextView control and a UIButton control. Here's some sample code to help you get started:
                """
            ),
            TChatMsg(
                id: "04472164-162a-4927-9094-16da775ebf1b",
                source: .USER,
                time: "20:21",
                text: "what are the differences between class and struct?"
            ),
            TChatMsg(
                id: "f068439c-a634-4509-b10b-75b509aadb35",
                source: .ASSISTANT,
                time: "20:21",
                text: """
                In Swift, both classes and structs are used to define custom data types, but they have some key differences in terms of how they are used and their underlying behavior.

                Here are some of the key differences between classes and structs:
                """
            )
        ],
        pinned: true
    ),
    TChat(
        id: "12d2bc67-97bc-442d-ab54-efbc5b140f74",
        name: "Start WebSocket Server - Java",
        model: "chatgpt-3",
        messages: [
            TChatMsg(
                id: "e05b4dc9-beac-475c-bb59-29ee64e88ec1",
                source: .ASSISTANT,
                time: "10:03",
                text: "Designing a WebSocket API involves defining the message formats, endpoints")
        ],
        pinned: false
    ),
    TChat(
        id: "da782611-e1f5-4e3a-a677-912d9282d709",
        name: "An empty chat",
        model: "chatgpt-3",
        messages: [],
        pinned: false
    )
]);
