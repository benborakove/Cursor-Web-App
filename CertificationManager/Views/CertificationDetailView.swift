import SwiftUI
import CoreData

struct CertificationDetailView: View {
    let certification: Certification
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var reminderManager = ReminderManager.shared
    @State private var showingEditView = false
    @State private var showingDocumentPicker = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(certification.name ?? "Unknown Certification")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(certification.issuingOrganization ?? "Unknown Organization")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusBadge(status: certification.status)
                    }
                    
                    if let certificationNumber = certification.certificationNumber, !certificationNumber.isEmpty {
                        HStack {
                            Text("Certification Number:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(certificationNumber)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Dates Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Important Dates")
                        .font(.headline)
                    
                    DateRow(
                        title: "Issue Date",
                        date: certification.issueDate,
                        icon: "calendar.badge.plus"
                    )
                    
                    DateRow(
                        title: "Expiration Date",
                        date: certification.expirationDate,
                        icon: "calendar.badge.exclamationmark",
                        isExpiration: true
                    )
                    
                    if let expirationDate = certification.expirationDate {
                        ExpirationInfoCard(daysUntilExpiration: certification.daysUntilExpiration)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // PDU Progress (if applicable)
                if certification.pduRequired > 0 {
                    PDUProgressSection(certification: certification)
                }
                
                // Document Section
                DocumentSection(
                    documentPath: certification.documentPath,
                    onDocumentSelected: { path in
                        certification.documentPath = path
                        saveContext()
                    }
                )
                
                // Renewal Resources
                RenewalResourcesSection(
                    renewalURL: certification.renewalURL,
                    pduURL: certification.pduURL
                )
                
                // Reminder Settings
                ReminderSettingsSection(certification: certification)
                
                // Actions
                ActionsSection(
                    certification: certification,
                    onEdit: { showingEditView = true },
                    onDelete: { showingDeleteAlert = true }
                )
            }
            .padding()
        }
        .navigationTitle("Certification Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditCertificationView(certification: certification)
        }
        .alert("Delete Certification", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCertification()
            }
        } message: {
            Text("Are you sure you want to delete this certification? This action cannot be undone.")
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func deleteCertification() {
        reminderManager.cancelReminders(for: certification.id!)
        viewContext.delete(certification)
        saveContext()
    }
}

struct StatusBadge: View {
    let status: CertificationStatus
    
