//
//  ViewController.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 20/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var history: UIButton!
    
    var historyFromCore: [History] = []
    var historyList: [HistoryElement]?
    
    var questions: [QuestionDetails] = [QuestionDetails(question: "Who is the best cricketer in the world?", options: [Option(optionText: "Sachin Tendulkar", isSelected: false) , Option(optionText: "Virat Kohli", isSelected: false), Option(optionText: "Adam Gilchirst", isSelected: false), Option(optionText: "Jacques Kallis", isSelected: false)], isMultiSelect: false), QuestionDetails(question: "What are the colors in the Indian national flag?", options: [Option(optionText: "White", isSelected: false), Option(optionText: "Yellow", isSelected: false), Option(optionText: "Orange", isSelected: false), Option(optionText: "Green", isSelected: false)], isMultiSelect: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // check if previously any history present and show the history button in that case.
        loadHistory()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        history.isHidden = historyList?.count ?? 0 <= 0
        // Resetting the controller (name and answers for the questions) once the user comes back here.
        name.text = ""
        name.resignFirstResponder()
        questions = questions.map { (question) -> QuestionDetails in
            question.answerOptions = question.answerOptions?.map({ (option) -> Option in option.isSelectedOption = false
                return option })
            return question
        }
    }
    
    func loadHistory() {
        historyList = History.getHistoryList()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        navigationController?.pushViewController(QuestionViewController.controller(name: name.text ?? "", questions: questions, currentQuestionIndex: 0, previousHistory: historyList), animated: true)
    }
    
    @IBAction func HistoryClicked(_ sender: Any) {
        navigationController?.pushViewController(SummaryHistoryTableViewController.controller(name: "", questions: nil, isSummaryPage: false, previousHistory: historyList), animated: true)
    }
}
