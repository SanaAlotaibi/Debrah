import SwiftUI

// MARK: - Services Screen

/// الشاشة الرئيسية: بطاقات الخدمات الأربع في شبكة من عمودين.
struct ServicesView: View {

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.lg),
        GridItem(.flexible(), spacing: Theme.Spacing.lg)
    ]

    var body: some View {
        ZStack {
            ScreenBackground()

            ScrollView {
                VStack(spacing: Theme.Spacing.xxl) {
                    ScreenTitle("الخدمات")
                        .padding(.top, Theme.Spacing.xl)

                    // RTL: the first service sits on the right.
                    LazyVGrid(columns: columns, spacing: Theme.Spacing.xl) {
                        ForEach(DiagnosisData.services) { service in
                            NavigationLink(value: Route.category(categoryID: service.id)) {
                                ServiceCard(service: service)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Service Card

/// بطاقة خدمة: أيقونة، واسم الخدمة، ورقاقة «استكشف».
///
/// البطاقة كلها قابلة للضغط؛ «استكشف» شكل فقط.
struct ServiceCard: View {

    let service: ServiceCategory

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 52
    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 220

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: service.icon ?? "square.grid.2x2")
                .font(.system(size: iconSize, weight: .regular))
                .foregroundStyle(Theme.mintAction)
                .frame(height: iconSize * 1.3)
                .accessibilityHidden(true)

            Text(service.title)
                .typography(.cardTitle)
                .foregroundStyle(Theme.brown)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("استكشف")
                .typography(.caption)
                .foregroundStyle(Theme.brown)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.xs)
                .background(Theme.mintButton, in: Capsule())
                .accessibilityHidden(true)
        }
        .padding(.vertical, Theme.Spacing.xl)
        .padding(.horizontal, Theme.Spacing.md)
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .cardSurface(cornerRadius: Theme.Radius.tile, shadowOpacity: Theme.Shadow.raisedCard)
        .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Previews

#Preview("Services") {
    NavigationStack {
        ServicesView()
    }
    .appPreviewEnvironment()
}
