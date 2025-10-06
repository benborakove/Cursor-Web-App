import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var reminderManager = ReminderManager.shared
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingAbout = false
    @State private var showingExportOptions = false
    @State private var showingImportOptions = false
    
    var body: some View {
        NavigationView {
            List {
                // Notifications Section
                Section("Notifications") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Push Notifications")
                                .font(.subheadline)
                            
                            Text(notificationStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if notificationPermissionStatus == .denied {
                            Button("Settings") {
                                openAppSettings()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: requestNotificationPermission) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Request Permission")
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(notificationPermissionStatus == .authorized)
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: { showingExportOptions = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Export Data")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: { showingImportOptions = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Import Data")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: clearAllData) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Clear All Data")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("About")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Support Section
                Section("Support") {
                    Button(action: sendFeedback) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Send Feedback")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: rateApp) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            
                            Text("Rate App")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            checkNotificationPermission()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView()
        }
        .sheet(isPresented: $showingImportOptions) {
            ImportOptionsView()
        }
    }
    
    private var notificationStatusText: String {
        switch notificationPermissionStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Disabled - Enable in Settings"
        case .notDetermined:
            return "Not Set"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestNotificationPermission() {
        reminderManager.requestNotificationPermission()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            checkNotificationPermission()
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func clearAllData() {
        // This would clear all Core Data
        // Implementation would depend on your specific needs
    }
    
    private func sendFeedback() {
        if let url = URL(string: "mailto:support@certificationmanager.app?subject=Feedback") {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        // This would open the App Store rating page
        // Implementation would depend on your app's App Store URL
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App Icon and Name
                    VStack(spacing: 12) {
                        Image(systemName: "certificate.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Certification Manager")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Certification Manager helps you track and manage your professional certifications with ease. Never miss an expiration date again with our intelligent reminder system.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "bell.fill", text: "Smart reminders and notifications")
                            FeatureRow(icon: "chart.bar.fill", text: "Progress tracking and analytics")
                            FeatureRow(icon: "link", text: "Direct links to renewal resources")
                            FeatureRow(icon: "doc.fill", text: "Document storage and management")
                            FeatureRow(icon: "list.bullet", text: "Comprehensive certification database")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Credits")
                            .font(.headline)
                        
                        Text("Built with SwiftUI and Core Data")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Export Format") {
                    Button(action: exportToCSV) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Export to CSV")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: exportToPDF) {
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Export to PDF")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Section("What's Included") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Certification details")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Expiration dates")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("PDU progress")
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportToCSV() {
        // Implement CSV export
        dismiss()
    }
    
    private func exportToPDF() {
        // Implement PDF export
        dismiss()
    }
}

struct ImportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Import From") {
                    Button(action: importFromCSV) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Import from CSV")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: importFromJSON) {
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Import from JSON")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Section("Supported Fields") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Certification name")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Issuing organization")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Issue and expiration dates")
                    }
                }
            }
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func importFromCSV() {
        // Implement CSV import
        dismiss()
    }
    
    private func importFromJSON() {
        // Implement JSON import
        dismiss()
    }
}

#Preview {
    SettingsView()
}