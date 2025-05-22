//
//  Helper.swift
//  WanderGenie_Test
//
//  Created by Ahnaf Rahat on 22/5/25.
//

import UIKit
import PDFKit

class Helper {
    static let shared = Helper() 

    private init() {}

    func generatePDF(preference: TravelPreference, results: [String], completion: @escaping (URL?) -> Void) {
        let pdfMetaData = [
            kCGPDFContextCreator: "WanderGenie",
            kCGPDFContextAuthor: "WanderGenie App"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2
        let pageHeight = 841.8
        let margin: CGFloat = 20

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = margin

            // Add Title
            let title = "Your \(preference.destination) Itinerary"
            yPosition = drawText(title, at: yPosition, font: .boldSystemFont(ofSize: 22))

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateRange = "\(formatter.string(from: preference.startDate)) - \(formatter.string(from: preference.endDate))"
            let travelerInfo = "\(preference.numberOfTravelers) traveler\(preference.numberOfTravelers > 1 ? "s" : "") • \(preference.budget.capitalized) budget"
            yPosition = drawText(dateRange, at: yPosition + 10, font: .systemFont(ofSize: 16))
            yPosition = drawText(travelerInfo, at: yPosition + 5, font: .systemFont(ofSize: 16))
            yPosition += 20

            // Add each itinerary item
            for line in results {
                if yPosition > pageHeight - margin - 40 {
                    context.beginPage()
                    yPosition = margin
                }
                yPosition = drawText(line, at: yPosition + 5, font: .systemFont(ofSize: 14))
            }
        }

        // Save to temp file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Itinerary.pdf")
        do {
            try data.write(to: tempURL)
            completion(tempURL)
        } catch {
            print("PDF write failed: \(error)")
            completion(nil)
        }
    }

    private func drawText(_ text: String, at y: CGFloat, font: UIFont) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let width: CGFloat = 595.2 - 40 // page width - 2*margin
        let textRect = CGRect(x: 20, y: y, width: width, height: .greatestFiniteMagnitude)
        let boundingRect = text.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                             options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             attributes: attrs,
                                             context: nil)
        text.draw(in: textRect, withAttributes: attrs)
        return y + ceil(boundingRect.height)
    }
}

