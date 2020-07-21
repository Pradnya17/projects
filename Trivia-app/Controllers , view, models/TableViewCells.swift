//
//  TableViewCells.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var optionText: UILabel!
    weak var delegate: OptionSelectionDelegate?
    
    var isMultiSelect: Bool = false
    var option: Option?
    
    func configure(option: Option?, isMultiSelect: Bool?, delegate: OptionSelectionDelegate?) -> Self {
        self.optionText.text = option?.optionText
        self.selectBtn.isSelected = option?.isSelectedOption ?? false
        self.isMultiSelect = isMultiSelect ?? false
        self.delegate = delegate
        self.option = option
        configureSelectLook()
        return self
    }
    
    func configureSelectLook() {
        let imageName = (selectBtn.isSelected && isMultiSelect) ? "checkmark.square.fill" : selectBtn.isSelected ? "largecircle.fill.circle" : isMultiSelect ? "square" : "circle"
        selectBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func optionSelected(_ sender: UIButton) {
        option?.isSelectedOption = !(self.option?.isSelectedOption ?? false)
        delegate?.optionSelected(option: option)
    }
}

class HeadingCell: UITableViewCell {
    
    @IBOutlet weak var heading: UILabel!
    
    func configure(heading: String) -> Self {
        self.heading.text = heading
        return self
    }
}

class SubHeadingCell: UITableViewCell {
    
    @IBOutlet weak var subHeading: UILabel!
    
    func configure(subHeading: String) -> Self {
        self.subHeading.text = subHeading
        return self
    }
}

class QAndACell: UITableViewCell {
    
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var answer: UILabel!
    
    func configure(questionText: String?, answerText: String?) -> Self {
        question.text = questionText
        answer.text = answerText
        return self
    }
}