    var body: some View {
        Text(status.text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(status.color)
            .cornerRadius(12)
    }
}

struct DateRow: View {
    let title: String
    let date: Date?
    let icon: String
    var isExpiration: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isExpiration ? .orange : .blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let date = date {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else {
                Text("Not set")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ExpirationInfoCard: View {
    let daysUntilExpiration: Int
    
    var body: some View {
        HStack {
            Image(systemName: daysUntilExpiration <= 30 ? "exclamationmark.triangle.fill" : "info.circle.fill")
                .foregroundColor(daysUntilExpiration <= 30 ? .orange : .blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(daysUntilExpiration <= 0 ? "This certification has expired" : "Days until expiration")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(abs(daysUntilExpiration)) days")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(daysUntilExpiration <= 30 ? .orange : .blue)
            }
            
            Spacer()
        }
        .padding()
        .background(daysUntilExpiration <= 30 ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PDUProgressSection: View {
    let certification: Certification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PDU Progress")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Professional Development Units")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(certification.pduEarned)/\(certification.pduRequired)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                ProgressView(value: certification.pduProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: certification.pduProgress >= 1.0 ? .green : .blue))
                
                if certification.pduProgress < 1.0 {
                    Text("\(certification.pduRequired - certification.pduEarned) PDU(s) remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("PDU requirement completed!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DocumentSection: View {
    let documentPath: String?
    let onDocumentSelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Document")
                .font(.headline)
            
            if let documentPath = documentPath, !documentPath.isEmpty {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.blue)
                    
                    Text(URL(fileURLWithPath: documentPath).lastPathComponent)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button("View") {
                        // Open document
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                Button(action: { /* Show document picker */ }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Document")
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RenewalResourcesSection: View {
    let renewalURL: String?
    let pduURL: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Renewal Resources")
                .font(.headline)
            
            VStack(spacing: 8) {
                if let renewalURL = renewalURL, !renewalURL.isEmpty {
                    ResourceLink(
                        title: "Renewal Portal",
                        url: renewalURL,
                        icon: "arrow.clockwise.circle"
                    )
                }
                
                if let pduURL = pduURL, !pduURL.isEmpty {
                    ResourceLink(
                        title: "PDU Resources",
                        url: pduURL,
                        icon: "book.circle"
                    )
                }
                
                if (renewalURL?.isEmpty ?? true) && (pduURL?.isEmpty ?? true) {
                    Text("No renewal resources available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ResourceLink: View {
    let title: String
    let url: String
    let icon: String
    
    var body: some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct ReminderSettingsSection: View {
    let certification: Certification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder Settings")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Reminder Days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(certification.reminderDaysArray.map { "\($0) days" }.joined(separator: ", "))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("You'll receive notifications at these intervals before expiration")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActionsSection: View {
    let certification: Certification
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onEdit) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Certification")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: onDelete) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Certification")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Edit Certification View
struct EditCertificationView: View {
    let certification: Certification
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var reminderManager = ReminderManager.shared
    
    @State private var name: String
    @State private var issuingOrganization: String
    @State private var certificationNumber: String
    @State private var issueDate: Date
    @State private var expirationDate: Date
    @State private var renewalURL: String
    @State private var pduURL: String
    @State private var pduRequired: Int
    @State private var pduEarned: Int
    @State private var reminderDaysText: String
    
    init(certification: Certification) {
        self.certification = certification
        _name = State(initialValue: certification.name ?? "")
        _issuingOrganization = State(initialValue: certification.issuingOrganization ?? "")
        _certificationNumber = State(initialValue: certification.certificationNumber ?? "")
        _issueDate = State(initialValue: certification.issueDate ?? Date())
        _expirationDate = State(initialValue: certification.expirationDate ?? Date())
        _renewalURL = State(initialValue: certification.renewalURL ?? "")
        _pduURL = State(initialValue: certification.pduURL ?? "")
        _pduRequired = State(initialValue: Int(certification.pduRequired))
        _pduEarned = State(initialValue: Int(certification.pduEarned))
        _reminderDaysText = State(initialValue: certification.reminderDays ?? "30, 7, 1")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Certification Name", text: $name)
                    TextField("Issuing Organization", text: $issuingOrganization)
                    TextField("Certification Number", text: $certificationNumber)
                }
                
                Section("Dates") {
                    DatePicker("Issue Date", selection: $issueDate, displayedComponents: .date)
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                }
                
                Section("Renewal Information") {
                    TextField("Renewal URL", text: $renewalURL)
                        .keyboardType(.URL)
                    TextField("PDU Resources URL", text: $pduURL)
                        .keyboardType(.URL)
                    
                    HStack {
                        Text("PDU Required")
                        Spacer()
                        TextField("0", value: $pduRequired, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("PDU Earned")
                        Spacer()
                        TextField("0", value: $pduEarned, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("Reminder Settings") {
                    TextField("Reminder Days (comma-separated)", text: $reminderDaysText)
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            .navigationTitle("Edit Certification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || issuingOrganization.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        certification.name = name
        certification.issuingOrganization = issuingOrganization
        certification.certificationNumber = certificationNumber.isEmpty ? nil : certificationNumber
        certification.issueDate = issueDate
        certification.expirationDate = expirationDate
        certification.renewalURL = renewalURL.isEmpty ? nil : renewalURL
        certification.pduURL = pduURL.isEmpty ? nil : pduURL
        certification.pduRequired = Int16(pduRequired)
        certification.pduEarned = Int16(pduEarned)
        certification.reminderDays = reminderDaysText
        certification.updatedAt = Date()
        
        do {
            try viewContext.save()
            reminderManager.scheduleReminders(for: certification)
            dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let certification = Certification(context: context)
    certification.name = "PMP"
    certification.issuingOrganization = "PMI"
    certification.issueDate = Date()
    certification.expirationDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())
    certification.pduRequired = 60
    certification.pduEarned = 30
    
    return CertificationDetailView(certification: certification)
        .environment(\.managedObjectContext, context)
}