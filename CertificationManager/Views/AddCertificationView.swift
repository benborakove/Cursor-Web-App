import SwiftUI
import CoreData

struct AddCertificationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var certificationDatabase = CertificationDatabase.shared
    @StateObject private var reminderManager = ReminderManager.shared
    
    @State private var searchText = ""
    @State private var selectedCategory: CertificationCategory? = nil
    @State private var showingCustomForm = false
    @State private var customCertification = CustomCertificationData()
    
    var filteredTemplates: [CertificationTemplate] {
        let filtered = certificationDatabase.searchCertifications(query: searchText)
        
        if let category = selectedCategory {
            return filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if showingCustomForm {
                    CustomCertificationForm(
                        certificationData: $customCertification,
                        onSave: saveCustomCertification,
                        onCancel: { showingCustomForm = false }
                    )
                } else {
                    VStack(spacing: 0) {
                        // Search and Filter
                        VStack(spacing: 12) {
                            SearchBar(text: $searchText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    FilterChip(
                                        title: "All",
                                        isSelected: selectedCategory == nil,
                                        action: { selectedCategory = nil }
                                    )
                                    
                                    ForEach(CertificationCategory.allCases, id: \.self) { category in
                                        FilterChip(
                                            title: category.rawValue,
                                            isSelected: selectedCategory == category,
                                            action: { selectedCategory = category }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Templates List
                        if filteredTemplates.isEmpty {
                            EmptyTemplatesView(searchText: searchText, selectedCategory: selectedCategory)
                        } else {
                            List {
                                ForEach(filteredTemplates, id: \.name) { template in
                                    TemplateRowView(template: template) {
                                        createCertificationFromTemplate(template)
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            }
            .navigationTitle("Add Certification")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if !showingCustomForm {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Custom") {
                            showingCustomForm = true
                        }
                    }
                }
            }
        }
    }
    
    private func createCertificationFromTemplate(_ template: CertificationTemplate) {
        let certification = Certification(context: viewContext)
        certification.id = UUID()
        certification.name = template.name
        certification.issuingOrganization = template.issuingOrganization
        certification.renewalURL = template.renewalURL
        certification.pduURL = template.pduURL
        certification.pduRequired = Int16(template.pduRequired)
        certification.pduEarned = 0
        certification.reminderDays = template.reminderDays.map(String.init).joined(separator: ",")
        certification.isActive = true
        certification.createdAt = Date()
        certification.updatedAt = Date()
        
        // Set default dates
        certification.issueDate = Date()
        if template.typicalValidityYears > 0 {
            certification.expirationDate = Calendar.current.date(byAdding: .year, value: template.typicalValidityYears, to: Date())
        }
        
        do {
            try viewContext.save()
            reminderManager.scheduleReminders(for: certification)
            dismiss()
        } catch {
            print("Error saving certification: \(error)")
        }
    }
    
    private func saveCustomCertification() {
        let certification = Certification(context: viewContext)
        certification.id = UUID()
        certification.name = customCertification.name
        certification.issuingOrganization = customCertification.issuingOrganization
        certification.certificationNumber = customCertification.certificationNumber
        certification.issueDate = customCertification.issueDate
        certification.expirationDate = customCertification.expirationDate
        certification.renewalURL = customCertification.renewalURL
        certification.pduURL = customCertification.pduURL
        certification.pduRequired = Int16(customCertification.pduRequired)
        certification.pduEarned = Int16(customCertification.pduEarned)
        certification.reminderDays = customCertification.reminderDays.map(String.init).joined(separator: ",")
        certification.isActive = true
        certification.createdAt = Date()
        certification.updatedAt = Date()
        
        do {
            try viewContext.save()
            reminderManager.scheduleReminders(for: certification)
            dismiss()
        } catch {
            print("Error saving custom certification: \(error)")
        }
    }
}

struct TemplateRowView: View {
    let template: CertificationTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: template.category.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(template.issuingOrganization)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(template.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                        
                        if template.pduRequired > 0 {
                            Text("\(template.pduRequired) PDU required")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if template.typicalValidityYears > 0 {
                            Text("\(template.typicalValidityYears) year validity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct EmptyTemplatesView: View {
    let searchText: String
    let selectedCategory: CertificationCategory?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Templates Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Try adjusting your search terms or category filter, or create a custom certification.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Custom Certification Form
struct CustomCertificationForm: View {
    @Binding var certificationData: CustomCertificationData
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("Certification Name", text: $certificationData.name)
                TextField("Issuing Organization", text: $certificationData.issuingOrganization)
                TextField("Certification Number (Optional)", text: $certificationData.certificationNumber)
            }
            
            Section("Dates") {
                DatePicker("Issue Date", selection: $certificationData.issueDate, displayedComponents: .date)
                DatePicker("Expiration Date (Optional)", selection: $certificationData.expirationDate, displayedComponents: .date)
            }
            
            Section("Renewal Information") {
                TextField("Renewal URL (Optional)", text: $certificationData.renewalURL)
                    .keyboardType(.URL)
                TextField("PDU Resources URL (Optional)", text: $certificationData.pduURL)
                    .keyboardType(.URL)
                
                HStack {
                    Text("PDU Required")
                    Spacer()
                    TextField("0", value: $certificationData.pduRequired, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                HStack {
                    Text("PDU Earned")
                    Spacer()
                    TextField("0", value: $certificationData.pduEarned, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
            }
            
            Section("Reminder Settings") {
                Text("Reminder Days (comma-separated)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("30, 7, 1", text: $certificationData.reminderDaysText)
                    .keyboardType(.numbersAndPunctuation)
            }
        }
        .navigationTitle("Custom Certification")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", action: onCancel)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave()
                }
                .disabled(certificationData.name.isEmpty || certificationData.issuingOrganization.isEmpty)
            }
        }
    }
}

struct CustomCertificationData {
    var name: String = ""
    var issuingOrganization: String = ""
    var certificationNumber: String = ""
    var issueDate: Date = Date()
    var expirationDate: Date = Date()
    var renewalURL: String = ""
    var pduURL: String = ""
    var pduRequired: Int = 0
    var pduEarned: Int = 0
    var reminderDaysText: String = "30, 7, 1"
    
    var reminderDays: [Int] {
        reminderDaysText.components(separatedBy: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }
}

#Preview {
    AddCertificationView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}