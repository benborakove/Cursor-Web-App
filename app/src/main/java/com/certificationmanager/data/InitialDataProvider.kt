package com.certificationmanager.data

import com.certificationmanager.data.entity.CertificationTemplate
import com.certificationmanager.data.repository.CertificationTemplateRepository
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class InitialDataProvider @Inject constructor(
    private val templateRepository: CertificationTemplateRepository
) {
    
    suspend fun insertInitialData() {
        val templates = listOf(
            // IT Certifications
            CertificationTemplate(
                id = "pmp",
                name = "Project Management Professional (PMP)",
                issuingOrganization = "Project Management Institute (PMI)",
                category = "Project Management",
                validityPeriodYears = 3,
                renewalUrl = "https://www.pmi.org/certifications/maintain/renewal",
                pduUrl = "https://www.pmi.org/learning/education/professional-development-units",
                description = "The most important industry-recognized project management certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "cissp",
                name = "Certified Information Systems Security Professional (CISSP)",
                issuingOrganization = "International Information System Security Certification Consortium (ISC)²",
                category = "Security",
                validityPeriodYears = 3,
                renewalUrl = "https://www.isc2.org/Certifications/CISSP/Continuing-Professional-Education",
                pduUrl = "https://www.isc2.org/Certifications/CISSP/Continuing-Professional-Education",
                description = "Advanced-level information security certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "aws-saa",
                name = "AWS Solutions Architect Associate",
                issuingOrganization = "Amazon Web Services",
                category = "Cloud",
                validityPeriodYears = 3,
                renewalUrl = "https://aws.amazon.com/certification/recertification/",
                pduUrl = "https://aws.amazon.com/training/",
                description = "Cloud architecture and AWS services certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "comptia-a",
                name = "CompTIA A+",
                issuingOrganization = "CompTIA",
                category = "IT",
                validityPeriodYears = 3,
                renewalUrl = "https://www.comptia.org/certifications/a",
                pduUrl = "https://www.comptia.org/continuing-education",
                description = "Entry-level IT certification for technical support and IT operational roles",
                isPopular = true
            ),
            CertificationTemplate(
                id = "comptia-network",
                name = "CompTIA Network+",
                issuingOrganization = "CompTIA",
                category = "IT",
                validityPeriodYears = 3,
                renewalUrl = "https://www.comptia.org/certifications/network",
                pduUrl = "https://www.comptia.org/continuing-education",
                description = "Networking fundamentals and troubleshooting certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "comptia-security",
                name = "CompTIA Security+",
                issuingOrganization = "CompTIA",
                category = "Security",
                validityPeriodYears = 3,
                renewalUrl = "https://www.comptia.org/certifications/security",
                pduUrl = "https://www.comptia.org/continuing-education",
                description = "Cybersecurity fundamentals certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "azure-fundamentals",
                name = "Microsoft Azure Fundamentals",
                issuingOrganization = "Microsoft",
                category = "Cloud",
                validityPeriodYears = 1,
                renewalUrl = "https://docs.microsoft.com/en-us/learn/certifications/",
                pduUrl = "https://docs.microsoft.com/en-us/learn/",
                description = "Cloud concepts and Azure services fundamentals",
                isPopular = true
            ),
            CertificationTemplate(
                id = "itil",
                name = "ITIL 4 Foundation",
                issuingOrganization = "AXELOS",
                category = "IT",
                validityPeriodYears = 3,
                renewalUrl = "https://www.axelos.com/certifications/itil-service-management/itil-4-foundation",
                pduUrl = "https://www.axelos.com/",
                description = "IT service management best practices",
                isPopular = true
            ),
            CertificationTemplate(
                id = "ccna",
                name = "Cisco Certified Network Associate (CCNA)",
                issuingOrganization = "Cisco",
                category = "IT",
                validityPeriodYears = 3,
                renewalUrl = "https://www.cisco.com/c/en_in/training-events/training-certifications/certifications/associate/ccna.html",
                pduUrl = "https://www.cisco.com/c/en_in/training-events/training-certifications/continuing-education.html",
                description = "Cisco networking fundamentals certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "cism",
                name = "Certified Information Security Manager (CISM)",
                issuingOrganization = "ISACA",
                category = "Security",
                validityPeriodYears = 3,
                renewalUrl = "https://www.isaca.org/credentialing/cism/cism-maintain",
                pduUrl = "https://www.isaca.org/credentialing/cism/cism-maintain",
                description = "Information security management certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "gcp-associate",
                name = "Google Cloud Associate Cloud Engineer",
                issuingOrganization = "Google Cloud",
                category = "Cloud",
                validityPeriodYears = 3,
                renewalUrl = "https://cloud.google.com/certification/recertification",
                pduUrl = "https://cloud.google.com/training",
                description = "Google Cloud Platform fundamentals certification",
                isPopular = true
            ),
            CertificationTemplate(
                id = "prince2",
                name = "PRINCE2 Foundation",
                issuingOrganization = "AXELOS",
                category = "Project Management",
                validityPeriodYears = 3,
                renewalUrl = "https://www.axelos.com/certifications/prince2-project-management/prince2-foundation",
                pduUrl = "https://www.axelos.com/",
                description = "Structured project management methodology",
                isPopular = true
            )
        )
        
        templateRepository.insertTemplates(templates)
    }
}