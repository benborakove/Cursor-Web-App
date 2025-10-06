import Foundation
import CoreData
import SwiftUI

// MARK: - Certification Model
@objc(Certification)
public class Certification: NSManagedObject {
    
}

extension Certification {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Certification> {
        return NSFetchRequest<Certification>(entityName: "Certification")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var issuingOrganization: String?
    @NSManaged public var issueDate: Date?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var certificationNumber: String?
    @NSManaged public var documentPath: String?
    @NSManaged public var renewalURL: String?
    @NSManaged public var pduURL: String?
    @NSManaged public var pduRequired: Int16
    @NSManaged public var pduEarned: Int16
    @NSManaged public var reminderDays: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

// MARK: - Reminder Model
@objc(Reminder)
public class Reminder: NSManagedObject {
    
}

extension Reminder {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var certificationId: UUID?
    @NSManaged public var daysBeforeExpiration: Int16
    @NSManaged public var isEnabled: Bool
    @NSManaged public var lastSent: Date?
    @NSManaged public var reminderType: String?
}

// MARK: - Certification Status
enum CertificationStatus {
    case active
    case expiringSoon(days: Int)
    case expired
    case expiringIn(days: Int)
    
    var color: Color {
        switch self {
        case .active:
            return .green
        case .expiringSoon:
            return .orange
        case .expired:
            return .red
        case .expiringIn:
            return .blue
        }
    }
    
    var text: String {
        switch self {
        case .active:
            return "Active"
        case .expiringSoon(let days):
            return "Expires in \(days) days"
        case .expired:
            return "Expired"
        case .expiringIn(let days):
            return "Expires in \(days) days"
        }
    }
}

// MARK: - Certification Extensions
extension Certification {
    var status: CertificationStatus {
        guard let expirationDate = expirationDate else { return .active }
        
        let calendar = Calendar.current
        let now = Date()
        let daysUntilExpiration = calendar.dateComponents([.day], from: now, to: expirationDate).day ?? 0
        
        if daysUntilExpiration < 0 {
            return .expired
        } else if daysUntilExpiration <= 30 {
            return .expiringSoon(days: daysUntilExpiration)
        } else {
            return .expiringIn(days: daysUntilExpiration)
        }
    }
    
    var daysUntilExpiration: Int {
        guard let expirationDate = expirationDate else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        return calendar.dateComponents([.day], from: now, to: expirationDate).day ?? 0
    }
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return Date() > expirationDate
    }
    
    var isExpiringSoon: Bool {
        return daysUntilExpiration <= 30 && daysUntilExpiration >= 0
    }
    
    var pduProgress: Double {
        guard pduRequired > 0 else { return 1.0 }
        return Double(pduEarned) / Double(pduRequired)
    }
    
    var reminderDaysArray: [Int] {
        guard let reminderDays = reminderDays else { return [30, 7, 1] }
        return reminderDays.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }
}

// MARK: - Certification Category
enum CertificationCategory: String, CaseIterable {
    case projectManagement = "Project Management"
    case informationTechnology = "Information Technology"
    case cybersecurity = "Cybersecurity"
    case cloudComputing = "Cloud Computing"
    case dataScience = "Data Science"
    case agile = "Agile"
    case qualityAssurance = "Quality Assurance"
    case businessAnalysis = "Business Analysis"
    case networking = "Networking"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .projectManagement:
            return "chart.bar.doc.horizontal"
        case .informationTechnology:
            return "laptopcomputer"
        case .cybersecurity:
            return "shield.checkered"
        case .cloudComputing:
            return "cloud"
        case .dataScience:
            return "chart.line.uptrend.xyaxis"
        case .agile:
            return "arrow.triangle.2.circlepath"
        case .qualityAssurance:
            return "checkmark.seal"
        case .businessAnalysis:
            return "doc.text.magnifyingglass"
        case .networking:
            return "network"
        case .other:
            return "star"
        }
    }
}