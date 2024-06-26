//
//  CatTableViewCell.swift
//  AIChatApp
//
//  Created by Yiğithan Sönmez on 10.03.2024.
//

import UIKit
import Kingfisher

enum SenderType {
    case user
    case chatGPT
    case persona
    case imageGenerator
}

struct ChatCellPresentation {
    let senderType: SenderType
    let senderName: String
    let senderImage: String?
    let message: String
    let imageMessage: [String]?
}

class ChatTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "ChatUserTableViewCell"
    
    private var senderType: SenderType = .user
    
    let senderNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let senderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let firstImageMessageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let secondImageMessageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let firstActivityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
//        spinner.style = .large
        spinner.isHidden = true
        return spinner
    }()
    
    private let secondActivityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
//        spinner.style = .large
        spinner.isHidden = true
        return spinner
    }()
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareView()
    }
    
    override func prepareForReuse() {
        backgroundColor = .systemBackground
    }
    
    private func prepareView() {
        addSubview(senderNameLabel)
        addSubview(messageLabel)
        addSubview(senderImageView)
        addSubview(firstImageMessageImageView)
        addSubview(secondImageMessageImageView)
        firstImageMessageImageView.addSubview(firstActivityIndicator)
        secondImageMessageImageView.addSubview(secondActivityIndicator)
        
        setupConstraints()
    }
    
    func configure(with presentation: ChatCellPresentation) {
        senderNameLabel.text = presentation.senderName
        messageLabel.text = presentation.message
        self.senderType = presentation.senderType
        
        configureImage(presentation: presentation)
        configureStyle(presentation: presentation)
    }
    
    private func configureImage(presentation: ChatCellPresentation) {
        if let imageMessage = presentation.imageMessage, imageMessage.count > 0 {
            remakeConstraintsForImageMessage()
            // image not yet loaded
            if let first = imageMessage.first, first.isEmpty {
                firstImageMessageImageView.isHidden = false
                firstActivityIndicator.isHidden = false
                firstImageMessageImageView.backgroundColor = .lightGray
                firstActivityIndicator.startAnimating()
            } else {
                var index = 0
                for _ in imageMessage {
                    if index == 0 {
                        if let url1 = URL(string: imageMessage[0]) {
                            firstImageMessageImageView.kf.indicatorType = .activity
                            firstImageMessageImageView.kf.setImage(with: url1)
                            firstImageMessageImageView.isHidden = false
                            firstActivityIndicator.stopAnimating()
                        }
                    } else if index == 1 {
                        if let url2 = URL(string: imageMessage[1]) {
                            secondImageMessageImageView.kf.indicatorType = .activity
                            secondImageMessageImageView.kf.setImage(with: url2)
                            secondImageMessageImageView.isHidden = false
                            firstActivityIndicator.stopAnimating()
                        }
                    }
                    index += 1
                }
            }
        }
    }
    
    private func configureStyle(presentation: ChatCellPresentation) {
        if senderType == .user {
            senderImageView.image = UIImage(systemName: presentation.senderImage ?? "")
        }else {
            senderImageView.image = UIImage(named: presentation.senderImage ?? "")
            backgroundColor = .customBackground
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        senderImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(15)
            make.width.height.equalTo(30)
        }
        
        senderNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalTo(senderImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-15).priority(999)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(senderNameLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-15)
            make.leading.equalTo(senderImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-15).priority(999)
        }
        
        firstActivityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        secondActivityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        firstImageMessageImageView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(5)
            make.leading.equalTo(senderImageView.snp.trailing).offset(15)
            make.height.width.equalTo(150)
        }
        
        secondImageMessageImageView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(5)
            make.leading.equalTo(firstImageMessageImageView.snp.trailing).offset(5)
            make.height.width.equalTo(150)
        }
    }
    
    private func remakeConstraintsForImageMessage() {
        messageLabel.snp.remakeConstraints { make in
            make.top.equalTo(senderNameLabel.snp.bottom).offset(5)
            make.leading.equalTo(senderImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        firstImageMessageImageView.snp.remakeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(5)
            make.leading.equalTo(senderImageView.snp.trailing).offset(15)
            make.height.width.equalTo(150)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        secondImageMessageImageView.snp.remakeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(5)
            make.leading.equalTo(firstImageMessageImageView.snp.trailing).offset(5)
            make.height.width.equalTo(150)
        }
    }
}
