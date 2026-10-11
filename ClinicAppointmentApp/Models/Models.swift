import Foundation
import SwiftUI

struct ClinicRules {
    static let maxAdvanceDays = 30
    static let minNoticeHours = 24
    static let defaultSlotDurationMinutes = 30
}

enum AppointmentStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case awaitingPatientResponse = "Awaiting Patient Response"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case rescheduled = "Rescheduled"
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .green
        case .awaitingPatientResponse: return .blue
        case .completed: return .purple
        case .cancelled: return .red
        case .rescheduled: return .indigo
        }
    }
}

enum UserRole: String, Codable, CaseIterable {
    case patient, doctor, admin, receptionist
    var title: String {
        switch self {
        case .patient: return "Patient"
        case .doctor: return "Doctor"
        case .admin: return "Admin"
        case .receptionist: return "Reception"
        }
    }
}

struct Specialty: Identifiable, Codable { let id: Int; let name: String }
struct Service: Identifiable, Codable {
    let id: Int; var name: String; var duration: Int; var price: Double; var specialtyId: Int
    var active: Bool = true
}
struct DayHours: Codable { var start: String; var end: String }
struct WorkingHours: Codable {
    var mon: DayHours?; var tue: DayHours?; var wed: DayHours?
    var thu: DayHours?; var fri: DayHours?; var sat: DayHours?; var sun: DayHours?
}
struct Doctor: Identifiable, Codable {
    let id: Int; var name: String; var title: String; var specialties: [Int]
    var experience: String; var imageURL: String
    var workingHours: WorkingHours; var leaveDates: [String]
    var locationId: Int = 1
}
struct Patient: Identifiable, Codable {
    let id: Int; var name: String; var email: String; var phone: String; var dob: String
}
struct Appointment: Identifiable, Codable {
    let id: Int
    var patientId: Int; var doctorId: Int; var serviceId: Int
    var locationId: Int = 1
    var date: String; var time: String
    var status: AppointmentStatus
    var source: String
    var notes: String
    var prescription: String
    var checkInStatus: String = "Scheduled"
    var createdAt: String
    var originalDate: String?
    var originalTime: String?
}
struct TimeSlot: Identifiable {
    let id = UUID(); let time: String; let available: Bool
}
struct Location: Identifiable, Codable {
    let id: Int; var name: String; var address: String; var phone: String
}
struct Feedback: Identifiable, Codable {
    let id: Int; let appointmentId: Int; let patientId: Int; let doctorId: Int
    let rating: Int; let comment: String; let createdAt: String
}
struct WaitingEntry: Identifiable, Codable {
    let id: Int; var patientId: Int; var doctorId: Int; var serviceId: Int
    var locationId: Int; var preferredDate: String; var notes: String; var status: String
}
struct AppNotification: Identifiable, Codable {
    let id: Int; var type: String; var message: String; var time: String; var read: Bool
}

// Side menu destinations per role
enum MenuItem: String, CaseIterable, Identifiable, Hashable {
    // Shared / patient
    case dashboard, book, appointments, history, feedback, profile
    // Doctor
    case availability, patients, notes
    // Admin
    case doctors, services, schedules, reports, notifications, settings
    case locations, specialties, billing, waiting
    // Reception
    case queue, bookForPatient
    case logout

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .book: return "Book Appointment"
        case .appointments: return "Appointments"
        case .history: return "Medical History"
        case .feedback: return "Feedback"
        case .profile: return "Profile"
        case .availability: return "My Availability"
        case .patients: return "Patients"
        case .notes: return "Clinical Notes"
        case .doctors: return "Doctors"
        case .services: return "Services & Pricing"
        case .schedules: return "Schedules"
        case .reports: return "Reports"
        case .notifications: return "Notifications"
        case .settings: return "Settings"
        case .locations: return "Locations"
        case .specialties: return "Specialties"
        case .billing: return "Billing"
        case .waiting: return "Waiting List"
        case .queue: return "Today's Queue"
        case .bookForPatient: return "Book for Patient"
        case .logout: return "Logout"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .book, .bookForPatient: return "calendar.badge.plus"
        case .appointments: return "calendar"
        case .history: return "clock.arrow.circlepath"
        case .feedback: return "star.fill"
        case .profile: return "person.circle"
        case .availability: return "clock"
        case .patients: return "person.2.fill"
        case .notes: return "doc.text.fill"
        case .doctors: return "stethoscope"
        case .services: return "cross.case.fill"
        case .schedules: return "calendar.badge.clock"
        case .reports: return "chart.bar.fill"
        case .notifications: return "bell.fill"
        case .settings: return "gearshape.fill"
        case .locations: return "mappin.and.ellipse"
        case .specialties: return "list.bullet.rectangle"
        case .billing: return "doc.richtext"
        case .waiting: return "hourglass"
        case .queue: return "person.3.fill"
        case .logout: return "rectangle.portrait.and.arrow.right"
        }
    }

    static func items(for role: UserRole) -> [MenuItem] {
        switch role {
        case .patient:
            return [.dashboard, .book, .appointments, .history, .feedback, .profile, .logout]
        case .doctor:
            return [.dashboard, .appointments, .availability, .patients, .notes, .profile, .logout]
        case .admin:
            return [.dashboard, .appointments, .doctors, .patients, .services, .schedules,
                    .locations, .specialties, .waiting, .billing, .reports, .notifications, .settings, .logout]
        case .receptionist:
            return [.queue, .bookForPatient, .patients, .waiting, .logout]
        }
    }
}
