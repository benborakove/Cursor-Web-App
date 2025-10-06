import Foundation
import CoreData

class CertificationDatabase: ObservableObject {
    static let shared = CertificationDatabase()
    
    private init() {}
    
    // MARK: - Common Certifications Database
    let commonCertifications: [CertificationTemplate] = [
        // Project Management
        CertificationTemplate(
            name: "PMP (Project Management Professional)",
            issuingOrganization: "PMI",
            category: .projectManagement,
            renewalURL: "https://www.pmi.org/certifications/project-management-pmp",
            pduURL: "https://www.pmi.org/learning/pdus",
            pduRequired: 60,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "CAPM (Certified Associate in Project Management)",
            issuingOrganization: "PMI",
            category: .projectManagement,
            renewalURL: "https://www.pmi.org/certifications/project-management-capm",
            pduURL: "https://www.pmi.org/learning/pdus",
            pduRequired: 15,
            typicalValidityYears: 5
        ),
        CertificationTemplate(
            name: "PRINCE2 Foundation",
            issuingOrganization: "AXELOS",
            category: .projectManagement,
            renewalURL: "https://www.axelos.com/certifications/prince2",
            pduURL: "https://www.axelos.com/qualifications/prince2",
            pduRequired: 0,
            typicalValidityYears: 0
        ),
        
        // Information Technology
        CertificationTemplate(
            name: "ITIL 4 Foundation",
            issuingOrganization: "AXELOS",
            category: .informationTechnology,
            renewalURL: "https://www.axelos.com/certifications/itil",
            pduURL: "https://www.axelos.com/qualifications/itil",
            pduRequired: 0,
            typicalValidityYears: 0
        ),
        CertificationTemplate(
            name: "CompTIA A+",
            issuingOrganization: "CompTIA",
            category: .informationTechnology,
            renewalURL: "https://www.comptia.org/certifications/a",
            pduURL: "https://www.comptia.org/continuing-education",
            pduRequired: 20,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "CompTIA Network+",
            issuingOrganization: "CompTIA",
            category: .informationTechnology,
            renewalURL: "https://www.comptia.org/certifications/network",
            pduURL: "https://www.comptia.org/continuing-education",
            pduRequired: 20,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "CompTIA Security+",
            issuingOrganization: "CompTIA",
            category: .informationTechnology,
            renewalURL: "https://www.comptia.org/certifications/security",
            pduURL: "https://www.comptia.org/continuing-education",
            pduRequired: 50,
            typicalValidityYears: 3
        ),
        
        // Cybersecurity
        CertificationTemplate(
            name: "CISSP (Certified Information Systems Security Professional)",
            issuingOrganization: "ISC2",
            category: .cybersecurity,
            renewalURL: "https://www.isc2.org/Certifications/CISSP",
            pduURL: "https://www.isc2.org/Continuing-Education",
            pduRequired: 40,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "CISM (Certified Information Security Manager)",
            issuingOrganization: "ISACA",
            category: .cybersecurity,
            renewalURL: "https://www.isaca.org/credentialing/cism",
            pduURL: "https://www.isaca.org/credentialing/cism/cism-cpe",
            pduRequired: 20,
            typicalValidityYears: 1
        ),
        CertificationTemplate(
            name: "CEH (Certified Ethical Hacker)",
            issuingOrganization: "EC-Council",
            category: .cybersecurity,
            renewalURL: "https://www.eccouncil.org/programs/certified-ethical-hacker-ceh/",
            pduURL: "https://www.eccouncil.org/programs/certified-ethical-hacker-ceh/",
            pduRequired: 20,
            typicalValidityYears: 3
        ),
        
        // Cloud Computing
        CertificationTemplate(
            name: "AWS Certified Solutions Architect",
            issuingOrganization: "Amazon Web Services",
            category: .cloudComputing,
            renewalURL: "https://aws.amazon.com/certification/certified-solutions-architect-associate/",
            pduURL: "https://aws.amazon.com/training/",
            pduRequired: 0,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "AWS Certified Developer",
            issuingOrganization: "Amazon Web Services",
            category: .cloudComputing,
            renewalURL: "https://aws.amazon.com/certification/certified-developer-associate/",
            pduURL: "https://aws.amazon.com/training/",
            pduRequired: 0,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "Microsoft Azure Fundamentals",
            issuingOrganization: "Microsoft",
            category: .cloudComputing,
            renewalURL: "https://docs.microsoft.com/en-us/learn/certifications/azure-fundamentals/",
            pduURL: "https://docs.microsoft.com/en-us/learn/",
            pduRequired: 0,
            typicalValidityYears: 0
        ),
        CertificationTemplate(
            name: "Google Cloud Professional Cloud Architect",
            issuingOrganization: "Google Cloud",
            category: .cloudComputing,
            renewalURL: "https://cloud.google.com/certification/cloud-architect",
            pduURL: "https://cloud.google.com/training",
            pduRequired: 0,
            typicalValidityYears: 2
        ),
        
        // Data Science
        CertificationTemplate(
            name: "Certified Analytics Professional (CAP)",
            issuingOrganization: "INFORMS",
            category: .dataScience,
            renewalURL: "https://www.informs.org/Certification-Continuing-Ed/Certification",
            pduURL: "https://www.informs.org/Certification-Continuing-Ed/Continuing-Education",
            pduRequired: 30,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "SAS Certified Specialist",
            issuingOrganization: "SAS",
            category: .dataScience,
            renewalURL: "https://www.sas.com/en_us/certification.html",
            pduURL: "https://www.sas.com/en_us/training.html",
            pduRequired: 0,
            typicalValidityYears: 3
        ),
        
        // Agile
        CertificationTemplate(
            name: "Certified ScrumMaster (CSM)",
            issuingOrganization: "Scrum Alliance",
            category: .agile,
            renewalURL: "https://www.scrumalliance.org/get-certified/csm",
            pduURL: "https://www.scrumalliance.org/get-certified/continuing-education",
            pduRequired: 20,
            typicalValidityYears: 2
        ),
        CertificationTemplate(
            name: "Professional Scrum Master (PSM)",
            issuingOrganization: "Scrum.org",
            category: .agile,
            renewalURL: "https://www.scrum.org/certifications/professional-scrum-master",
            pduURL: "https://www.scrum.org/learning",
            pduRequired: 0,
            typicalValidityYears: 0
        ),
        CertificationTemplate(
            name: "SAFe Agilist",
            issuingOrganization: "Scaled Agile",
            category: .agile,
            renewalURL: "https://www.scaledagile.com/certification/safe-agilist/",
            pduURL: "https://www.scaledagile.com/learning/",
            pduRequired: 0,
            typicalValidityYears: 1
        ),
        
        // Quality Assurance
        CertificationTemplate(
            name: "ISTQB Foundation Level",
            issuingOrganization: "ISTQB",
            category: .qualityAssurance,
            renewalURL: "https://www.istqb.org/certifications/foundation-level",
            pduURL: "https://www.istqb.org/continuing-education",
            pduRequired: 0,
            typicalValidityYears: 0
        ),
        CertificationTemplate(
            name: "CSTE (Certified Software Test Engineer)",
            issuingOrganization: "QAI",
            category: .qualityAssurance,
            renewalURL: "https://www.qaiglobalinstitute.org/certifications/cste",
            pduURL: "https://www.qaiglobalinstitute.org/continuing-education",
            pduRequired: 20,
            typicalValidityYears: 3
        ),
        
        // Business Analysis
        CertificationTemplate(
            name: "CBAP (Certified Business Analysis Professional)",
            issuingOrganization: "IIBA",
            category: .businessAnalysis,
            renewalURL: "https://www.iiba.org/certifications/core-business-analysis-certifications/cbap/",
            pduURL: "https://www.iiba.org/certifications/core-business-analysis-certifications/cbap/continuing-education/",
            pduRequired: 60,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "CCBA (Certification of Capability in Business Analysis)",
            issuingOrganization: "IIBA",
            category: .businessAnalysis,
            renewalURL: "https://www.iiba.org/certifications/core-business-analysis-certifications/ccba/",
            pduURL: "https://www.iiba.org/certifications/core-business-analysis-certifications/ccba/continuing-education/",
            pduRequired: 20,
            typicalValidityYears: 3
        ),
        
        // Networking
        CertificationTemplate(
            name: "CCNA (Cisco Certified Network Associate)",
            issuingOrganization: "Cisco",
            category: .networking,
            renewalURL: "https://www.cisco.com/c/en/us/training-events/training-certifications/certifications/associate/ccna.html",
            pduURL: "https://www.cisco.com/c/en/us/training-events/training-certifications/continuing-education.html",
            pduRequired: 0,
            typicalValidityYears: 3
        ),
        CertificationTemplate(
            name: "CCNP (Cisco Certified Network Professional)",
            issuingOrganization: "Cisco",
            category: .networking,
            renewalURL: "https://www.cisco.com/c/en/us/training-events/training-certifications/certifications/professional/ccnp.html",
            pduURL: "https://www.cisco.com/c/en/us/training-events/training-certifications/continuing-education.html",
            pduRequired: 0,
            typicalValidityYears: 3
        )
    ]
    
