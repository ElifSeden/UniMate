import Foundation
import PDFKit
import UIKit

struct PDFCreator {
    struct Theme {
        let primaryColor: UIColor
        let titleColor: UIColor
        static let green = Theme(primaryColor: UIColor.systemGreen, titleColor: UIColor.systemGreen)
        static let navy = Theme(primaryColor: UIColor.systemBlue, titleColor: UIColor.systemBlue)
        static let maroon = Theme(primaryColor: UIColor.systemRed, titleColor: UIColor.systemRed)
        static let black = Theme(primaryColor: UIColor.black, titleColor: UIColor.black)
        static let darkYellow = Theme(
            primaryColor: UIColor(red: 0.75, green: 0.6, blue: 0.0, alpha: 1.0),
            titleColor: UIColor(red: 0.75, green: 0.6, blue: 0.0, alpha: 1.0)
        )

    }

    static func createStyledPDF(
        name: String,
        position: String,
        email: String,
        phone: String,
        location: String,
        linkedin: String,
        github: String,
        website: String?,
        skills: [String],
        experiences: [ExperienceInfo],
        educations: [EducationInfo],
        profileImage: UIImage?,
        summary: String,
        languages: [String],
        theme: Theme = .green
    ) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextCreator: "Unimate",
            kCGPDFContextAuthor: name
        ] as [String: Any]

        let pageWidth: CGFloat = 595.2
        let margin: CGFloat = 40
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: 841.8), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yOffset: CGFloat = margin

            if let image = profileImage {
                let imgRect = CGRect(x: margin, y: yOffset, width: 80, height: 80)
                context.cgContext.saveGState()
                UIBezierPath(ovalIn: imgRect).addClip()
                image.draw(in: imgRect)
                context.cgContext.restoreGState()
            }

            let infoX = margin + 100

            name.uppercased().draw(at: CGPoint(x: infoX, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)])
            yOffset += 26
            position.uppercased().draw(at: CGPoint(x: infoX, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            yOffset += 26

            let infoFont = UIFont.systemFont(ofSize: 11)
            let infos = [
                "✉️  \(email)",
                "📞  \(phone)",
                "📍  \(location)",
                "💻  \(github)",
                "🔗  \(linkedin)"
            ] + (website != nil ? ["🌐  \(website!)"] : [])

            for info in infos {
                info.draw(at: CGPoint(x: infoX, y: yOffset), withAttributes: [.font: infoFont])
                yOffset += 16
            }

            yOffset += 10

            let summaryFont = UIFont.systemFont(ofSize: 12)
            let summaryAttributes: [NSAttributedString.Key: Any] = [.font: summaryFont]
            let summaryRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: .greatestFiniteMagnitude)

            let summaryHeight = summary.boundingRect(with: summaryRect.size, options: .usesLineFragmentOrigin, attributes: summaryAttributes, context: nil).height

            summary.draw(in: CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: summaryHeight), withAttributes: summaryAttributes)
            yOffset += summaryHeight + 10

            drawDivider(context: context, y: yOffset, theme: theme)
            yOffset += 20
            "Work Experience".draw(
                at: CGPoint(x: margin, y: yOffset),
                withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
            )
            yOffset += 28
            for (index, exp) in experiences.enumerated() {
                let dateText = "\(formatDate(exp.startDate)) - \(formatDate(exp.endDate))"
                dateText.draw(
                    at: CGPoint(x: margin, y: yOffset),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor.gray
                    ]
                )
                yOffset += 18

                let numberedPosition = "\(index + 1). \(exp.position)"
                numberedPosition.draw(
                    at: CGPoint(x: margin, y: yOffset),
                    withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
                )
                yOffset += 20

                exp.company.draw(
                    at: CGPoint(x: margin, y: yOffset),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 13)]
                )
                yOffset += 18

                let lines = exp.description.components(separatedBy: "\n")
                for line in lines {
                    let bulletLine = "• \(line)"
                    bulletLine.draw(
                        at: CGPoint(x: margin + 8, y: yOffset),
                        withAttributes: [.font: UIFont.systemFont(ofSize: 12)]
                    )
                    yOffset += 16
                }

                yOffset += 12
            }
            drawDivider(context: context, y: yOffset, theme: theme)
            yOffset += 20

            "Education".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            yOffset += 28

            for edu in educations {
                edu.school.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
                yOffset += 20
                edu.degree.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 13)])
                yOffset += 18
                let dateText = "\(formatDate(edu.startDate)) - \(formatDate(edu.endDate))"
                dateText.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray])
                yOffset += 32
            }

            drawDivider(context: context, y: yOffset, theme: theme)
            yOffset += 20

            let columnWidth = (pageWidth - 2 * margin - 20) / 2
            let leftX = margin
            let rightX = margin + columnWidth + 20
            let maxLines = max(skills.count, languages.count)

            "Skills".draw(at: CGPoint(x: leftX, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            "Languages".draw(at: CGPoint(x: rightX, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            yOffset += 20

            for i in 0..<maxLines {
                if i < skills.count {
                    let skill = "\u{2022} \(skills[i])"
                    skill.draw(at: CGPoint(x: leftX, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                }
                if i < languages.count {
                    let lang = "\u{2022} \(languages[i])"
                    lang.draw(at: CGPoint(x: rightX, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                }
                yOffset += 16
            }
        }

        return data
    }

    private static func drawDivider(context: UIGraphicsPDFRendererContext, y: CGFloat, theme: Theme) {
        context.cgContext.setStrokeColor(theme.primaryColor.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: 40, y: y))
        context.cgContext.addLine(to: CGPoint(x: 595.2 - 40, y: y))
        context.cgContext.strokePath()
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}
