import SwiftUI

// MARK: - الألوان
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

    static let brownText  = Color(hex: "61472F")
    static let sageIcon   = Color(hex: "91AFA3")
    static let sageButton = Color(hex: "B9CCC4")
    static let cardCream  = Color(hex: "FEFCF9")
}

// MARK: - نوع الخدمة (للتنقل)
enum ServiceType: Hashable {
    case water
    case furniture
    case electricity
    case appliances
}

// MARK: - موديل الخدمة
struct ServiceItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let type: ServiceType
}

// MARK: - صفحة الخدمات
struct ServicesView: View {

    // الترتيب في RTL: أول عنصر يكون يمين
    let services: [ServiceItem] = [
        ServiceItem(title: "مشاكل المياه",     icon: "drop",    type: .water),
        ServiceItem(title: "الأبواب والأثاث",  icon: "homekit", type: .furniture),
        ServiceItem(title: "مشاكل الكهرباء",   icon: "bolt",    type: .electricity),
        ServiceItem(title: "الأجهزة المنزلية", icon: "washer",  type: .appliances)
    ]

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.white, Color(hex: "EEF6F4")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("الخدمات")
                        .font(.system(size: 52, weight: .regular))
                        .foregroundColor(.brownText)
                        .padding(.top, 40)

                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(services) { service in
                            NavigationLink(value: service.type) {
                                ServiceCard(service: service)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationDestination(for: ServiceType.self) { type in
                switch type {
                case .water:
                    WaterProblemsView()
                case .furniture:
                    Text("الأبواب والأثاث")   // بدّلها بصفحتك لاحقًا
                case .electricity:
                    Text("مشاكل الكهرباء")    // بدّلها بصفحتك لاحقًا
                case .appliances:
                    DevicesView()
                }
            }
            .toolbar(.hidden)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - الكارد
struct ServiceCard: View {
    let service: ServiceItem

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: service.icon)
                .font(.system(size: 70, weight: .regular))
                .foregroundColor(.sageIcon)
                .frame(height: 90)

            Text(service.title)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.brownText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // صار شكل فقط لأن الكارد كله قابل للضغط
            Text("استكشف")
                .font(.system(size: 16))
                .foregroundColor(.brownText)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.sageButton))

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.6, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 45, style: .continuous)
                .fill(Color.cardCream)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
        )
        .contentShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
    }
}

#Preview {
    ServicesView()
}
