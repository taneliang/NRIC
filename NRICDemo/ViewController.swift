//
//  ViewController.swift
//  NRICDemo
//
//  Created by E-Liang Tan on 6/26/16.
//  Copyright (c) 2016 E-Liang Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    var nric: NRIC?
    
    @IBOutlet weak var prefixSelector: NSPopUpButton!
    @IBOutlet weak var numberField: NSTextField!
    @IBOutlet weak var checkDigitLabel: NSTextField!
    @IBOutlet weak var copyButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recalculateCheckDigit()
    }

    @IBAction func prefixDidChange(_ sender: AnyObject) {
        recalculateCheckDigit()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        recalculateCheckDigit()
    }
    
    func recalculateCheckDigit() {
        let digits = numberField.stringValue.characters.flatMap { Int(String($0)) }
        if let prefixChar = prefixSelector.title.characters.first,
            let prefix = NRIC.Prefix(rawValue: prefixChar),
            let nric = try? NRIC(prefix: prefix, digits: digits) {
            
            checkDigitLabel.stringValue = String(nric.checkDigit)
            self.nric = nric
            copyButton.isEnabled = true
            copyButton.title = "Copy " + String(describing: nric)
        } else {
            checkDigitLabel.stringValue = ""
            nric = nil
            copyButton.isEnabled = false
            copyButton.title = "Copy"
        }
    }
    
    @IBAction func copyNRIC(_ sender: AnyObject) {
        if let nric = nric {
            print("hohoho")
            let pasteboard = NSPasteboard.general()
            pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
            pasteboard.setString(String(describing: nric), forType: NSPasteboardTypeString)
        }
    }
}

