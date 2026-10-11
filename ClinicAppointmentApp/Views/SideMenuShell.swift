import SwiftUI

/// Side drawer shell matching web navy sidebar aesthetic.
struct SideMenuShell<Content: View>: View {
    let role: UserRole
    let userName: String
    let userSubtitle: String
    @Binding var selected: MenuItem
    var onLogout: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var showMenu = false
    @GestureState private var dragOffset: CGFloat = 0

    private let menuWidth: CGFloat = 286
    private var items: [MenuItem] { MenuItem.items(for: role).filter { $0 != .logout } }

    var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            VStack(spacing: 0) {
                // Top bar
                HStack(spacing: 14) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { showMenu.toggle() }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.navy)
                            .frame(width: 40, height: 40)
                            .background(Color.brandLight)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(selected.title)
                            .font(.headline)
                            .foregroundStyle(Color.navy)
                        Text(role.title + " Portal")
                            .font(.caption)
                            .foregroundStyle(Color.mutedText)
                    }
                    Spacer()
                    BrandLogo(size: 28)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Color.cardBorder).frame(height: 1)
                }

                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.screenBG)
            .offset(x: showMenu ? menuWidth * 0.15 : 0)
            .disabled(showMenu)
            .onTapGesture {
                if showMenu {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { showMenu = false }
                }
            }

            // Dim overlay
            if showMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { showMenu = false }
                    }
                    .transition(.opacity)
            }

            // Drawer
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        BrandLogo(size: 48)
                        Text("Harlay Clinic")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text("By Asad Irfan")
                            .font(.caption)
                            .foregroundStyle(Color.sidebarText)
                        HStack(spacing: 10) {
                            AvatarView(name: userName, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(userName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(userSubtitle)
                                    .font(.caption2)
                                    .foregroundStyle(Color.sidebarText)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(colors: [Color.navy, Color.navy2], startPoint: .top, endPoint: .bottom)
                    )

                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(items) { item in
                                Button {
                                    selected = item
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { showMenu = false }
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: item.icon)
                                            .font(.system(size: 16, weight: .semibold))
                                            .frame(width: 24)
                                        Text(item.title)
                                            .font(.subheadline.weight(selected == item ? .semibold : .regular))
                                        Spacer()
                                        if selected == item {
                                            Circle().fill(Color.accent).frame(width: 6, height: 6)
                                        }
                                    }
                                    .foregroundStyle(selected == item ? Color.white : Color.sidebarText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        selected == item
                                        ? Color.white.opacity(0.12)
                                        : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 12)
                    }

                    Spacer(minLength: 0)

                    Button {
                        withAnimation { showMenu = false }
                        onLogout()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: MenuItem.logout.icon)
                            Text(MenuItem.logout.title)
                            Spacer()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(red: 1, green: 0.7, blue: 0.7))
                        .padding(16)
                    }
                }
                .frame(width: menuWidth)
                .background(Color.navy2)
                .offset(x: showMenu ? 0 : -menuWidth + min(0, dragOffset))

                Spacer(minLength: 0)
            }
            .ignoresSafeArea()
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    if showMenu {
                        state = min(0, value.translation.width)
                    } else if value.startLocation.x < 24 {
                        state = max(0, value.translation.width)
                    }
                }
                .onEnded { value in
                    if showMenu && value.translation.width < -80 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { showMenu = false }
                    } else if !showMenu && value.startLocation.x < 24 && value.translation.width > 80 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { showMenu = true }
                    }
                }
        )
    }
}