    // MARK: - Search and Filter
    func searchCertifications(query: String) -> [CertificationTemplate] {
        if query.isEmpty {
            return commonCertifications
        }
        
        return commonCertifications.filter { certification in
            certification.name.localizedCaseInsensitiveContains(query) ||
            certification.issuingOrganization.localizedCaseInsensitiveContains(query) ||
            certification.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterByCategory(_ category: CertificationCategory) -> [CertificationTemplate] {
        return commonCertifications.filter { $0.category == category }
    }
    
    func getCertificationsByCategory() -> [CertificationCategory: [CertificationTemplate]] {
        var categorized: [CertificationCategory: [CertificationTemplate]] = [:]
        
        for certification in commonCertifications {
            if categorized[certification.category] == nil {
                categorized[certification.category] = []
            }
            categorized[certification.category]?.append(certification)
        }
        
        return categorized
    }
}

// MARK: - Certification Template
struct CertificationTemplate {
    let name: String
    let issuingOrganization: String
    let category: CertificationCategory
    let renewalURL: String
    let pduURL: String
    let pduRequired: Int
    let typicalValidityYears: Int
    
    var reminderDays: [Int] {
        switch typicalValidityYears {
        case 0:
            return [30, 7, 1] // No renewal required, but still remind
        case 1:
            return [60, 30, 14, 7, 1]
        case 2:
            return [90, 60, 30, 14, 7, 1]
        case 3:
            return [120, 90, 60, 30, 14, 7, 1]
        default:
            return [90, 60, 30, 14, 7, 1]
        }
    }
}