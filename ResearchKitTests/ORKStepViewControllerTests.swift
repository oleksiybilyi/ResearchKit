/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
import ResearchKit

class ORKStepViewControllerTests: XCTestCase {
    
    var testController: ORKStepViewController!
    var step: ORKStep!
    var result: ORKResult!
    var negativeTest: Bool!
    var forwardExpectation: XCTestExpectation!
    var reverseExpectation: XCTestExpectation!
    var testExpectation: XCTestExpectation!
    var appearExpectation: XCTestExpectation!
    var failExpectation: XCTestExpectation!
    var recorderExpectation: XCTestExpectation!
    
    override func setUp() {
        step = ORKStep(identifier: "STEP")
        result = ORKResult(identifier: "RESULT")
        testController = ORKStepViewController(step: step, result: result)
        testController.delegate = self
        negativeTest = false
    }
    
    func testAttributes() {
        let backButton = UIBarButtonItem(title: "BACK", style: .plain, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: nil, action: nil)
        let countinueString = "COUNTINUE"
        let learnMoreString = "LEARN MORE"
        let skipString = "SKIP"
        
        testController.continueButtonTitle = countinueString
        testController.learnMoreButtonTitle = learnMoreString
        testController.skipButtonTitle = skipString
        testController.backButtonItem = backButton
        testController.cancelButtonItem = cancelButton
        
        //        XCTAssertEqual(testController.learnMoreButtonTitle, learnMoreString)
        XCTAssertEqual(testController.continueButtonTitle, countinueString)
        XCTAssertEqual(testController.skipButtonTitle, skipString)
        XCTAssertEqual(testController.backButtonItem, backButton)
        XCTAssertEqual(testController.cancelButtonItem, cancelButton)
    }
    
    func testiPhoneViewDidLoad() {
        var step = ORKStep(identifier: "STEP")
        let title = "TEST"
        
        step.title = title
        testController = ORKStepViewController(step: step)
        testController.viewDidLoad()
        XCTAssertEqual(testController.title, title)
        
        step = ORKStep(identifier: "STEP")
        testController = ORKStepViewController(step: step)
        testController.viewDidLoad()
        XCTAssertEqual(testController.title, "")
    }
    
    func testViewWillAppear() {
        
        XCTAssertEqual(testController.continueButtonItem, testController.internalDoneButtonItem)
        XCTAssertEqual(testController.backButtonItem, nil)
        
        appearExpectation = expectation(description: "ORKStepViewController notifies delegate its status(Will Appear)")
        testController.viewWillAppear(false)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        XCTAssertEqual(testController.continueButtonItem, testController.internalContinueButtonItem)
        XCTAssertEqual(testController.backButtonItem, testController.internalBackButtonItem)
        
//        Test currently fails since navigationBar is not initialized
//        guard let navigationBar = testController.taskViewController?.navigationBar else {
//            XCTFail()
//            return
//        }
//
//        XCTAssertEqual(navigationBar.backgroundColor, ORKColor(ORKBackgroundColorKey))
        
        XCTAssertEqual(testController.hasBeenPresented, true)
        XCTAssert(testController.presentedDate != nil)
        XCTAssertNil(testController.dismissedDate)
        
//        Swift cant catch Exceptions only errors
//        let otherStep = ORKStep(identifier: "HEY")
//        XCTAssertThrowsError(testController.step = otherStep)
//        let exceptionController = ORKStepViewController(step: nil)
//        XCTAssertThrowsError(exceptionController.viewWillAppear(false))
    }
    
    func testShowValidityAlertWithTitle() {
        testController.loadView()
        appearExpectation = expectation(description: "ORKStepViewController notifies delegate its status(Will Appear)")
        
        UIApplication.shared.keyWindow?.rootViewController = testController
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        testController.showValidityAlert(withMessage: "TEST")
        testController.
    }
    
