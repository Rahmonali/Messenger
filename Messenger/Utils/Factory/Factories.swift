//
//  Factories.swift
//  Messenger
//
//  Created by Rahmonali on 24/01/25.
//

import UIKit

// TODO: Remove the extra things

func makeLabel(
    withText text: String? = nil,
    textStyle: UIFont.TextStyle = .body,
    textColor: UIColor = .label,
    isBold: Bool = false,
    textAlignment: NSTextAlignment = .left,
    numberOfLines: Int = 1
) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.textColor = textColor
    label.font = isBold ? UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
    : UIFont.preferredFont(forTextStyle: textStyle)
    label.textAlignment = textAlignment
    label.numberOfLines = numberOfLines
    
    return label
}



let buttonHeight: CGFloat = 40
func makeButton(withText title: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .tintColor
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: buttonHeight, bottom: 10, trailing: buttonHeight)
    button.configuration = config
    
    let attributedText = NSMutableAttributedString(string: title, attributes: [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.kern: 1
    ])
    
    button.setAttributedTitle(attributedText, for: .normal) // Note how not button.setTitle()
    
    return button
}




func makeStackView(withOrientation axis: NSLayoutConstraint.Axis) -> UIStackView {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = axis
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.spacing = 12.0
    
    return stackView
}

public func makeSpacerView(height: CGFloat? = nil) -> UIView {
    let spacerView = UIView(frame: .zero)
    if let height = height {
        spacerView.heightAnchor.constraint(equalToConstant: height).setActiveBreakable()
    }
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    return spacerView
}


public extension NSLayoutConstraint {
    @objc func setActiveBreakable(priority: UILayoutPriority = UILayoutPriority(900)) {
        self.priority = priority
        isActive = true
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
