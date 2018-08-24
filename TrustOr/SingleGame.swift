import UIKit

enum AnswerChoice {
    case trueAnswer
    case doubtAnswer
    case falseAnswer
}

class SingleGameState {
    enum AnswerState {
        case notAnswered
        case answered
        case finishGame
    }
    
    var currentNumber: Int
    var answerState: AnswerState
    var score: Int
    var lastAnswer: AnswerChoice
    var answerResultString: String
    init() {
        currentNumber = 0
        answerState = .notAnswered
        score = 0
        lastAnswer = .trueAnswer
        answerResultString = ""
    }
}

class SingleGame {
    var questionText: UITextView
    var commentText: UITextView
    var trueAnswerButton: UIButton
    var doubtAsnwerButton: UIButton
    var falseAsnwerButton: UIButton
    var nextQuestionButton: UIButton
    var finishGameButton: UIButton
    var resultLabel: UILabel
    
    var questionsPack : QuestionsPack!
    var state: SingleGameState!
    weak var delegate: GameDelegate?
    
    init(delegate: GameDelegate, questionsPack: QuestionsPack, state: SingleGameState, questionText: UITextView, commentText: UITextView, trueAnswerButton: UIButton, doubtAsnwerButton: UIButton, falseAsnwerButton: UIButton, nextQuestionButton: UIButton, finishGameButton: UIButton, resultLabel: UILabel) {
        self.delegate = delegate
        self.questionsPack = questionsPack
        self.state = state
        self.questionText = questionText
        self.commentText = commentText
        self.trueAnswerButton = trueAnswerButton
        self.doubtAsnwerButton = doubtAsnwerButton
        self.falseAsnwerButton = falseAsnwerButton
        self.nextQuestionButton = nextQuestionButton
        self.finishGameButton = finishGameButton
        self.resultLabel = resultLabel
        restoreState()
    }
    
    //MARK:- Game logic = Data change functions
    func answerIsTrue() {
        state.answerResultString = K.winResultString
        state.score += 1
    }
    func answerIsFalse() {
        state.answerResultString = K.looseResultString
        state.score -= 1
    }
    func answerIsDoubt() {
        state.answerResultString = K.doubtResultString
    }

    func answerButtonPressed(button: AnswerChoice) {
        state.answerState = .answered
        if button == .doubtAnswer {
            answerIsDoubt()
        } else if (questionsPack.questionTasks[state.currentNumber].answer == true) && (button == .trueAnswer) || (questionsPack.questionTasks[state.currentNumber].answer == false) && (button == .falseAnswer) {
            answerIsTrue()
        } else {
            answerIsFalse()
        }
        if state.currentNumber+1 < questionsPack.questionTasks.count {
            showUIWaitMode()
        } else {
            state.answerState = .finishGame
            showUIFinishGame()
        }
    }
    func nextQuestionButtonPressed() {
        state.currentNumber+=1
        showUIAnswerMode()
        state.answerState = .notAnswered
    }
    func finishGameButtonPressed() {
        delegate?.returnToStartView()
    }
    //MARK:- UI Change functions
    func restoreState() {
        switch state.answerState {
        case .answered: showUIWaitMode()
        case .finishGame: showUIFinishGame()
        case .notAnswered: showUIAnswerMode()
        }
        reloadTexts()
    }
    private func reloadTexts() {
        questionText.text = questionsPack.questionTasks[state.currentNumber].question
        commentText.text = questionsPack.questionTasks[state.currentNumber].comment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.questionText.flashScrollIndicators()
        })
        var score = String(state.score)
        if state.score > 0 { score = "+"+score }
        if state.score == 0 { score = " "+score }
        let title =
            "\(K.questionLabel)\(state.currentNumber+1)/\(questionsPack.questionTasks.count)\(K.scoreLabel)\(score)"
        delegate?.setTitle(title: title)
    }
    private func showAnswer() {
        commentText.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.commentText.flashScrollIndicators()
        })
        if questionsPack.questionTasks[state.currentNumber].answer == true {
            resultLabel.backgroundColor = K.trueAnswerColor
            switch state.answerResultString {
            case K.winResultString:
                resultLabel.text = K.trueTextWin
            case K.looseResultString:
                resultLabel.text = K.trueTextLoose
            default:
                resultLabel.text = K.trueTextLoose
            }
        } else {
            resultLabel.backgroundColor = K.falseAnswerColor
            switch state.answerResultString {
            case K.winResultString:
                resultLabel.text = K.falseTextWin
            case K.looseResultString:
                resultLabel.text = K.falseTextLoose
            default:
                resultLabel.text = K.falseTextLoose
            }
        }
        resultLabel.text = resultLabel.text! + state.answerResultString
        resultLabel.isHidden = false
        reloadTexts()
    }
    private func hideAnswer() {
        commentText.isHidden = true
        resultLabel.isHidden = true
    }
    private func showUIAnswerMode() {
        hideAnswer()
        nextQuestionButton.isHidden = true
            
        trueAnswerButton.setTitle(K.trustText, for: .normal)
        trueAnswerButton.backgroundColor = K.trueAnswerButtonColor
        trueAnswerButton.isHidden = false
        
        doubtAsnwerButton.setTitle(K.doubtText, for: .normal)
        doubtAsnwerButton.backgroundColor = K.doubtAnswerButtonColor
        doubtAsnwerButton.isHidden = false
        
        falseAsnwerButton.setTitle(K.notTrustText, for: .normal)
        falseAsnwerButton.backgroundColor = K.falseAnswerButtonColor
        falseAsnwerButton.isHidden = false
        
        reloadTexts()
    }
    private func showUIWaitMode() {
        showAnswer()
        trueAnswerButton.isHidden = true
        doubtAsnwerButton.isHidden = true
        falseAsnwerButton.isHidden = true

        nextQuestionButton.setTitle(K.nextQuestionButtonText, for: .normal)
        nextQuestionButton.backgroundColor = K.foregroundColor
        nextQuestionButton.isHidden = false
    }
    private func showUIFinishGame() {
        showAnswer()
        trueAnswerButton.isHidden = true
        doubtAsnwerButton.isHidden = true
        falseAsnwerButton.isHidden = true
        
        finishGameButton.setTitle(K.finishGameButtonText, for: .normal)
        finishGameButton.backgroundColor = K.foregroundColor
        finishGameButton.isHidden = false
    }
}