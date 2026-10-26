import SwiftUI

struct ServiceItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String   // اسم أيقونة SF Symbols
}

struct ServicesView: View {
    private let services: [ServiceItem] = [
        ServiceItem(title: "مشاكل المياه",     icon: "drop"),
        ServiceItem(title: "الأبواب والأثاث",  icon: "house"),
        ServiceItem(title: "مشاكل الكهرباء",   icon: "bolt"),
        ServiceItem(title: "الأجهزة المنزلية", icon: "dishwasher")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.white, Color(red: 0.93, green: 0.97, blue: 0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 80) {
                Text("الخدمات")
                    .font(.system(size: 45, weight: .regular, design: .serif))
                    .foregroundStyle(Color.servicesBrown)
                    .padding(.top, 40)

                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(services) { service in
                        ServiceCard(service: service)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct ServiceCard: View {
    let service: ServiceItem
    var onExplore: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: service.icon)
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(Color.servicesSage)
                .frame(height: 70)

            Text(service.title)
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(Color.servicesBrown)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Button(action: onExplore) {
                Text("استكشف")
                    .font(.system(size: 11, design: .serif))
                    .foregroundStyle(Color.servicesBrown)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.servicesPill))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.servicesCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 6, x: 0, y: 6)
    }
}

private extension Color {
    static let servicesBrown = Color(red: 0.36, green: 0.27, blue: 0.21)
    static let servicesSage  = Color(red: 0.58, green: 0.71, blue: 0.64)
    static let servicesPill  = Color(red: 0.72, green: 0.80, blue: 0.75)
    static let servicesCard  = Color(red: 1.00, green: 0.98, blue: 0.96)
}

#Preview {
    ServicesView()
}
