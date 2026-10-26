import SwiftUI

// MARK: - Model

struct FridgeProblem: Identifiable, Hashable {
    let id: Int
    let title: String
    let imageName: String

    static let all: [FridgeProblem] = [
        FridgeProblem(id: 1, title: "الثلاجة لا تبرد جيدًا",       imageName: "fridge_not_cooling"),
        FridgeProblem(id: 2, title: "باب الثلاجة لا يغلق بإحكام",  imageName: "fridge_door_seal"),
        FridgeProblem(id: 3, title: "وجود قطرات ماء داخل الثلاجة", imageName: "fridge_water_drops")
    ]
}

// MARK: - Theme

private enum FridgeTheme {
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

struct FridgesView: View {

    var body: some View {
        ZStack {
            background

            VStack(spacing: 30) {
                Text("الثلاجات")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(FridgeTheme.text)
                    .frame(maxWidth: .infinity)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        ForEach(FridgeProblem.all) { problem in
                            NavigationLink(value: problem) {
                                FridgeProblemCard(problem: problem)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .navigationDestination(for: FridgeProblem.self) { problem in
            FridgeProblemDetailView(problem: problem)
        }
        .tint(FridgeTheme.mint)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var background: some View {
        LinearGradient(
            colors: [.white, .white, FridgeTheme.mintTint],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Card

struct FridgeProblemCard: View {
    let problem: FridgeProblem

    var body: some View {
        // في RTL أول عنصر يظهر على اليمين: الصورة ثم الخط ثم النص ثم السهم
        HStack(spacing: 18) {
            Image(problem.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Rectangle()
                .fill(FridgeTheme.divider)
                .frame(width: 1.5, height: 80)

            Text(problem.title)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(FridgeTheme.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)

            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FridgeTheme.mint)
        }
        .padding(.horizontal, 18)
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(FridgeTheme.card)
                .shadow(color: FridgeTheme.shadow.opacity(0.22), radius: 7, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

// MARK: - Detail Screen (placeholder)

struct FridgeProblemDetailView: View {
    let problem: FridgeProblem

    var body: some View {
        ZStack {
            FridgeTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(problem.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Text(problem.title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(FridgeTheme.text)
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
        FridgesView()
    }
}
