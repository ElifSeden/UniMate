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
    }

    static func createStyledPDF(
        name: String,
        position: String,
        email: String,
        phone: String,
        linkedin: String,
        github: String,
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
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 40
        let columnGap: CGFloat = 20
        let columnWidth = (pageWidth - 2 * margin - columnGap) / 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yOffset: CGFloat = margin

            // Profil Fotoğrafı
            if let image = profileImage {
                let imgRect = CGRect(x: margin, y: yOffset, width: 80, height: 80)
                context.cgContext.saveGState()
                let path = UIBezierPath(ovalIn: imgRect)
                path.addClip()
                image.draw(in: imgRect)
                context.cgContext.restoreGState()
            }

            // İsim ve Pozisyon
            let nameX = margin + 100
            name.draw(at: CGPoint(x: nameX, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
            yOffset += 26
            position.draw(at: CGPoint(x: nameX, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.darkGray])
            yOffset += 24

            // Özet
            let summaryRect = CGRect(x: nameX, y: yOffset, width: pageWidth - nameX - margin, height: 60)
            summary.draw(in: summaryRect, withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
            yOffset += 70

            // İletişim Bilgileri
            let iconFont = UIFont.systemFont(ofSize: 12)
            let infoX = margin
            let contactGap: CGFloat = 20
            "📧 \(email)".draw(at: CGPoint(x: infoX, y: yOffset), withAttributes: [.font: iconFont])
            yOffset += contactGap
            "🔗 \(linkedin)".draw(at: CGPoint(x: infoX, y: yOffset), withAttributes: [.font: iconFont])
            yOffset += contactGap
            "💻 \(github)".draw(at: CGPoint(x: infoX, y: yOffset), withAttributes: [.font: iconFont])
            yOffset += contactGap + 10

            // Divider
            context.cgContext.setStrokeColor(theme.primaryColor.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: margin, y: yOffset))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            context.cgContext.strokePath()
            yOffset += 20

            // Work Experience
            "Work Experience".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            yOffset += 20

            for exp in experiences {
                let dateText = "\(formatDate(exp.startDate)) - \(formatDate(exp.endDate))"
                dateText.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.gray])

                let titleX = margin + 130
                exp.position.draw(at: CGPoint(x: titleX, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 13)])
                yOffset += 16
                exp.company.draw(at: CGPoint(x: titleX, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                yOffset += 16

                let lines = exp.description.components(separatedBy: "\n")
                for line in lines {
                    ("\u{2022} \(line)").draw(in: CGRect(x: titleX, y: yOffset, width: pageWidth - titleX - margin, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 11)])
                    yOffset += 16
                }
                yOffset += 10
            }

            // Divider
            context.cgContext.setStrokeColor(theme.primaryColor.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: margin, y: yOffset))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            context.cgContext.strokePath()
            yOffset += 20

            // Education
            "Education".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            yOffset += 20

            for edu in educations {
                edu.school.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 13)])
                yOffset += 16
                edu.degree.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                yOffset += 16
                let dateText = "\(formatDate(edu.startDate)) - \(formatDate(edu.endDate))"
                dateText.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.gray])
                yOffset += 24
            }

            // Divider
            context.cgContext.setStrokeColor(theme.primaryColor.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: margin, y: yOffset))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            context.cgContext.strokePath()
            yOffset += 20

            // Skills
            "Skills".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            yOffset += 18
            for skill in skills {
                ("\u{2022} \(skill)").draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                yOffset += 16
            }

            yOffset += 20
            "Languages".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            yOffset += 18
            for lang in languages {
                ("\u{2022} \(lang)").draw(at: CGPoint(x: margin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                yOffset += 16
            }
        }

        return data
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
