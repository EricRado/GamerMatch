//
//  ChatMessageCollectionViewCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/9/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class ChatMessageCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func showIncomingMessage(text: String) {
        backgroundColor = UIColor.red
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.text = text
        
        let constraintRect = CGSize(width: 0.667 * frame.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingBox = text.boundingRect(with: constraintRect, options: options,
                                            attributes: [.font: label.font], context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        let bubbleImageSize = CGSize(width: label.frame.width + 28,
                                     height: label.frame.height + 20)
        
        let incomingMessageView = UIImageView(frame:
            CGRect(x: 16,
                   y: 0,
                   width: bubbleImageSize.width,
                   height: bubbleImageSize.height))
        
        let bubbleImage = UIImage(named: "incoming-message-bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch)
    
        incomingMessageView.image = bubbleImage
        
        addSubview(incomingMessageView)
        
        label.center = incomingMessageView.center
        
        addSubview(label)
    }
    
    func showOutgoingMessage(text: String) {
        backgroundColor = UIColor.green
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text
        
        let testWidth = 0.667 * frame.width
        print("This is the test width: \(testWidth)")
        let constraintRect = CGSize(width: 0.667 * frame.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingBox = text.boundingRect(with: constraintRect, options: options,
                                            attributes: [.font: label.font], context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        let bubbleImageSize = CGSize(width: label.frame.width + 28,
                                     height: label.frame.height + 20)
        
        let outgoingMessageView = UIImageView(frame:
            CGRect(x: frame.width - bubbleImageSize.width - 20,
                   y: 0,
                   width: bubbleImageSize.width,
                   height: bubbleImageSize.height))
        
        let bubbleImage = UIImage(named: "outgoing-message-bubble")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch)
        
        outgoingMessageView.image = bubbleImage
        
        addSubview(outgoingMessageView)
        
        label.center = outgoingMessageView.center
        
        addSubview(label)
    }
    
}

















