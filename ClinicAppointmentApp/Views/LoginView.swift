import SwiftUI

struct LoginView: View {
    var onLogin: (UserRole, Int) -> Void

    @State private var selectedRole: UserRole = .patient
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    private let roles: [UserRole] = [.patient, .doctor, .receptionist, .admin]

    private let demo: [(UserRole, String, String)] = [
        (.patient, "patient@harlayclinic.com", "patient123"),
        (.doctor, "doctor@harlayclinic.com", "doctor123"),
        (.receptionist, "reception@harlayclinic.com", "reception123"),
        (.admin, "admin@harlayclinic.com", "admin123")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    BrandLogo(size: 80)
                    BrandTitle(size: 28)
                    Text("Sign in to your portal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                // Role pills (2x2)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(roles, id: \.self) { role in
                        Button {
                            selectedRole = role
                        } label: {
                            Text(role.title)
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedRole == role ? Color.brand : Color(.systemBackground))
                                .foregroundStyle(selectedRole == role ? Color.white : Color.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(selectedRole == role ? Color.brand : Color.cardBorder, lineWidth: 1)
                                )
                        }
                    }
                }

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope").foregroundStyle(.secondary)
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.cardBorder))

                    HStack(spacing: 12) {
                        Image(systemName: "lock").foregroundStyle(.secondary)
                        Group {
                            if showPassword { TextField("Password", text: $password) }
                            else { SecureField("Password", text: $password) }
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        Button { showPassword.toggle() } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye").foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.cardBorder))
                }

                Button {
                    let userId: Int
                    switch selectedRole {
                    case .patient: userId = 1
                    case .doctor: userId = 1
                    case .receptionist, .admin: userId = 0
                    }
                    onLogin(selectedRole, userId)
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.brand, Color.brandDark], startPoint: .top, endPoint: .bottom))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.brand.opacity(0.3), radius: 8, x: 0, y: 4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill").foregroundStyle(Color.brand)
                        Text("Demo credentials (tap to fill)").font(.subheadline.weight(.semibold))
                    }
                    ForEach(demo, id: \.1) { d in
                        Button {
                            selectedRole = d.0
                            email = d.1
                            password = d.2
                        } label: {
                            Text("\(d.0.title): \(d.1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Text("Any password works in this prototype.")
                        .font(.caption2).foregroundStyle(.tertiary)
                }
                .card()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.screenBG.ignoresSafeArea())
    }
}
