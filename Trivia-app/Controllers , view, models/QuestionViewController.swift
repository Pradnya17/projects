//
//  QuestionViewController.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 20/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import UIKit

protocol OptionSelectionDelegate: class {
    func optionSelected(option: Option?)
}

class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, OptionSelectionDelegate {
    
    var name: String?
    var questions: [QuestionDetails]?
    var currentQuestionIndex: Int?
    var previousHistory: [HistoryElement]?
    
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var optionsTable: UITableView!
    
    // method for initializing the controller and passing variables if any from  previous controller to present one.
    class func controller(name: String?, questions: [QuestionDetails]?, currentQuestionIndex: Int?, previousHistory: [HistoryElement]?) -> QuestionViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionVC") as! QuestionViewController
        controller.name = name
        controller.questions = questions
        controller.currentQuestionIndex = currentQuestionIndex
        controller.previousHistory = previousHistory
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // assining value of question
        questionText.text = questions?[currentQuestionIndex ?? 0].questionText
    }
    
    // MARK:- TableView datasource, delegate methods
    
    // table is used for the options with an idea of keeping it dynamic for future.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions?[currentQuestionIndex ?? 0].answerOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let questionDetail = questions?[currentQuestionIndex ?? 0]
        return (tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsTableViewCell).configure(option: questionDetail?.answerOptions?[indexPath.row], isMultiSelect: questionDetail?.isMultiSelect, delegate: self)
    }
    
    // MARK:- Option Selection delegate method
    func optionSelected(option: Option?) {
        questions?[currentQuestionIndex ?? 0].answerOptions = questions?[currentQuestionIndex ?? 0].answerOptions?.map({ (aOption) -> Option in
            if questions?[currentQuestionIndex ?? 0].isMultiSelect ?? false {
                return ((aOption.optionText == option?.optionText ? option : aOption) ?? aOption)
            } else {
                aOption.isSelectedOption = aOption.optionText == option?.optionText ? true : false
                return aOption
            }
        })
        optionsTable.reloadData()
    }
    
    // MARK: IBActions
    /// navigating to next controller, if questions are still not over then instantiiationg another question controller or else directing user to summary.
    @IBAction func goToNext(_ sender: UIButton) {
        let nextQuestionIndex = (currentQuestionIndex ?? 0) + 1
        if nextQuestionIndex < questions?.count ?? 0 {
            navigationController?.pushViewController(QuestionViewController.controller(name: name, questions: questions, currentQuestionIndex: nextQuestionIndex, previousHistory: previousHistory), animated: true)
        } else {
            navigationController?.pushViewController(SummaryHistoryTableViewController.controller(name: name, questions: questions, isSummaryPage: true, previousHistory: previousHistory), animated: true)
        }
    }
}