    func testiPadSetUp() {
        testController.shouldIgnoreiPadDesign = false
        let iPadScreenSize = CGRect(x: 0, y: 0, width: 768, height: 1024)
        
        UIApplication.shared.windows.first?.bounds = iPadScreenSize
        testController.viewDidLoad()
        
        //        Can't verify this since navigation bar has not been initialized
        //        XCTAssertFalse(navigationBar!.prefersLargeTitles)
        
        guard let iPadBackgroundView = testController.view!.subviews.first else{
            XCTFail()
            return
        }
        
        XCTAssertEqual(iPadBackgroundView.backgroundColor, ORKColor(ORKiPadBackgroundViewColorKey))
        XCTAssertEqual(iPadBackgroundView.layer.cornerRadius, ORKiPadBackgroundViewCornerRadius)
        
        guard let iPadContentView = iPadBackgroundView.subviews.first else{
            XCTFail()
            return
        }
        
        XCTAssertEqual(iPadContentView.backgroundColor, UIColor.clear)
        
        guard let iPadStepTitleLabel = iPadBackgroundView.subviews.last as? UILabel else {
            XCTFail()
            return
        }
        let iPadStepTitleLabelFontSize = CGFloat(50.0)
        
        XCTAssertEqual(iPadStepTitleLabel.numberOfLines, 0)
        XCTAssertEqual(iPadStepTitleLabel.textAlignment, NSTextAlignment.natural)
        XCTAssertEqual(iPadStepTitleLabel.font, UIFont.systemFont(ofSize: iPadStepTitleLabelFontSize, weight: UIFont.Weight.bold))
        XCTAssertEqual(iPadStepTitleLabel.adjustsFontSizeToFitWidth, true)
        XCTAssertEqual(iPadStepTitleLabel.text, testController.step?.title)
        
        
        let text = "TEST"
        testController.setiPadStepTitleLabelText(text)
        XCTAssertEqual(iPadStepTitleLabel.text, text)
        
        let backgroundColor = UIColor.red
        testController.setiPadBackgroundViewColor(backgroundColor)
        XCTAssertEqual(iPadBackgroundView.backgroundColor, backgroundColor)
    }
    
    func testNavigation() {
        negativeTest = false
        XCTAssertEqual(testController.hasPreviousStep(), true)
        XCTAssertEqual(testController.hasNextStep(), true)
        
        negativeTest = true
        XCTAssertEqual(testController.hasPreviousStep(), false)
        XCTAssertEqual(testController.hasNextStep(), false)
    }
    
    func testAddResult() {
        let resultOne = ORKResult(identifier: "RESULT ONE")
        testController.addResult(resultOne)
        
        XCTAssertEqual(testController.result?.results, [resultOne])
        
        // Verify result is added to the array not replaced
        let resultTwo = ORKResult(identifier: "RESULT TWO")
        testController.addResult(resultTwo)
        XCTAssertEqual(testController.result?.results, [resultOne, resultTwo])
    }
    
    func testGoForward() {
        forwardExpectation = expectation(description: "ORKStepViewController notifies delegate with Forward Direction")
        testController.goForward()
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGoBackward() {
        reverseExpectation = expectation(description: "ORKStepViewController notifies delegate with Reverse Direction")
        testController.goBackward()
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    func testResultDidChangeDelegate() {
        testExpectation = expectation(description: "ORKStepViewController notifies delegate that results changed")
        testController.notifyDelegateOnResultChange()
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    func testSkip() {
        forwardExpectation = expectation(description: "ORKStepViewController notifies delegate with Forward Direction")
        let skipButton = testController.skipButtonItem
        UIApplication.shared.sendAction(skipButton!.action!, to: skipButton!.target, from: self, for: nil)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testViewDelegates() {
        failExpectation = expectation(description: "ORKStepViewController notifies delegate it did fail")
        testController.delegate?.stepViewControllerDidFail(testController, withError: nil)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        recorderExpectation = expectation(description: "ORKStepViewController notifies delegate that it's recorder failed")
        let recorder = ORKRecorder(identifier: "RECORDER", step: nil, outputDirectory: nil)
        testController!.delegate!.stepViewController(testController, recorder: recorder, didFailWithError: TestError.scaryError)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
}

extension ORKStepViewControllerTests: ORKStepViewControllerDelegate {
    func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
        if(direction == .forward){
            forwardExpectation.fulfill()
        }else {
            reverseExpectation.fulfill()
        }
    }
    
    func stepViewControllerWillAppear(_ stepViewController: ORKStepViewController) {
        appearExpectation.fulfill()
    }
    
    func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {
        testExpectation.fulfill()
    }
    
    func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?) {
        failExpectation.fulfill()
    }
    
    func stepViewController(_ stepViewController: ORKStepViewController, recorder: ORKRecorder, didFailWithError error: Error) {
        recorderExpectation.fulfill()
    }
    
    func stepViewControllerHasNextStep(_ stepViewController: ORKStepViewController) -> Bool {
        if negativeTest{return false}
        return true
    }
    
    func stepViewControllerHasPreviousStep(_ stepViewController: ORKStepViewController) -> Bool {
        if negativeTest{return false}
        return true
    }
}

enum TestError: Error {
    case scaryError
}
