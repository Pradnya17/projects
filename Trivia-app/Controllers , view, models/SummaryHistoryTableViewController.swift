//
//  SummaryHistoryTableViewController.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import UIKit

class SummaryHistoryTableViewController: UITableViewController {
    
    var name: String = ""
    var questions: [QuestionDetails]?
    var isSummaryPage: Bool = true
    var previousHistory: [HistoryElement]?
    
    //MARK: Properties
    
    class func controller(name: String?, questions: [QuestionDetails]?, isSummaryPage: Bool, previousHistory: [HistoryElement]?) -> SummaryHistoryTableViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SummaryHistoryVC") as! SummaryHistoryTableViewController
        controller.name = name ?? ""
        controller.questions = questions
        controller.isSummaryPage = isSummaryPage
        controller.previousHistory = previousHistory
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSummaryPage ? 1 : previousHistory?.count ?? 0 + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSummaryPage ? (questions?.count ?? 0) + 2 : (previousHistory?[section].questions?.count ?? 0) +  2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // the switch for each index depending of whether the controller is showing history or summary.
        switch indexPath.row {
        case 0: return
            isSummaryPage ?
                (tableView.dequeueReusableCell(withIdentifier: "headingCell", for: indexPath) as! HeadingCell).configure(heading: "Hello, \(name)")
                : (tableView.dequeueReusableCell(withIdentifier: "headingCell", for: indexPath) as! HeadingCell).configure(heading: "Game \(indexPath.section + 1): \(previousHistory?[indexPath.row * indexPath.section].dateTime ?? "")")
        case 1: return
            isSummaryPage ? tableView.dequeueReusableCell(withIdentifier: "subHeadingCell", for: indexPath)
                :  (tableView.dequeueReusableCell(withIdentifier: "subHeadingCell", for: indexPath) as! SubHeadingCell).configure(subHeading: "\(previousHistory?[indexPath.row * indexPath.section].name ?? "")")
        default:
            let details = isSummaryPage ? questions?[indexPath.row - 2] : previousHistory?[indexPath.section].questions?[indexPath.row - 2]
            let answers = details?.answerOptions?.map({ (aOption) -> String? in
                return (((aOption.isSelectedOption ?? false) ? aOption.optionText : nil) ?? nil) }).compactMap{$0}.joined(separator: ", ")
            return (tableView.dequeueReusableCell(withIdentifier: "QAndACell", for: indexPath) as! QAndACell).configure(questionText: "\(indexPath.row - 1). \(details?.questionText ?? "")", answerText: answers)
        }
    }
    
    @IBAction func finishClicked(_ sender: UIButton) {
        if isSummaryPage { saveToHistory() }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func saveToHistory() {
        // formatting date before saving the history.
        let dateTime = Date().localDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM HH:mm a"
        let dateTimeString = dateFormatter.string(from: dateTime)
        let historyElement = HistoryElement(name: name, dateTime: dateTimeString, questions: questions)
        if previousHistory != nil { previousHistory?.append(historyElement) } else {
            previousHistory = []
            previousHistory?.append(historyElement)
        }
        History.saveHistories(data: previousHistory)
    }
}

// to show the local date.
extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
}
