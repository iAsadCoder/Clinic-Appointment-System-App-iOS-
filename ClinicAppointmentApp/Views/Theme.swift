import SwiftUI

// MARK: - Colors (aligned with web --primary / --navy)
extension Color {
    static let brand      = Color(red: 0.082, green: 0.396, blue: 0.902) // #1565e6
    static let brandDark  = Color(red: 0.051, green: 0.310, blue: 0.753) // #0d4fc0
    static let brandLight = Color(red: 0.910, green: 0.941, blue: 0.996) // #e8f0fe
    static let navy       = Color(red: 0.043, green: 0.106, blue: 0.204) // #0b1b34
    static let navy2      = Color(red: 0.024, green: 0.094, blue: 0.188) // #061830
    static let screenBG   = Color(red: 0.957, green: 0.969, blue: 0.984) // #f4f7fb
    static let cardBorder = Color(red: 0.898, green: 0.922, blue: 0.953) // #e5ebf3
    static let mutedText  = Color(red: 0.392, green: 0.455, blue: 0.545) // #64748b
    static let sidebarText = Color(red: 0.765, green: 0.816, blue: 0.894) // #c3d0e4
    static let accent     = Color(red: 0.220, green: 0.741, blue: 0.973) // #38bdf8
}

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.cardBorder, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View { modifier(CardStyle(padding: padding)) }
}

struct BrandTitle: View {
    var size: CGFloat = 28
    var light: Bool = false
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("Harlay Clinic")
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(light ? Color.white : Color.navy)
            Text("By Asad Irfan")
                .font(.system(size: max(size * 0.38, 10), weight: .medium))
                .foregroundStyle(light ? Color.white.opacity(0.7) : Color.mutedText)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

struct BrandLogo: View {
    var size: CGFloat = 96
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: size))
                .foregroundStyle(
                    LinearGradient(colors: [Color(red: 0.80, green: 0.89, blue: 1.0), Color(red: 0.55, green: 0.72, blue: 1.0)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: Color.brand.opacity(0.25), radius: 12, x: 0, y: 8)
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(Color.brand)
        }
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 46, height: 46)
                Image(systemName: icon).font(.system(size: 20, weight: .semibold)).foregroundStyle(color)
            }
            Text(title).font(.subheadline).foregroundStyle(.primary)
            Text(value).font(.system(size: 28, weight: .bold)).foregroundStyle(color)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .card()
    }
}

struct StatusPill: View {
    let status: AppointmentStatus
    var body: some View {
        Text(status == .awaitingPatientResponse ? "Awaiting" : status.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(status.color.opacity(0.15))
            .foregroundStyle(status.color)
            .clipShape(Capsule())
    }
}

struct AvatarView: View {
    var urlString: String = ""
    var name: String = ""
    var size: CGFloat = 52
    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }
    var body: some View {
        ZStack {
            Circle().fill(Color.brandLight)
            if let url = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: url) { img in img.resizable().scaledToFill() } placeholder: { initialsView }
            } else if !name.isEmpty {
                initialsView
            } else {
                Image(systemName: "person").font(.system(size: size * 0.42)).foregroundStyle(Color.brand)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    private var initialsView: some View {
        Text(initials.isEmpty ? "?" : initials)
            .font(.system(size: size * 0.36, weight: .semibold))
            .foregroundStyle(Color.brand)
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        HStack {
            Text(title).font(.headline).foregroundStyle(Color.navy)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: 2) { Text(actionTitle); Image(systemName: "chevron.right") }
                        .font(.subheadline.weight(.medium))
                }
            }
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    var showPatient: Bool = false
    @EnvironmentObject var data: MockDataService
    private var title: String {
        if showPatient { return data.patient(by: appointment.patientId)?.name ?? "Patient" }
        return data.doctor(by: appointment.doctorId)?.name ?? "Doctor"
    }
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(name: title, size: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.navy)
                Text(data.service(by: appointment.serviceId)?.name ?? "").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    Label(appointment.date, systemImage: "calendar")
                    Label(Formatters.time12(appointment.time), systemImage: "clock")
                }
                .font(.caption2).foregroundStyle(Color.brand)
            }
            Spacer(minLength: 4)
            StatusPill(status: appointment.status)
        }
        .padding(.vertical, 6)
    }
}

enum Formatters {
    static func time12(_ t: String) -> String {
        let parts = t.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return t }
        let h = parts[0], m = parts[1]
        let suffix = h >= 12 ? "PM" : "AM"
        let h12 = h % 12 == 0 ? 12 : h % 12
        return String(format: "%d:%02d %@", h12, m, suffix)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 40)).foregroundStyle(Color.brand.opacity(0.5))
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .card()
    }
}
