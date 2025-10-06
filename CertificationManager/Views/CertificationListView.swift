import SwiftUI
import CoreData

struct CertificationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Certification.expirationDate, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default)
    private var certifications: FetchedResults<Certification>
    
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var showingAddCertification = false
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case expiringSoon = "Expiring Soon"
        case expired = "Expired"
    }
    
    var filteredCertifications: [Certification] {
        let filtered = certifications.filter { certification in
            let matchesSearch = searchText.isEmpty || 
                (certification.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (certification.issuingOrganization?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .active:
                matchesFilter = !certification.isExpired && !certification.isExpiringSoon
            case .expiringSoon:
                matchesFilter = certification.isExpiringSoon
            case .expired:
                matchesFilter = certification.isExpired
            }
            
            return matchesSearch && matchesFilter
        }
        
        return Array(filtered)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                FilterButton(
                                    title: option.rawValue,
                                    isSelected: selectedFilter == option,
                                    action: { selectedFilter = option }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                
                // Certifications List
                if filteredCertifications.isEmpty {
                    EmptyStateView(filter: selectedFilter, searchText: searchText)
                } else {
                    List {
                        ForEach(filteredCertifications, id: \.id) { certification in
                            NavigationLink(destination: CertificationDetailView(certification: certification)) {
                                CertificationRowView(certification: certification)
                            }
                        }
                        .onDelete(perform: deleteCertifications)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Certifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCertification = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCertification) {
                AddCertificationView()
            }
        }
    }
    
    private func deleteCertifications(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredCertifications[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting certifications: \(error)")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search certifications...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FilterButton: View {
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

struct CertificationRowView: View {
    let certification: Certification
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Circle()
                .fill(certification.status.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(certification.name ?? "Unknown Certification")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(certification.issuingOrganization ?? "Unknown Organization")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if let expirationDate = certification.expirationDate {
                        Text("Expires: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(certification.status.text)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(certification.status.color)
                }
            }
            
            Spacer()
            
            // PDU Progress (if applicable)
            if certification.pduRequired > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("PDU")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(certification.pduEarned)/\(certification.pduRequired)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(certification.pduProgress >= 1.0 ? .green : .blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let filter: CertificationListView.FilterOption
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(emptyStateMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateIcon: String {
        if !searchText.isEmpty {
            return "magnifyingglass"
        }
        
        switch filter {
        case .all:
            return "certificate"
        case .active:
            return "checkmark.circle"
        case .expiringSoon:
            return "exclamationmark.triangle"
        case .expired:
            return "xmark.circle"
        }
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty {
            return "No Results Found"
        }
        
        switch filter {
        case .all:
            return "No Certifications"
        case .active:
            return "No Active Certifications"
        case .expiringSoon:
            return "No Expiring Certifications"
        case .expired:
            return "No Expired Certifications"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or filters to find what you're looking for."
        }
        
        switch filter {
        case .all:
            return "Add your first certification to get started with tracking your professional credentials."
        case .active:
            return "You don't have any active certifications at the moment."
        case .expiringSoon:
            return "Great! No certifications are expiring soon."
        case .expired:
            return "You don't have any expired certifications."
        }
    }
}

#Preview {
    CertificationListView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}