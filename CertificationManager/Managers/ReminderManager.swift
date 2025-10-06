import Foundation
import UserNotifications
import CoreData

class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    private init() {}
    
    // MARK: - Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Schedule Reminders
    func scheduleReminders(for certification: Certification) {
        guard let expirationDate = certification.expirationDate,
              let certificationId = certification.id else { return }
        
        // Cancel existing reminders for this certification
        cancelReminders(for: certificationId)
        
        let reminderDays = certification.reminderDaysArray
        
        for days in reminderDays {
            let reminderDate = Calendar.current.date(byAdding: .day, value: -days, to: expirationDate) ?? expirationDate
            
            // Only schedule if the reminder date is in the future
            if reminderDate > Date() {
                scheduleNotification(
                    for: certificationId,
                    title: "Certification Expiring Soon",
                    body: "Your \(certification.name ?? "certification") expires in \(days) days",
                    date: reminderDate,
                    identifier: "\(certificationId.uuidString)_\(days)"
                )
            }
        }
    }
    
    private func scheduleNotification(for certificationId: UUID, title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Reminders
    func cancelReminders(for certificationId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.compactMap { request in
                request.identifier.hasPrefix(certificationId.uuidString) ? request.identifier : nil
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    // MARK: - Email Reminders
    func sendEmailReminder(for certification: Certification, daysUntilExpiration: Int) {
        // In a real app, this would integrate with an email service
        // For now, we'll just log the email content
        let emailContent = """
        Subject: Certification Expiration Reminder
        
        Dear User,
        
        This is a reminder that your certification "\(certification.name ?? "Unknown")" 
        from \(certification.issuingOrganization ?? "Unknown Organization") 
        will expire in \(daysUntilExpiration) days.
        
        Expiration Date: \(certification.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")
        
        Please take action to renew your certification.
        
        Renewal URL: \(certification.renewalURL ?? "Not available")
        PDU Resources: \(certification.pduURL ?? "Not available")
        
        Best regards,
        Certification Manager
        """
        
        print("Email reminder content:\n\(emailContent)")
    }
    
    // MARK: - Check and Send Reminders
    func checkAndSendReminders(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Certification> = Certification.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES AND expirationDate != nil")
        
        do {
            let certifications = try context.fetch(request)
            
            for certification in certifications {
                guard let expirationDate = certification.expirationDate else { continue }
                
                let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
                let reminderDays = certification.reminderDaysArray
                
                if reminderDays.contains(daysUntilExpiration) {
                    sendEmailReminder(for: certification, daysUntilExpiration: daysUntilExpiration)
                }
            }
        } catch {
            print("Error fetching certifications for reminders: \(error)")
        }
    }
    
    // MARK: - Background Task
    func scheduleBackgroundReminderCheck() {
        // This would typically be called from the app delegate or scene delegate
        // to check for reminders when the app becomes active
        checkAndSendReminders(context: PersistenceController.shared.container.viewContext)
    }
}