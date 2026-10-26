import SwiftUI

// MARK: - Model

struct DeviceProblem: Identifiable, Hashable {
    let id: Int
    let title: String
    let imageName: String

    static let all: [DeviceProblem] = [
        DeviceProblem(id: 1, title: "الغسالات",         imageName: "device_washer"),
        DeviceProblem(id: 2, title: "الثلاجات",         imageName: "device_fridge"),
        DeviceProblem(id: 3, title: "المكيفات",         imageName: "device_ac"),
        DeviceProblem(id: 4, title: "أفران الغاز",      imageName: "device_oven"),
        DeviceProblem(id: 5, title: "المكانس الكهربائية", imageName: "device_vacuum"),
        DeviceProblem(id: 6, title: "سخّانات المياه",   imageName: "water_heater")
    ]
}

// MARK: - Theme

private enum DevicesTheme {
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

struct DevicesView: View {

    var body: some View {
        ZStack {
            background

            // نفس ترتيب صفحة الخدمات: VStack(spacing: 30) بين العنوان والكروت
            VStack(spacing: 30) {
                Text("الأجهزة المنزلية")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(DevicesTheme.text)
                    .frame(maxWidth: .infinity)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        ForEach(DeviceProblem.all) { problem in
                            NavigationLink(value: problem) {
                                DeviceProblemCard(problem: problem)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationDestination(for: DeviceProblem.self) { problem in
            switch problem.id {
            case 1:
                WashersView()
            case 2:
                FridgesView()
            case 3:
                ACsView()
            case 4:
                GasOvensView()
            case 5:
                VacuumCleanersView()
            case 6:
                WaterHeatersView()
            default:
                DeviceProblemDetailView(problem: problem)
            }
        }
        .tint(DevicesTheme.mint)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var background: some View {
        LinearGradient(
            colors: [.white, .white, DevicesTheme.mintTint],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Card

struct DeviceProblemCard: View {
    let problem: DeviceProblem

    var body: some View {
        // في RTL أول عنصر يظهر على اليمين: الصورة ثم الخط ثم النص
        HStack(spacing: 14) {
            Image(problem.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)

            Rectangle()
                .fill(DevicesTheme.divider)
                .frame(width: 1.5, height: 62)

            Text(problem.title)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(DevicesTheme.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DevicesTheme.card)
                .shadow(color: DevicesTheme.shadow.opacity(0.22), radius: 7, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Detail Screen (placeholder)

struct DeviceProblemDetailView: View {
    let problem: DeviceProblem

    var body: some View {
        ZStack {
            DevicesTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(problem.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Text(problem.title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(DevicesTheme.text)
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
        DevicesView()
    }
}
