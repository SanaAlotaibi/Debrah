import SwiftUI

// MARK: - Introduction Screen

/// شاشة المقدمة التي تظهر بعد اختيار المشكلة.
///
/// تعرض عنوان المشكلة، وبطاقة فيها الرسمة والوصف،
/// وزر «ابدأ التشخيص» الذي ينقل إلى ``DiagnosisFlowView``.
struct DiagnosisIntroductionView: View {

    // MARK: Properties

    /// المشكلة المختارة.
    let problem: DiagnosisProblem

    /// ارتفاع الرسمة داخل البطاقة.
    private let illustrationHeight: CGFloat = 160

    // MARK: Body

    var body: some View {
        ZStack {
            ScreenBackground()

            GeometryReader { proxy in
                // Scrolls only when the content is taller than the screen
                // (for example at the largest Dynamic Type sizes).
                ScrollView {
                    VStack(spacing: 0) {
                        ScreenTitle(problem.title)
                            .padding(.top, Theme.Spacing.xxl)

                        Spacer(minLength: Theme.Spacing.xxl)

                        // Card and button centered in the space below the title.
                        VStack(spacing: Theme.Spacing.xxxl) {
                            descriptionCard
                            startButton
                        }

                        Spacer(minLength: Theme.Spacing.xxl)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: Subviews

    /// بطاقة الرسمة والوصف.
    private var descriptionCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProblemIllustration(assetName: problem.illustrationAsset)
                .frame(maxWidth: .infinity)
                .frame(height: illustrationHeight)
                .accessibilityHidden(true)

            if !problem.description.isEmpty {
                Text(problem.description)
                    .typography(.body)
                    .foregroundStyle(Theme.brown)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.vertical, Theme.Spacing.xxl)
        .frame(maxWidth: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.largeCard, shadowOpacity: Theme.Shadow.card)
    }

    /// زر «ابدأ التشخيص»، بعرض يتناسب مع عرض البطاقة.
    private var startButton: some View {
        NavigationLink(value: startRoute) {
            Text("ابدأ التشخيص")
        }
        .buttonStyle(MintButtonStyle())
        .containerRelativeFrame(.horizontal) { length, _ in
            min(length * 0.65, 280)
        }
    }

    // MARK: Navigation

    /// المشكلة التي ليس لها أسئلة تنتقل مباشرة إلى الحل.
    private var startRoute: Route {
        problem.questions.isEmpty
            ? .solution(problemID: problem.id)
            : .diagnosis(problemID: problem.id)
    }
}

// MARK: - Diagnosis Flow Screen

/// شاشة الأسئلة: تعرض سؤالاً واحداً في كل مرة على بطاقات متراكبة.
///
/// - «نعم» تحرّك البطاقة يميناً، و«لا» يساراً.
/// - التقييم نفسه يتم في ``DiagnosisResultEvaluator``؛ هذه الشاشة تعرض النتيجة فقط.
/// - النتيجة تظهر دائماً بعد انتهاء حركة البطاقة الحالية.
struct DiagnosisFlowView: View {

    // MARK: Properties

    @Environment(Router.self) private var router

    /// المشكلة التي تُعرض أسئلتها.
    let problem: DiagnosisProblem

    /// الأسئلة والإجابات والسؤال الحالي.
    @State private var session: DiagnosisSession

    /// الانتظار الجاري حتى تنتهي حركة البطاقة. وجوده يمنع الضغط المتكرر.
    @State private var pendingTransition: Task<Void, Never>?

    /// يتحكم في ظهور نافذة التنبيه.
    @State private var isShowingWarning = false

    /// مدة حركة خروج البطاقة قبل عرض النتيجة.
    private static let cardExitDuration: Duration = .milliseconds(450)

    /// أقصى ارتفاع لكومة البطاقات على الشاشات الكبيرة.
    private static let maxStackHeight: CGFloat = 470

    // MARK: Initialization

    /// - Parameters:
    ///   - problem: المشكلة المختارة.
    ///   - policy: قاعدة التقييم. الافتراضية قاعدة الأغلبية.
    init(problem: DiagnosisProblem, policy: DiagnosisEvaluationPolicy = .majority) {
        self.problem = problem
        _session = State(initialValue: DiagnosisSession(questions: problem.questions, policy: policy))
    }

    // MARK: Computed Properties

    /// الأزرار تعمل فقط عند وجود سؤال، وعدم وجود حركة أو تنبيه.
    private var canAnswer: Bool {
        pendingTransition == nil && !isShowingWarning && session.currentQuestion != nil
    }

    // MARK: Body

    var body: some View {
        ZStack {
            content
                .blur(radius: isShowingWarning ? 8 : 0)
                .overlay {
                    Color.black
                        .opacity(isShowingWarning ? 0.08 : 0)
                        .ignoresSafeArea()
                }
                .allowsHitTesting(!isShowingWarning)
                .accessibilityHidden(isShowingWarning)

            if isShowingWarning {
                DiagnosisWarningView(
                    onGoToSolution: goToSolution,
                    onReturnToServices: { router.popToRoot() }
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(Theme.modalSpring, value: isShowingWarning)
        .sensoryFeedback(.selection, trigger: session.answers.count)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            // A problem without questions has nothing to ask.
            if session.questions.isEmpty {
                handle(session.result)
            }
        }
        .onDisappear {
            // Leaving mid-animation must not trigger a late navigation.
            pendingTransition?.cancel()
            pendingTransition = nil
        }
    }

    // MARK: Subviews

    /// العنوان في الأعلى، والبطاقات مع الأزرار كمجموعة واحدة في منتصف المساحة المتبقية.
    private var content: some View {
        ZStack {
            ScreenBackground()

            VStack(spacing: 0) {
                ScreenTitle(problem.title)
                    .padding(.top, Theme.Spacing.xl)
                    .padding(.horizontal, Theme.Spacing.lg)

                Spacer(minLength: Theme.Spacing.xl)

                VStack(spacing: Theme.Spacing.xxl) {
                    DiagnosisCardStack(
                        questions: session.questions,
                        currentIndex: session.currentIndex,
                        answers: session.answers
                    )
                    .frame(maxHeight: Self.maxStackHeight)
                    .layoutPriority(1)

                    answerButtons
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .layoutPriority(1)

                Spacer(minLength: Theme.Spacing.xl)
            }
        }
    }

    /// زرّا «نعم» و«لا». في RTL يظهر الزر الأول («نعم») على اليمين.
    private var answerButtons: some View {
        HStack(spacing: Theme.Spacing.huge) {
            DiagnosisAnswerButton(answer: .yes) { submit(true) }
            DiagnosisAnswerButton(answer: .no) { submit(false) }
        }
        // Not disabled during the card animation, so the buttons don't flicker;
        // `submit(_:)` ignores taps while a card is moving.
        .disabled(session.currentQuestion == nil || isShowingWarning)
    }

    // MARK: Actions

    /// يسجّل الإجابة، ثم يعرض النتيجة بعد انتهاء حركة البطاقة.
    ///
    /// - Parameter answer: `true` عند «نعم»، و`false` عند «لا».
    private func submit(_ answer: Bool) {
        guard canAnswer,
              let result = session.answerCurrentQuestion(answer) else { return }

        pendingTransition = Task { @MainActor in
            do {
                try await Task.sleep(for: Self.cardExitDuration)
            } catch {
                return // Cancelled: the screen was left.
            }
            pendingTransition = nil
            handle(result)
        }
    }

    /// ينفّذ ما تتطلبه النتيجة.
    ///
    /// عدم المطابقة وسؤال السلامة يعرضان نفس التنبيه؛ الفرق بينهما فقط في توقيت التقييم.
    private func handle(_ result: DiagnosisResult) {
        switch result {
        case .inProgress:
            break
        case .matches:
            goToSolution()
        case .mismatch, .unsafe:
            guard !isShowingWarning else { return }
            isShowingWarning = true
        }
    }

    /// يستبدل شاشة التشخيص بشاشة الحل، فلا يعود زر الرجوع إلى الأسئلة.
    private func goToSolution() {
        router.replaceCurrent(with: .solution(problemID: problem.id))
    }
}

// MARK: - Question Card

/// بطاقة سؤال واحدة: كلمة «التشخيص» في الأعلى، والسؤال في المنتصف.
struct DiagnosisCardView: View {

    /// السؤال المعروض في البطاقة.
    let question: DiagnosisQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // `.leading` maps to the right edge in RTL.
            Text("التشخيص")
                .typography(.eyebrow)
                .foregroundStyle(Theme.mintLabel)

            // Centered when it fits; scrolls inside the card when it is too long,
            // so the font is never shrunk.
            ViewThatFits(in: .vertical) {
                questionText
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                ScrollView {
                    questionText
                        .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardSurface(cornerRadius: Theme.Radius.card, shadowOpacity: Theme.Shadow.raisedCard)
        .accessibilityElement(children: .combine)
    }

    private var questionText: some View {
        Text(question.text)
            .typography(.question)
            .foregroundStyle(Theme.brown)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Card Stack

/// كومة بطاقات الأسئلة المتراكبة.
///
/// جميع البطاقات موجودة دائماً، ويُحسب شكل كل بطاقة من عمقها
/// (`index - currentIndex`):
/// - **عمق سالب**: بطاقة أُجيب عنها وتخرج من الشاشة.
/// - **عمق 0**: البطاقة الحالية في الأمام.
/// - **عمق حتى `visibleDepth`**: بطاقات ظاهرة في الخلف بحجم أصغر.
/// - **أعمق من ذلك**: بطاقات مخفية.
///
/// تغيير `currentIndex` يحرّك الإزاحة والحجم والشفافية والترتيب معاً،
/// مهما كان عدد الأسئلة.
struct DiagnosisCardStack: View {

    // MARK: Properties

    let questions: [DiagnosisQuestion]
    let currentIndex: Int
    let answers: [String: Bool]

    /// عدد البطاقات الظاهرة خلف البطاقة الحالية.
    private let visibleDepth = 2

    /// المسافة العمودية بين كل بطاقة والتي خلفها.
    private let peek: CGFloat = 10

    /// مقدار التصغير لكل مستوى عمق.
    private let scaleStep: CGFloat = 0.03

    /// نسبة عرض البطاقة من المساحة المتاحة.
    private let widthFraction: CGFloat = 0.86

    /// أقصى عرض للبطاقة.
    private let maxCardWidth: CGFloat = 340

    /// نسبة الارتفاع إلى العرض.
    private let heightToWidthRatio: CGFloat = 1.17

    // MARK: Body

    var body: some View {
        GeometryReader { proxy in
            let reserved = peek * CGFloat(visibleDepth)
            let width = min(proxy.size.width * widthFraction, maxCardWidth)
            let height = max(0, min(width * heightToWidthRatio, proxy.size.height - reserved))

            ZStack(alignment: .top) {
                ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                    card(for: question, index: index, width: width, height: height)
                }
            }
            .frame(width: width, height: height + reserved, alignment: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: Helpers

    /// ينشئ بطاقة واحدة ويضبط موضعها وشكلها حسب عمقها في الكومة.
    ///
    /// - Parameters:
    ///   - question: السؤال المعروض.
    ///   - index: ترتيب السؤال في القائمة.
    ///   - width: عرض البطاقة.
    ///   - height: ارتفاع البطاقة.
    /// - Returns: البطاقة بعد تطبيق الحركة والشكل المناسبين.
    private func card(
        for question: DiagnosisQuestion,
        index: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let depth = index - currentIndex
        let hasLeft = depth < 0
        let isHidden = depth > visibleDepth
        let stackedDepth = CGFloat(max(depth, 0))

        // "Yes" exits to the right (toward the check button), "No" to the left.
        let direction: CGFloat = (answers[question.id] ?? true) ? 1 : -1

        return DiagnosisCardView(question: question)
            .frame(width: width, height: height)
            .scaleEffect(hasLeft ? 0.96 : 1 - scaleStep * stackedDepth, anchor: .bottom)
            .rotationEffect(.degrees(hasLeft ? Double(direction) * 10 : 0))
            .offset(
                x: hasLeft ? direction * width * 1.3 : 0,
                y: hasLeft ? 0 : peek * stackedDepth
            )
            .opacity(hasLeft || isHidden ? 0 : 1)
            .zIndex(Double(questions.count - depth))
            .animation(Theme.cardSpring, value: currentIndex)
            .allowsHitTesting(false)
            .accessibilityHidden(depth != 0)
    }
}

// MARK: - Answer Button

/// زر دائري لإجابة «نعم» أو «لا» أسفل البطاقات.
struct DiagnosisAnswerButton: View {

    // MARK: Answer

    /// نوع الإجابة، ويحدد الأيقونة واللون ووصف إمكانية الوصول.
    enum Answer {
        case yes
        case no

        var symbol: String {
            switch self {
            case .yes: "checkmark"
            case .no: "xmark"
            }
        }

        var tint: Color {
            switch self {
            case .yes: Theme.mintAction
            case .no: Theme.danger
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .yes: "نعم"
            case .no: "لا"
            }
        }
    }

    // MARK: Properties

    let answer: Answer
    let action: () -> Void

    /// قطر الزر، ويكبر مع Dynamic Type.
    @ScaledMetric(relativeTo: .title2) private var diameter: CGFloat = 60

    /// أقصى قطر حتى لا يطغى الزر على البطاقات مع الخطوط الكبيرة جداً.
    private let maxDiameter: CGFloat = 76

    // MARK: Body

    var body: some View {
        let size = min(diameter, maxDiameter)

        Button(action: action) {
            Image(systemName: answer.symbol)
                .font(.system(size: size * 0.36, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(answer.tint, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                .contentShape(Circle())
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(answer.accessibilityLabel)
    }
}

// MARK: - Press Style

/// يصغّر الزر قليلاً عند الضغط، ويخفّته عند تعطيله.
private struct PressScaleButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Warning View

/// نافذة «تنبيه!» العائمة فوق شاشة الأسئلة.
///
/// نافذة واحدة موحّدة لعدم المطابقة ولأسئلة السلامة، وتعرض الزرين دائماً.
/// نافذة مخصصة بدلاً من `Alert` النظام لتطابق تصميم التطبيق.
struct DiagnosisWarningView: View {

    // MARK: Properties

    /// يُستدعى عند الضغط على «الذهاب إلى الحل».
    let onGoToSolution: () -> Void

    /// يُستدعى عند الضغط على «العودة إلى قائمة الخدمات».
    let onReturnToServices: () -> Void

    // MARK: Body

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Text("تنبيه!")
                .typography(.alertTitle)
                .foregroundStyle(Theme.mintLabel)
                .accessibilityAddTraits(.isHeader)

            Text("قد يكون حل المشكلة التي اخترتها لا يناسب المشكلة التي تواجهها.")
                .typography(.alertBody)
                .foregroundStyle(Theme.brown)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Side by side by default; stacked at large Dynamic Type sizes.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.Spacing.sm) { actions }
                VStack(spacing: Theme.Spacing.sm) { actions }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.xxl)
        .frame(maxWidth: 380)
        .cardSurface(cornerRadius: Theme.Radius.card, shadowOpacity: Theme.Shadow.overlay)
        .padding(.horizontal, Theme.Spacing.xxl)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    // MARK: Subviews

    /// أزرار التنبيه. في RTL يظهر الزر الأول على اليمين.
    @ViewBuilder
    private var actions: some View {
        Button("الذهاب إلى الحل", action: onGoToSolution)
            .buttonStyle(MintButtonStyle())

        Button("العودة إلى قائمة الخدمات", action: onReturnToServices)
            .buttonStyle(MintButtonStyle())
    }
}

// MARK: - Preview Data

/// بيانات تجريبية للمعاينات فقط. لا تُستخدم في التطبيق ولا تغيّر بيانات المشكلات.
extension DiagnosisProblem {

    /// مشكلة بستة أسئلة لاختبار الكومة مع عدد مختلف من البطاقات.
    static let previewSixQuestions = DiagnosisProblem(
        id: "preview-six-questions",
        title: "معاينة: ستة أسئلة",
        description: DiagnosisData.looseDrawer.description,
        illustrationAsset: DiagnosisData.looseDrawer.illustrationAsset,
        questions: (1...6).map { number in
            DiagnosisQuestion(
                id: "preview-six-q\(number)",
                text: "سؤال معاينة رقم \(number)",
                expectedAnswer: true
            )
        },
        solutionSteps: []
    )

    /// مشكلة أول أسئلتها سؤال سلامة حرج؛ الإجابة بـ «لا» توقف التشخيص فوراً.
    static let previewSafetyCritical = DiagnosisProblem(
        id: "preview-safety",
        title: "معاينة: سؤال سلامة",
        description: DiagnosisData.looseDrawer.description,
        illustrationAsset: DiagnosisData.looseDrawer.illustrationAsset,
        questions: [
            DiagnosisQuestion(
                id: "preview-safety-q1",
                text: "هل الكهرباء مفصولة عن الجهاز؟",
                expectedAnswer: true,
                isSafetyCritical: true
            ),
            DiagnosisQuestion(
                id: "preview-safety-q2",
                text: "سؤال معاينة ثانٍ",
                expectedAnswer: true
            )
        ],
        solutionSteps: []
    )
}

// MARK: - Previews

#Preview("Introduction") {
    NavigationStack {
        DiagnosisIntroductionView(problem: DiagnosisData.looseDrawer)
    }
    .appPreviewEnvironment()
}

#Preview("Introduction — Large Text") {
    NavigationStack {
        DiagnosisIntroductionView(problem: DiagnosisData.looseDrawer)
    }
    .appPreviewEnvironment()
    .dynamicTypeSize(.accessibility2)
}

#Preview("Cards — 3 questions") {
    NavigationStack {
        DiagnosisFlowView(problem: DiagnosisData.looseDrawer)
    }
    .appPreviewEnvironment()
}

#Preview("Cards — 6 questions") {
    NavigationStack {
        DiagnosisFlowView(problem: .previewSixQuestions)
    }
    .appPreviewEnvironment()
}

#Preview("Cards — Safety critical") {
    NavigationStack {
        DiagnosisFlowView(problem: .previewSafetyCritical)
    }
    .appPreviewEnvironment()
}

#Preview("Cards — Small screen, large text") {
    NavigationStack {
        DiagnosisFlowView(problem: DiagnosisData.looseDrawer)
    }
    .appPreviewEnvironment()
    .dynamicTypeSize(.xxxLarge)
}

#Preview("Question card") {
    DiagnosisCardView(question: DiagnosisData.looseDrawer.questions[0])
        .frame(width: 300, height: 350)
        .padding()
        .appPreviewEnvironment()
}

#Preview("Question card — Long text") {
    DiagnosisCardView(
        question: DiagnosisQuestion(
            id: "preview-long",
            text: String(repeating: "هل يميل الدرج إلى الأسفل عند فتحه بالكامل ويحتك بالإطار؟ ", count: 6),
            expectedAnswer: true
        )
    )
    .frame(width: 300, height: 350)
    .padding()
    .appPreviewEnvironment()
}

#Preview("Answer buttons") {
    HStack(spacing: Theme.Spacing.huge) {
        DiagnosisAnswerButton(answer: .yes) {}
        DiagnosisAnswerButton(answer: .no) {}
    }
    .padding()
    .appPreviewEnvironment()
}

#Preview("Warning") {
    ZStack {
        ScreenBackground()
        DiagnosisWarningView(onGoToSolution: {}, onReturnToServices: {})
    }
    .appPreviewEnvironment()
}

#Preview("Warning — Large Text") {
    ZStack {
        ScreenBackground()
        DiagnosisWarningView(onGoToSolution: {}, onReturnToServices: {})
    }
    .appPreviewEnvironment()
    .dynamicTypeSize(.accessibility1)
}
