//
//  HistoryView.swift
//  AIChatApp
//
//  Created by Yiğithan Sönmez on 13.03.2024.
//

import UIKit

struct ChatHistoryCellPresentation {
    let aiName: String
    let chatTitle: String?
    let chatMessage: String?
    let createdAt: String
    let isStarred: Bool
    let image: String?
    let chatType: ChatType
}

protocol HistoryViewProtocol: AnyObject {
    func showChatHistory(with presentation: [ChatHistoryCellPresentation])
    func showChatView(vc: ChatView)
}

final class HistoryView: UIViewController {
    var chatHistoryCellPresentation = [ChatHistoryCellPresentation]()
    private lazy var viewModel: HistoryViewModelProtocol = HistoryViewModel(view: self)
    
    private let customSegmentedControl = CustomSegmentedControl()
    
    private let chatHistoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        prepareView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        customSegmentedControl.selectSegment(index: 0)
    }
    
    private func prepareView() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Chat History"
        view.addSubview(customSegmentedControl)
        view.addSubview(chatHistoryTableView)
        
        chatHistoryTableView.delegate = self
        chatHistoryTableView.dataSource = self
        customSegmentedControl.delegate = self
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        customSegmentedControl.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        chatHistoryTableView.snp.makeConstraints { make in
            make.top.equalTo(customSegmentedControl.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension HistoryView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatHistoryCellPresentation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
        cell.configure(with: chatHistoryCellPresentation[indexPath.row])
        cell.viewModel = viewModel
        cell.index = indexPath.row
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.loadChatView(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, success) in
            self?.viewModel.deleteChat(at: indexPath.row)
            self?.chatHistoryCellPresentation.remove(at: indexPath.row)
            self?.chatHistoryTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])
        return swipeActions
    }
}

extension HistoryView: HistoryViewProtocol {
    func showChatHistory(with presentation: [ChatHistoryCellPresentation]) {
        chatHistoryCellPresentation = presentation
        chatHistoryTableView.reloadData()
    }
    
    func showChatView(vc: ChatView) {
        show(vc, sender: self)
    }
}

extension HistoryView: CustomSegmentedControlDelegate {
    func selectedSegment(index: Int) {
        viewModel.segmentSelected(index: index)
    }
}
