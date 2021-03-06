//
//  DaySelectionView.swift
//  Remindew
//
//  Created by Jorge Alvarez on 11/24/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import AVFoundation

class DaySelectionView: UIStackView {

    // MARK: - Properties
    
    var buttonArray = [UIButton]()
    let selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 20.0)
    let unselectedFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)

    // MARK: - View Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    @objc private func selectDay(_ button: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // NOT Selected, so select it
        if button.tintColor == .secondaryLabel {
            button.tintColor = UIColor.customSelectedDayColor//.darkGray
            button.titleLabel?.font = selectedFont
        }
        // IS Selected, so unselect
        else {
            button.tintColor = .secondaryLabel
            button.titleLabel?.font = unselectedFont
        }
    }
    
    private func setupSubviews() {
        
        distribution = .fillEqually
        self.spacing = 4
        for integer in 0..<String.dayInitials.count {
            let day = UIButton(type: .system)
            day.translatesAutoresizingMaskIntoConstraints = false
            addArrangedSubview(day)
            buttonArray.append(day)
            day.tag = integer + 1
            day.contentMode = .scaleToFill
            day.setTitle("\(String.dayInitials[integer])", for: .normal)
            day.backgroundColor = .clear
            
            day.tintColor = .secondaryLabel
            
            day.addTarget(self, action: #selector(selectDay), for: .touchUpInside)
            
            day.layer.cornerRadius = 13.0
        }
    }
    
    /// Sets buttons to be selected if they are in the plants days  (should NOT select buttons that are already selected)
    func selectDays(_ daysToSelect: [Int16]) {
        
        for day in daysToSelect {
            let index = Int(day) - 1
            // NOT Selected, so select it
            if buttonArray[index].tintColor == .secondaryLabel {
                buttonArray[index].tintColor = UIColor.customSelectedDayColor//.darkGray
                buttonArray[index].titleLabel?.font = selectedFont
            }
        }
    }
 
    /// Resets all days so they're unselected
    private func resetDays() {
        for button in buttonArray {
            button.tintColor = .secondaryLabel
            button.titleLabel?.font = unselectedFont
        }
    }
    
    /// Return an array of Int16s that are currently selected (Sunday = 1, etc)
    func returnDaysSelected() -> [Int16] {
        
        var result = [Int16]()
        
        for button in buttonArray {
            // if "selected"
            if button.tintColor == UIColor.customSelectedDayColor {
                result.append(Int16(button.tag))
            }
        }
        return result
    }
}
