import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var reminderManager = ReminderManager.shared
    @StateObject private var certificationDatabase = CertificationDatabase.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CertificationListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Certifications")
                }
                .tag(0)
            
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(1)
            
            AddCertificationView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add New")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .onAppear {
            reminderManager.requestNotificationPermission()
        }
    }
}

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Certification.expirationDate, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default)
    private var certifications: FetchedResults<Certification>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary Cards
                    HStack(spacing: 15) {
                        SummaryCard(
                            title: "Total Certifications",
                            value: "\(certifications.count)",
                            color: .blue,
                            icon: "certificate.fill"
                        )
                        
                        SummaryCard(
                            title: "Expiring Soon",
                            value: "\(expiringSoonCount)",
                            color: .orange,
                            icon: "exclamationmark.triangle.fill"
                        )
                    }
                    
                    HStack(spacing: 15) {
                        SummaryCard(
                            title: "Expired",
                            value: "\(expiredCount)",
                            color: .red,
                            icon: "xmark.circle.fill"
                        )
                        
                        SummaryCard(
                            title: "Active",
                            value: "\(activeCount)",
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                    }
                    
                    // Upcoming Expirations
                    if !upcomingExpirations.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Upcoming Expirations")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(upcomingExpirations, id: \.id) { certification in
                                ExpirationCard(certification: certification)
                            }
                        }
                    }
                    
                    // PDU Progress
                    if !pduRequiredCertifications.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PDU Progress")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(pduRequiredCertifications, id: \.id) { certification in
                                PDUProgressCard(certification: certification)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private var expiringSoonCount: Int {
        certifications.filter { $0.isExpiringSoon }.count
    }
    
    private var expiredCount: Int {
        certifications.filter { $0.isExpired }.count
    }
    
    private var activeCount: Int {
        certifications.filter { !$0.isExpired && !$0.isExpiringSoon }.count
    }
    
    private var upcomingExpirations: [Certification] {
        Array(certifications.filter { !$0.isExpired }.prefix(5))
    }
    
    private var pduRequiredCertifications: [Certification] {
        certifications.filter { $0.pduRequired > 0 }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExpirationCard: View {
    let certification: Certification
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(certification.name ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(certification.issuingOrganization ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Expires: \(certification.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text("\(certification.daysUntilExpiration)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(certification.status.color)
                
                Text("days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PDUProgressCard: View {
    let certification: Certification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(certification.name ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(certification.pduEarned)/\(certification.pduRequired)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: certification.pduProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: certification.pduProgress >= 1.0 ? .green : .blue))
            
            if let pduURL = certification.pduURL, !pduURL.isEmpty {
                Link("View PDU Resources", destination: URL(string: pduURL)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}