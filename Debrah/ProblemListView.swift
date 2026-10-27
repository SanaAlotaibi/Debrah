import SwiftUI

// MARK: - Problem List Screen

/// شاشة قائمة واحدة لكل الأقسام: مشاكل المياه، الأبواب والأثاث، الأجهزة المنزلية،
/// الغسالات، الثلاجات، وغيرها.
///
/// تعرض الأقسام الفرعية أولاً (مثل الأجهزة)، ثم المشكلات. محتوى الشاشة
/// يأتي بالكامل من ``ServiceCategory``، فلا تحتاج أي قسم جديد إلى شاشة جديدة.
struct ProblemListView: View {

    let category: ServiceCategory

    private var isEmpty: Bool {
        category.subcategories.isEmpty && category.problems.isEmpty
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            ScrollView {
                VStack(spacing: Theme.Spacing.xxl) {
                    ScreenTitle(category.title)
                        .padding(.top, Theme.Spacing.xl)

                    if isEmpty {
                        emptyState
                    } else {
                        rows
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: Subviews

    private var rows: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
            ForEach(category.subcategories) { subcategory in
                NavigationLink(value: Route.category(categoryID: subcategory.id)) {
                    ProblemRow(title: subcategory.title, imageName: subcategory.imageName)
                }
                .buttonStyle(.plain)
            }

            ForEach(category.problems) { problem in
                NavigationLink(value: Route.intro(problemID: problem.id)) {
                    ProblemRow(title: problem.title, imageName: problem.illustrationAsset)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        Text("لا توجد مشكلات في هذا القسم حالياً.")
            .typography(.body)
            .foregroundStyle(Theme.brown)
            .multilineTextAlignment(.center)
            .padding(Theme.Spacing.xl)
            .frame(maxWidth: .infinity)
            .cardSurface(cornerRadius: Theme.Radius.row, shadowOpacity: Theme.Shadow.card)
    }
}

// MARK: - Problem Row

/// صف في القائمة: الصورة، ثم خط فاصل، ثم العنوان. في RTL تظهر الصورة على اليمين.
struct ProblemRow: View {

    let title: String
    let imageName: String?

    @ScaledMetric(relativeTo: .body) private var imageSize: CGFloat = 64

    /// أقصى حجم للصورة حتى لا تطغى على النص مع الخطوط الكبيرة.
    private let maxImageSize: CGFloat = 88

    var body: some View {
        let size = min(imageSize, maxImageSize)

        HStack(spacing: Theme.Spacing.md) {
            ProblemIllustration(assetName: imageName ?? "")
                .frame(width: size, height: size)
                .accessibilityHidden(true)

            Rectangle()
                .fill(Theme.mintLabel)
                .frame(width: 1.5, height: size * 0.8)
                .accessibilityHidden(true)

            Text(title)
                .typography(.rowTitle)
                .foregroundStyle(Theme.brown)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .frame(maxWidth: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.row, shadowOpacity: Theme.Shadow.card)
        .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.row, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Previews

#Preview("Water") {
    NavigationStack {
        ProblemListView(category: DiagnosisData.water)
    }
    .appPreviewEnvironment()
}

#Preview("Home appliances") {
    NavigationStack {
        ProblemListView(category: DiagnosisData.homeAppliances)
    }
    .appPreviewEnvironment()
}

#Preview("Empty") {
    NavigationStack {
        ProblemListView(category: DiagnosisData.electricity)
    }
    .appPreviewEnvironment()
}
