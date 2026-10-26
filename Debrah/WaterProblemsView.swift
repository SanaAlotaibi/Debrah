import SwiftUI

// MARK: - Model

struct WaterProblem: Identifiable, Hashable {
    let id: Int
    let title: String
    let imageName: String

    static let all: [WaterProblem] = [
        WaterProblem(id: 1, title: "تسرّب الصنبور",                  imageName: "water_faucet_leak"),
        WaterProblem(id: 2, title: "انسداد المغسلة",                 imageName: "water_sink_slow_drain"),
        WaterProblem(id: 3, title: "ضعف تدفق رأس الدش",              imageName: "water_low_pressure"),
        WaterProblem(id: 4, title: "استمرار تدفق المياه في المرحاض", imageName: "water_toilet_running"),
        WaterProblem(id: 5, title: "تسريب وصلة رأس الدش",            imageName: "water_shower_clog")
    ]
}

// MARK: - Theme

private enum Theme {
    static let brown      = Color(red: 0.40, green: 0.29, blue: 0.20)
    static let mint       = Color(red: 0.52, green: 0.70, blue: 0.63)
    static let card       = Color(red: 1.0,  green: 0.99, blue: 0.98)
    static let mintTint   = Color(red: 0.91, green: 0.97, blue: 0.94)
    static let shadow     = Color(red: 0.25, green: 0.36, blue: 0.31)

    static let text       = brown
    static let divider    = mint
    static let background = Color.white
}

// MARK: - List Screen

struct WaterProblemsView: View {

    var body: some View {
        ZStack {
            background

            // نفس ترتيب صفحة الخدمات: VStack(spacing: 30) بين العنوان والكروت
            VStack(spacing: 30) {
                Text("مشاكل المياه")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        ForEach(WaterProblem.all) { problem in
                            NavigationLink(value: problem) {
                                WaterProblemCard(problem: problem)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationDestination(for: WaterProblem.self) { problem in
            WaterProblemDetailView(problem: problem)
        }
        .tint(Theme.mint)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var background: some View {
        LinearGradient(
            colors: [.white, .white, Theme.mintTint],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Card

struct WaterProblemCard: View {
    let problem: WaterProblem

    var body: some View {
        // في RTL أول عنصر يظهر على اليمين: الصورة ثم الخط ثم النص
        HStack(spacing: 14) {
            Image(problem.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)

            Rectangle()
                .fill(Theme.divider)
                .frame(width: 1.5, height: 62)

            Text(problem.title)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(Theme.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.card)
                .shadow(color: Theme.shadow.opacity(0.22), radius: 7, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Detail Screen (placeholder)

struct WaterProblemDetailView: View {
    let problem: WaterProblem

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(problem.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Text(problem.title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle(problem.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    NavigationStack {
        WaterProblemsView()
    }
}
