//
//  ViewController.swift
//  HWS Project 5
//
//  Created by Walker Lockard on 3/10/23.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [AcceptedAnswer]()
    var currentWord: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(promptForAnswer)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(startGame)
        )
        
        let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt")!
        let startWords = try! String(contentsOf: startWordsUrl)
        
        self.allWords = startWords.components(separatedBy: "\n")
        
        startGame()
    }

    @objc func startGame() {
        self.currentWord = self.allWords.randomElement()!
        self.title = self.currentWord
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func updateScore() {
        self.title = "\(self.currentWord) (\(self.usedWords.reduce(0, { $0 + $1.score })))"
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if !isNotPromptedWord(word: lowerAnswer) {
            self.showInvalidAnswerAlert(
                title: "Not Allowed",
                message: "The prompted word is not a valid answer."
            )
            return
        }
        
        if !isLongEnough(word: lowerAnswer) {
            self.showInvalidAnswerAlert(
                title: "Too Short",
                message: "Your answer, \"\(lowerAnswer)\", needs to be 3 or more characters long."
            )
            return
        }
        
        if !isPossible(word: lowerAnswer) {
            self.showInvalidAnswerAlert(
                title: "Not Possible",
                message: "Your answer, \"\(lowerAnswer)\", isn't possible with the given prompt."
            )
            return
        }
        
        if !isOriginal(word: lowerAnswer) {
            self.showInvalidAnswerAlert(
                title: "Answer Already Exists",
                message: "Your answer, \"\(lowerAnswer)\", has already been submitted!"
            )
            return
        }
        
        if !isReal(word: lowerAnswer) {
            self.showInvalidAnswerAlert(
                title: "Not a Word",
                message: "Your answer, \"\(lowerAnswer)\", isn't an English word."
            )
            return
        }

        usedWords.insert(AcceptedAnswer(word: lowerAnswer), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        self.updateScore()
    }
    
    func isPossible(word: String) -> Bool {
        var tmpCurrentWord = self.currentWord
        for letter in  word {
            guard let idx = tmpCurrentWord.firstIndex(of: letter) else {
                return false
            }
            
            tmpCurrentWord.remove(at: idx)
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        if word == self.currentWord { return false }
        if self.usedWords.contains(where: { $0.word == word }) { return false }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isNotPromptedWord(word: String) -> Bool {
        return self.currentWord != word
    }
    
    func showInvalidAnswerAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "Try Again", style: .default, handler: promptForAnswer)
        )
        alertController.addAction(
            UIAlertAction(title: "Ok", style: .default)
        )
        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        let answer = usedWords[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = answer.word
        content.secondaryText = String(answer.score)
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    @objc func promptForAnswer(_: UIAlertAction! = nil) {
        let alertController = UIAlertController(
            title: "Enter Answer",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField()
        
        let submitAction = UIAlertAction(
            title: "Submit",
            style: .default
        ) { [weak self, weak alertController] action in
            guard let answer = alertController?.textFields?[0].text else { return }
            self?.submit(answer)
            
        }
        
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
}

