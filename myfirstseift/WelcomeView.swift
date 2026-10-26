import SwiftUI

struct WelcomeView: View {
    @State private var glow = false          // إضاءة الألوان
    @State private var drift = false         // حركة خفيفة مستمرة
    @State private var showTitle = false
    @State private var showSubtitle = false

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 6) {
                Spacer()

                Text("مرحبا بك !")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(Color.welcomeBrown)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 14)

                Text("في دليلك للعناية بمنزلك")
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(Color.welcomeBrown)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.bottom, 170)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .ignoresSafeArea()
        .onAppear(perform: runAnimation)
    }

    // MARK: - Animation

    private func runAnimation() {
        // 1) الألوان تضيء (كل دائرة لها delay بالـ background)
        glow = true

        // 2) بعد ما تضيء الألوان يظهر العنوان
        withAnimation(.easeOut(duration: 1.0).delay(1.6)) {
            showTitle = true
        }

        // 3) بعده بشوي النص الصغير
        withAnimation(.easeOut(duration: 1.0).delay(2.1)) {
            showSubtitle = true
        }

        // 4) حركة خفيفة مستمرة للألوان
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true).delay(2.5)) {
            drift = true
        }
    }

    // MARK: - Background

    private var background: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Color(red: 0.96, green: 0.98, blue: 0.93)

                // أخضر ليموني أعلى اليسار
                glowCircle(
                    color: Color(red: 0.82, green: 0.91, blue: 0.62),
                    size: w * 0.9,
                    x: w * 0.15, y: h * 0.22,
                    blur: 60,
                    delay: 0.0,
                    driftX: 14, driftY: 10
                )

                // تركوازي أعلى اليمين
                glowCircle(
                    color: Color(red: 0.55, green: 0.80, blue: 0.78),
                    size: w * 0.7,
                    x: w * 0.95, y: h * 0.28,
                    blur: 70,
                    delay: 0.4,
                    driftX: -12, driftY: 14
                )

                // نعناعي وسط اليسار
                glowCircle(
                    color: Color(red: 0.75, green: 0.93, blue: 0.86),
                    size: w * 0.8,
                    x: w * 0.1, y: h * 0.62,
                    blur: 60,
                    delay: 0.8,
                    driftX: 10, driftY: -12
                )

                // أصفر فاتح أسفل اليمين
                glowCircle(
                    color: Color(red: 0.90, green: 0.95, blue: 0.70),
                    size: w * 0.8,
                    x: w * 0.9, y: h * 0.92,
                    blur: 60,
                    delay: 1.2,
                    driftX: -14, driftY: -8
                )
            }
        }
    }

    private func glowCircle(
        color: Color,
        size: CGFloat,
        x: CGFloat, y: CGFloat,
        blur: CGFloat,
        delay: Double,
        driftX: CGFloat, driftY: CGFloat
    ) -> some View {
        Circle()
            .fill(color)
            .frame(width: size)
            .scaleEffect(glow ? 1.0 : 0.6)
            .opacity(glow ? 1.0 : 0.0)
            .animation(.easeOut(duration: 1.8).delay(delay), value: glow)
            .offset(x: drift ? driftX : 0, y: drift ? driftY : 0)
            .position(x: x, y: y)
            .blur(radius: blur)
    }
}

private extension Color {
    static let welcomeBrown = Color(red: 0.36, green: 0.27, blue: 0.21)
}


#Preview {
    WelcomeView()
}
