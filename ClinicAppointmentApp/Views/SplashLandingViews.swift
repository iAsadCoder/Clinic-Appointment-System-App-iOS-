import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.6
    @State private var ringOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var pulse = false
    @State private var progress: CGFloat = 0
    @State private var canSkip = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.navy2, Color.navy, Color.brandDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Interactive floating orbs
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.06 + Double(i) * 0.015))
                    .frame(width: CGFloat(80 + i * 40))
                    .offset(
                        x: pulse ? CGFloat([-60, 50, -30, 70, -20][i]) : CGFloat([40, -50, 60, -40, 30][i]),
                        y: pulse ? CGFloat([-80, 40, 90, -50, 20][i]) : CGFloat([30, -60, -20, 70, -40][i])
                    )
                    .blur(radius: 1)
            }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 3)
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                    BrandLogo(size: 88)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 6) {
                    Text("Harlay Clinic")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                    Text("By Asad Irfan")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                    Text("Clinic Appointment System")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.top, 4)
                }
                .opacity(titleOpacity)

                if canSkip {
                    Button("Tap to continue") { finish() }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if canSkip { finish() }
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.7)) {
                logoScale = 1; logoOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.15)) {
                ringScale = 1; ringOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                titleOpacity = 1
            }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.linear(duration: 2.4)) {
                progress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation { canSkip = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                finish()
            }
        }
    }

    private func finish() {
        onFinished()
    }
}

struct LandingView: View {
    var onContinue: () -> Void
    @State private var page = 0
    @State private var animateHero = false
    @State private var showContent = false

    private let pages: [(icon: String, title: String, body: String)] = [
        ("heart.text.square.fill", "Care at Your Fingertips", "Book appointments, manage visits, and stay connected with your clinic from one calm interface."),
        ("stethoscope", "Built for Every Role", "Patient, Doctor, Reception, and Admin each have a full portal—mirroring the website experience."),
        ("person.badge.plus", "Register Anyone", "Staff can add unregistered patients so walk-ins are never left out of the system.")
    ]

    var body: some View {
        ZStack {
            Color.screenBG.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(colors: [Color.navy, Color.brand], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea(edges: .top)
                    Group {
                        Image(systemName: "cross.case.fill").font(.system(size: 36)).foregroundStyle(.white.opacity(0.18))
                            .offset(x: animateHero ? 90 : -90, y: -50)
                        Image(systemName: "waveform.path.ecg").font(.system(size: 48)).foregroundStyle(.white.opacity(0.22))
                            .offset(x: animateHero ? -70 : 70, y: 30)
                        Image(systemName: "pills.fill").font(.system(size: 28)).foregroundStyle(.white.opacity(0.15))
                            .offset(x: animateHero ? 40 : -40, y: 70)
                    }
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateHero)

                    VStack(spacing: 14) {
                        BrandLogo(size: 80).scaleEffect(showContent ? 1 : 0.7).opacity(showContent ? 1 : 0)
                        BrandTitle(size: 24, light: true).opacity(showContent ? 1 : 0)
                        Text("Clinic Appointment System")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.85)).opacity(showContent ? 1 : 0)
                    }
                    .padding(.top, 20)
                }
                .frame(height: 260)
                .clipped()

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 16) {
                            ZStack {
                                Circle().fill(Color.brandLight).frame(width: 72, height: 72)
                                Image(systemName: item.icon).font(.system(size: 30, weight: .semibold)).foregroundStyle(Color.brand)
                            }
                            Text(item.title).font(.title2.weight(.bold)).multilineTextAlignment(.center)
                            Text(item.body).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 28)
                            Spacer(minLength: 0)
                        }
                        .padding(.top, 28)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxHeight: .infinity)

                VStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text(page == pages.count - 1 ? "Get Started" : "Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [Color.brand, Color.brandDark], startPoint: .top, endPoint: .bottom))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.brand.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    if page < pages.count - 1 {
                        Button("Skip") { onContinue() }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            animateHero = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) { showContent = true }
        }
    }
}
