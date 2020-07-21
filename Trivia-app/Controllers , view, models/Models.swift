//
//  Models.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import Foundation

class HistoryElement: Codable {
    var name: String?
    var dateTime: String?
    var questions: [QuestionDetails]?
    
    init(name: String?, dateTime: String?, questions: [QuestionDetails]?) {
        self.name = name
        self.dateTime = dateTime
        self.questions = questions
    }
}

public class QuestionDetails: NSObject, Codable {
    var questionText: String?
    var answerOptions: [Option]?
    var isMultiSelect: Bool?
    
    init(question: String, options: [Option], isMultiSelect: Bool?) {
        self.questionText = question
        self.answerOptions = options
        self.isMultiSelect = isMultiSelect
    }
}

class Option: NSObject, Codable {
    var optionText: String?
    var isSelectedOption: Bool?
    
    init(optionText: String, isSelected: Bool) {
        self.optionText = optionText
        self.isSelectedOption = isSelected
    }
}
