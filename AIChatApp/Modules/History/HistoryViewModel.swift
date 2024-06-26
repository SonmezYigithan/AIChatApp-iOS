//
//  HistoryViewModel.swift
//  AIChatApp
//
//  Created by Yiğithan Sönmez on 13.03.2024.
//

import Foundation

protocol HistoryViewModelProtocol: AnyObject {
    func viewDidLoad()
    func fetchAllChats()
    func fetchStarredChats()
    func segmentSelected(index: Int)
    func loadChatView(at index: Int)
    func deleteChat(at index: Int)
    func starChat(at index: Int)
    func unStarChat(at index: Int)
}

final class HistoryViewModel {
    weak var view: HistoryViewProtocol?
    var chatEntities = [ChatEntity]()
    var starredChatEntities = [ChatEntity]()
    
    init(view: HistoryViewProtocol) {
        self.view = view
    }
}

extension HistoryViewModel: HistoryViewModelProtocol {
    func viewDidLoad() {
        guard let chatEntities = ChatSaveManager.shared.loadAllChats() else { return }
        self.chatEntities = chatEntities
        let chatHistoryPresentation = mapChatEntitiesToPresentation(chatEntities: chatEntities)
        view?.showChatHistory(with: chatHistoryPresentation)
    }
    
    func segmentSelected(index: Int) {
        if index == 0 {
            fetchAllChats()
        } else if index == 1 {
            fetchStarredChats()
        }
    }
    
    func fetchAllChats() {
        let chatHistoryPresentation = mapChatEntitiesToPresentation(chatEntities: chatEntities)
        view?.showChatHistory(with: chatHistoryPresentation)
    }
    
    func fetchStarredChats() {
        starredChatEntities = chatEntities.filter { $0.isStarred }
        let chatHistoryPresentation = mapChatEntitiesToPresentation(chatEntities: starredChatEntities)
        view?.showChatHistory(with: chatHistoryPresentation)
    }
    
    private func mapChatEntitiesToPresentation(chatEntities: [ChatEntity]) -> [ChatHistoryCellPresentation] {
        let dateFormatter = DateFormatter()
        
        let chatHistoryPresentation = chatEntities.map {
            var chatTypeValue: ChatType = .textGeneration
            if let chatType = ChatType(rawValue: Int($0.chatType)) {
                chatTypeValue = chatType
            }
            
            var chatMessage = ""
            if let messages = $0.messages {
                if let last = messages.last {
                    chatMessage = last.textMessage ?? ""
                }
            }
            
            var date = ""
            if Calendar.current.isDateInToday($0.createdAt) {
                dateFormatter.dateFormat = "h:mm a"
            }else {
                dateFormatter.dateFormat = "MMM d"
            }
            date = dateFormatter.string(from: $0.createdAt)
            
            return ChatHistoryCellPresentation(aiName: $0.aiName ?? "",
                                               chatTitle: $0.chatTitle,
                                               chatMessage: chatMessage,
                                               createdAt: date,
                                               isStarred: $0.isStarred,
                                               image: $0.aiImage,
                                               chatType: chatTypeValue)
        }
        return chatHistoryPresentation
    }
    
    func loadChatView(at index: Int) {
        let chat = chatEntities[index]
        var chatTypeValue: ChatType = .textGeneration
        if let chatType = ChatType(rawValue: Int(chat.chatType)) {
            chatTypeValue = chatType
        }
        
        let chatMessages = ChatSaveManager.shared.loadChatMessages(chatId: chat.chatId)
        let chatParameters = ChatParameters(chatType: chatTypeValue,
                                            aiName: chat.aiName ?? "",
                                            aiImage: chat.aiImage ?? "",
                                            startPrompt: chat.startPrompt,
                                            isStarred: chat.isStarred,
                                            createdAt: chat.createdAt,
                                            chatId: chat.chatId,
                                            greetingMessage: nil,
                                            chatTitle: chat.chatTitle)
        
        guard let chatMessages = chatMessages else { return }
        let vc = ChatViewBuilder.make(chatParameters: chatParameters, chatMessages: chatMessages)
        view?.showChatView(vc: vc)
    }
    
    func deleteChat(at index: Int) {
        ChatSaveManager.shared.deleteChat(chatId: chatEntities[index].chatId)
        chatEntities.remove(at: index)
    }
    
    func starChat(at index: Int) {
        ChatSaveManager.shared.starChat(chatEntity: chatEntities[index])
    }
    
    func unStarChat(at index: Int) {
        ChatSaveManager.shared.unStarChat(chatEntity: chatEntities[index])
    }
}
