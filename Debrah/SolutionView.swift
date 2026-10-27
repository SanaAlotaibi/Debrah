import SwiftUI

// MARK: - Solution Screen

/// خطوات حل المشكلة، خطوة في كل بطاقة، ثم بطاقة «تم الإصلاح!».
///
/// الخطوات تأتي من ``DiagnosisProblem/solutionSteps``. يمكن التنقل بالسحب
/// أو بزرّي «التالي» و«رجوع».
struct SolutionView: View {

    // MARK: Properties

    @Environment(Router.self) private var router

    /// المشكلة التي تُعرض خطوات حلها.
    let problem: DiagnosisProblem

    /// رقم الخطوة المعروضة (من 0).
    @State private var currentStep = 0

    /// يكون `true` بعد آخر خطوة، فتظهر بطاقة «تم الإصلاح!».
    @State private var isFinished = false

    private var steps: [SolutionStep] { problem.solutionSteps }
    private var isLastStep: Bool { currentStep >= steps.count - 1 }

    // MARK: Body

    var body: some View {
        ZStack {
            ScreenBackground()

            VStack(spacing: Theme.Spacing.xl) {
                ScreenTitle("الحل")
                    .padding(.top, Theme.Spacing.xl)

                if steps.isEmpty {
                    pendingContent
                } else if isFinished {
                    SolutionDoneView(onFinish: { router.popToRoot() })
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.xl)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    stepsContent
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut, value: isFinished)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: Subviews

    /// بطاقات الخطوات وأزرار التنقل.
    private var stepsContent: some View {
        VStack(spacing: Theme.Spacing.xl) {
            TabView(selection: $currentStep) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    SolutionStepCard(step: step, stepIndex: index, totalSteps: steps.count)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.md)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)

            // RTL: the first button ("التالي") sits on the right.
            HStack(spacing: Theme.Spacing.sm) {
                Button(isLastStep ? "إنهاء" : "التالي", action: goForward)
                    .buttonStyle(MintButtonStyle())

                if currentStep > 0 {
                    Button("رجوع", action: goBack)
                        .buttonStyle(MintOutlineButtonStyle())
                }
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.bottom, Theme.Spacing.xl)
        }
    }

    /// تظهر عندما لا تكون خطوات الحل مكتوبة بعد.
    private var pendingContent: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Text("خطوات حل هذه المشكلة قيد الإعداد.")
                .typography(.body)
                .foregroundStyle(Theme.brown)
                .multilineTextAlignment(.center)
                .padding(Theme.Spacing.xl)
                .frame(maxWidth: .infinity)
                .cardSurface(cornerRadius: Theme.Radius.card, shadowOpacity: Theme.Shadow.card)

            Button("العودة إلى قائمة الخدمات") { router.popToRoot() }
                .buttonStyle(MintButtonStyle())
                .padding(.horizontal, Theme.Spacing.xxl)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    // MARK: Actions

    private func goForward() {
        if isLastStep {
            isFinished = true
        } else {
            withAnimation { currentStep += 1 }
        }
    }

    private func goBack() {
        guard currentStep > 0 else { return }
        withAnimation { currentStep -= 1 }
    }
}

// MARK: - Step Card

/// بطاقة خطوة واحدة: رقم الخطوة، والنص، والصورة، والملاحظة، ومؤشر الصفحات.
struct SolutionStepCard: View {

    let step: SolutionStep
    let stepIndex: Int
    let totalSteps: Int

    @ScaledMetric(relativeTo: .body) private var imageHeight: CGFloat = 140

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Text("الخطوة \(step.order)")
                .typography(.eyebrow)
                .foregroundStyle(Theme.mintLabel)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    if let title = step.title {
                        Text(title)
                            .typography(.cardTitle)
                            .foregroundStyle(Theme.brown)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(step.text)
                        .typography(.question)
                        .foregroundStyle(Theme.brown)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    stepImage

                    if let warning = step.warning {
                        Text(warning)
                            .typography(.caption)
                            .foregroundStyle(Theme.brown)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)

            PageIndicator(current: stepIndex, total: totalSteps)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.largeCard, shadowOpacity: Theme.Shadow.raisedCard)
    }

    /// صورة الخطوة، أو مكان فارغ بأيقونة إذا لم تُضف بعد.
    private var stepImage: some View {
        Group {
            if let name = step.illustrationAsset {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Theme.mintButton.opacity(0.35))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(Theme.mintLabel)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: min(imageHeight, 200))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.image, style: .continuous))
        .accessibilityHidden(true)
    }
}

// MARK: - Page Indicator

/// مؤشر الخطوات: نقاط داخل كبسولة نعناعية.
struct PageIndicator: View {

    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.white : Color.white.opacity(0.55))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.mintButton, in: Capsule())
        .animation(.easeInOut, value: current)
        .accessibilityElement()
        .accessibilityLabel("الخطوة \(current + 1) من \(total)")
    }
}

// MARK: - Done Card

/// علامة الصح: خط سميك بأطراف دائرية.
private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        return path
    }
}

/// بطاقة «تم الإصلاح!» مع زر العودة إلى قائمة الخدمات.
struct SolutionDoneView: View {

    var lines: [String] = [
        "لقد انتهيت من خطوات الإصلاح",
        "تأكد من عمل الإصلاح بشكل جيد"
    ]

    /// يُستدعى عند الضغط على زر العودة.
    let onFinish: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var checkSize: CGFloat = 120

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            card

            Button("العودة إلى قائمة الخدمات", action: onFinish)
                .buttonStyle(MintButtonStyle())
                .padding(.horizontal, Theme.Spacing.xxl)
        }
    }

    private var card: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer(minLength: 0)

            CheckmarkShape()
                .stroke(
                    Theme.mintAction,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
                )
                .frame(width: min(checkSize, 150), height: min(checkSize, 150) * 0.94)
                .accessibilityHidden(true)

            Text("تم الإصلاح !")
                .typography(.displayTitle)
                .foregroundStyle(Theme.brown)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: Theme.Spacing.md) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .typography(.body)
                        .foregroundStyle(Theme.brown)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.largeCard, shadowOpacity: Theme.Shadow.raisedCard)
    }
}

// MARK: - Previews

#Preview("Solution — Steps") {
    NavigationStack {
        SolutionView(problem: DiagnosisData.looseDrawer)
    }
    .appPreviewEnvironment()
}

#Preview("Solution — Pending") {
    NavigationStack {
        SolutionView(problem: DiagnosisData.water.problems[0])
    }
    .appPreviewEnvironment()
}

#Preview("Solution — Done") {
    ZStack {
        ScreenBackground()
        SolutionDoneView(onFinish: {})
            .padding(Theme.Spacing.lg)
    }
    .appPreviewEnvironment()
}
