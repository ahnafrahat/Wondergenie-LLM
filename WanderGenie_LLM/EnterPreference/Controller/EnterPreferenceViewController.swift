//
//  EnterPreferenceViewController.swift
//  WanderGenie_Test
//
//  Created by Ahnaf Rahat on 22/5/25.
//

import UIKit

class EnterPreferenceViewController: UIViewController {

    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var numberOfTravellerTextField: UITextField!
    @IBOutlet weak var preferredActivityTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!

    private let datePicker = UIDatePicker()
    private var selectedDateField: UITextField?

    private let travelersOptions = Array(1...10)
    private let budgetOptions = ["Budget", "Standard", "Luxury"]
    private let activityOptions = ["Sightseeing", "Hiking", "Shopping", "Food Tour", "Beach", "Museum", "Nightlife"]
    private var selectedActivities = [String]()

    private var preference = TravelPreference(
        destination: "",
        startDate: Date(),
        endDate: Date(),
        numberOfTravelers: 1,
        preferredActivities: [],
        budget: ""
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePickers()
        configurePickerInputs()
    }

    private func configureDatePickers() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelDatePick))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDatePick))
        toolbar.setItems([cancelButton, flexible, doneButton], animated: false)

        startDateTextField.inputView = datePicker
        startDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputView = datePicker
        endDateTextField.inputAccessoryView = toolbar

        startDateTextField.delegate = self
        endDateTextField.delegate = self
    }

    @objc private func cancelDatePick() {
        selectedDateField?.resignFirstResponder()
    }

    @objc private func doneDatePick() {
        guard let field = selectedDateField else { return }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let date = datePicker.date
        field.text = formatter.string(from: date)

        if field == startDateTextField {
            preference.startDate = date
        } else if field == endDateTextField {
            preference.endDate = date
        }

        field.resignFirstResponder()
    }

    private func configurePickerInputs() {
        numberOfTravellerTextField.delegate = self
        budgetTextField.delegate = self
        preferredActivityTextField.delegate = self

        // Disable keyboard input
        numberOfTravellerTextField.inputView = UIView()
        budgetTextField.inputView = UIView()
        preferredActivityTextField.inputView = UIView()
    }

    @IBAction func onDenerateItinernary(_ sender: Any) {
        preference.destination = destinationTextField.text ?? ""

        let resultVC = storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        resultVC.preference = preference
        navigationController?.pushViewController(resultVC, animated: true)
    }

    private func showSinglePicker(for field: UITextField, options: [String], selectionHandler: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .actionSheet)
        options.forEach { option in
            alert.addAction(UIAlertAction(title: option, style: .default) { _ in
                selectionHandler(option)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showActivityMultiSelect() {
        let alert = UIAlertController(title: "Select Activities", message: nil, preferredStyle: .alert)

        activityOptions.forEach { activity in
            let isSelected = selectedActivities.contains(activity)
            alert.addAction(UIAlertAction(
                title: activity,
                style: isSelected ? .destructive : .default,
                handler: { _ in
                    if let index = self.selectedActivities.firstIndex(of: activity) {
                        self.selectedActivities.remove(at: index)
                    } else {
                        self.selectedActivities.append(activity)
                    }
                    self.preferredActivityTextField.text = self.selectedActivities.joined(separator: ", ")
                    self.preference.preferredActivities = self.selectedActivities
                    self.showActivityMultiSelect() // Reopen for multi toggle
                }))
        }

        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        present(alert, animated: true)
    }
}

extension EnterPreferenceViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case startDateTextField, endDateTextField:
            selectedDateField = textField
            if textField.text?.isEmpty ?? true {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                textField.text = formatter.string(from: datePicker.date)
                if textField == startDateTextField {
                    preference.startDate = datePicker.date
                } else {
                    preference.endDate = datePicker.date
                }
            }
        case numberOfTravellerTextField:
            showSinglePicker(for: textField, options: travelersOptions.map { "\($0)" }) { selected in
                textField.text = selected
                self.preference.numberOfTravelers = Int(selected) ?? 1
            }
        case budgetTextField:
            showSinglePicker(for: textField, options: budgetOptions) { selected in
                textField.text = selected
                self.preference.budget = selected
            }
        case preferredActivityTextField:
            showActivityMultiSelect()
            textField.resignFirstResponder()
        default:
            break
        }
    }
}
