//
//  ResultViewController.swift
//  WanderGenie_Test
//
//  Created by Ahnaf Rahat on 22/5/25.
//

import UIKit

class ResultViewController: UIViewController {

    var preference: TravelPreference?
    var results: [String] = []

    @IBOutlet weak var titleLabelWithDestination: UILabel!
    @IBOutlet weak var descriptionLabelWithDate: UILabel!
    @IBOutlet weak var descriptionWithBudget: UILabel!
    @IBOutlet weak var resultTableView: UITableView!

    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSpinner()

        let nib = UINib(nibName: "ResultTableViewCell", bundle: nil)
        resultTableView.register(nib, forCellReuseIdentifier: "ResultTableViewCell")
        resultTableView.dataSource = self
        resultTableView.delegate = self

        generateAndSendPrompt()
    }

    private func setupUI() {
        guard let preference = preference else { return }

        titleLabelWithDestination.text = "Your \(preference.destination) Itinerary"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let startDateStr = formatter.string(from: preference.startDate)
        let endDateStr = formatter.string(from: preference.endDate)

        let days = Calendar.current.dateComponents([.day], from: preference.startDate, to: preference.endDate).day ?? 0
        let totalDays = days + 1

        let budgetFormatted = String(format: "$%.2f", preference.dailyBudget)

        descriptionLabelWithDate.text = "\(startDateStr) - \(endDateStr) • \(totalDays) days"
        descriptionWithBudget.text = "\(preference.numberOfTravelers) traveler\(preference.numberOfTravelers > 1 ? "s" : "") • \(budgetFormatted) daily budget"
    }

    private func setupSpinner() {
        spinner.center = view.center
        spinner.color = UIColor.darkGray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
    }

    private func generateAndSendPrompt() {
        guard let preference = preference else { return }

        let destination = preference.destination
        let numberOfTravelers = preference.numberOfTravelers
        let dailyBudget = preference.dailyBudget

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let start = formatter.string(from: preference.startDate)
        let end = formatter.string(from: preference.endDate)

        let activities = preference.preferredActivities
        let activityList = activities.isEmpty ? "no specific activities" : activities.joined(separator: ", ")

        let prompt = """
        Create a personalized travel itinerary for a trip to \(destination). The trip starts on \(start) and ends on \(end), with a total of \(numberOfTravelers) traveler\(numberOfTravelers > 1 ? "s" : ""). The daily budget is $\(dailyBudget) USD. The user is interested in the following activities: \(activityList).
        
        Additional preferences:
        - Accommodation: \(preference.accommodationPreference)
        - Transportation: \(preference.transportationPreference)
        - Special Needs: \(preference.specialNeeds)
        
        Please provide a day-by-day itinerary in a friendly and organized format, taking into account all preferences and requirements.
        """

        callOpenAIGPTMini(with: prompt)
    }

    private func callOpenAIGPTMini(with prompt: String) {
        spinner.startAnimating()

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer @@ Enter Your Open AI API Key Here", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo-0125", 
            "temperature": 0.5,
            "messages": [
                ["role": "system", "content": "You are an Itinerary Assistant. Provide a day-by-day travel guide."],
                ["role": "user", "content": prompt]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }

            if let error = error {
                print("Request failed: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned.")
                return
            }

            do {
                if let response = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = response["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {

                    let dayResults = content
                        .components(separatedBy: "\n")
                        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

                    DispatchQueue.main.async {
                        self.results = dayResults
                        self.resultTableView.reloadData()
                    }
                } else {
                    print("Unexpected API response.")
                    print(String(data: data, encoding: .utf8) ?? "")
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    @IBAction func onBackButtonTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDownloadPdfButtonTap(_ sender: Any) {
        guard let preference = preference else { return }

        Helper.shared.generatePDF(preference: preference, results: results) { fileURL in
            guard let fileURL = fileURL else { return }

            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    
}


extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as? ResultTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = results[indexPath.row]
        return cell
    }
}


