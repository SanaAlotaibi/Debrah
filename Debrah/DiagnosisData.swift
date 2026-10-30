import Foundation

// MARK: - Diagnosis Question

/// سؤال تشخيص واحد يُعرض على بطاقة.
struct DiagnosisQuestion: Identifiable, Hashable {

    /// معرّف فريد للسؤال، وتُحفظ الإجابة به.
    let id: String

    /// نص السؤال المعروض على البطاقة.
    let text: String

    /// الإجابة التي تدل على أن المشكلة المختارة هي المشكلة الفعلية.
    ///
    /// قاعدة Debrah: جميع أسئلة التشخيص تُصاغ بحيث تكون «نعم» هي التأكيد،
    /// لذلك تكون القيمة دائماً `true` («نعم» = مطابق، «لا» = غير مطابق).
    ///
    /// - Note: إذا كانت `nil` فالسؤال معلوماتي فقط ولا يدخل في التقييم.
    let expectedAnswer: Bool?

    /// سؤال سلامة: الإجابة بـ «لا» توقف التشخيص فوراً وتُظهر التنبيه،
    /// دون انتظار بقية الأسئلة. يُصاغ بحيث تكون «نعم» هي الحالة الآمنة.
    var isSafetyCritical: Bool = false
}

// MARK: - Solution Step

/// خطوة واحدة من خطوات الحل.
struct SolutionStep: Identifiable, Hashable {

    /// ترتيب الخطوة، ويظهر كـ «الخطوة ١».
    let order: Int

    /// عنوان قصير للخطوة (مثل: «فصل الكهرباء»)، أو `nil`.
    var title: String? = nil

    /// نص الخطوة.
    let text: String

    /// صورة توضيحية واحدة للخطوة، أو `nil`.
    var illustrationAsset: String? = nil

    /// صور إضافية للخطوة (لخطوة فيها أكثر من صورة).
    var illustrationAssets: [String] = []

    /// ملاحظة تحذيرية تظهر أسفل الخطوة، أو `nil`.
    var warning: String? = nil

    var id: Int { order }

    /// كل صور الخطوة مجتمعة. إذا كانت فارغة فلا تظهر منطقة الصور أصلاً.
    var allIllustrations: [String] {
        var list = illustrationAssets
        if let single = illustrationAsset {
            list.insert(single, at: 0)
        }
        return list
    }

    init(
        order: Int,
        title: String? = nil,
        text: String,
        illustrationAsset: String? = nil,
        illustrationAssets: [String] = [],
        warning: String? = nil
    ) {
        self.order = order
        self.title = title
        self.text = text
        self.illustrationAsset = illustrationAsset
        self.illustrationAssets = illustrationAssets
        self.warning = warning
    }
}

// MARK: - Diagnosis Problem

/// مشكلة قابلة للتشخيص، مع أسئلتها وخطوات حلها.
struct DiagnosisProblem: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let illustrationAsset: String
    let questions: [DiagnosisQuestion]
    let solutionSteps: [SolutionStep]
}

extension DiagnosisProblem {

    /// مشكلة لم يُكتب محتواها بعد: عنوان وصورة فقط.
    ///
    /// تظهر في القائمة، وتفتح شاشة المقدمة، وتعرض شاشة الحل رسالة «قيد الإعداد».
    static func pending(id: String, title: String, image: String) -> DiagnosisProblem {
        DiagnosisProblem(
            id: id,
            title: title,
            description: "",
            illustrationAsset: image,
            questions: [],
            solutionSteps: []
        )
    }
}

// MARK: - Service Category

/// خدمة أو قسم يُعرض كقائمة.
///
/// يحتوي إما على أقسام فرعية (مثل: الأجهزة المنزلية ← الثلاجات)،
/// أو على مشكلات مباشرة (مثل: مشاكل المياه)، أو على الاثنين.
struct ServiceCategory: Identifiable, Hashable {
    let id: String
    let title: String

    /// رمز SF Symbol يظهر في بطاقة الخدمة بالشاشة الرئيسية.
    var icon: String? = nil

    /// صورة من Assets تظهر عندما يُعرض القسم كصف في قائمة.
    var imageName: String? = nil

    var subcategories: [ServiceCategory] = []
    var problems: [DiagnosisProblem] = []
}

// MARK: - Result

/// نتيجة تقييم إجابات التشخيص.
enum DiagnosisResult: Equatable {

    /// لم تُجب جميع الأسئلة بعد.
    case inProgress

    /// الإجابات تطابق المشكلة المختارة؛ يُعرض الحل.
    case matches

    /// الإجابات لا تطابق المشكلة المختارة؛ يُعرض التنبيه.
    case mismatch

    /// أُجيب سؤال سلامة حرج بإجابة غير مطابقة؛ لا يُنصح بالإصلاح الذاتي.
    case unsafe
}

// MARK: - Summary

/// ملخص رقمي لإجابات المستخدم.
struct DiagnosisAnswerSummary: Equatable {

    /// عدد الأسئلة التي لها إجابة متوقعة (مُجابة أو لا).
    let evaluableCount: Int

    /// عدد الإجابات المطابقة للإجابة المتوقعة.
    let matchingCount: Int

    /// عدد الإجابات غير المطابقة للإجابة المتوقعة.
    let mismatchingCount: Int

    /// عدد الأسئلة التي لم يُجب عنها بعد.
    let unansweredCount: Int

    /// يكون `true` إذا أُجيب سؤال سلامة حرج بإجابة غير مطابقة.
    let hasSafetyCriticalMismatch: Bool
}

// MARK: - Policy

/// قواعد التقييم. تغييرها لا يتطلب أي تعديل على الواجهات.
struct DiagnosisEvaluationPolicy: Equatable {

    /// يظهر التنبيه عندما يكون عدد الإجابات غير المطابقة
    /// **أكبر من** هذه النسبة مضروبةً في عدد الأسئلة القابلة للتقييم.
    var mismatchRatioThreshold: Double

    /// النتيجة عندما لا توجد أي أسئلة قابلة للتقييم.
    var resultWhenNothingToEvaluate: DiagnosisResult

    /// قاعدة الأغلبية: التنبيه عندما تتجاوز الإجابات غير المطابقة النصف.
    static let majority = DiagnosisEvaluationPolicy(
        mismatchRatioThreshold: 0.5,
        resultWhenNothingToEvaluate: .matches
    )
}

// MARK: - Evaluator

/// منطق تقييم إجابات التشخيص، مستقل تماماً عن الواجهة.
///
/// ترتيب القواعد:
/// 1. أي إجابة غير مطابقة على سؤال سلامة حرج ← ``DiagnosisResult/unsafe`` فوراً.
/// 2. وجود سؤال غير مُجاب ← ``DiagnosisResult/inProgress`` (لا يُعرض التنبيه مبكراً).
/// 3. بعد اكتمال الإجابات ← تُطبَّق ``DiagnosisEvaluationPolicy``.
enum DiagnosisResultEvaluator {

    /// يحسب ملخص الإجابات.
    ///
    /// - Parameters:
    ///   - questions: أسئلة المشكلة.
    ///   - answers: إجابات المستخدم مفهرسة بمعرّف السؤال.
    /// - Returns: ملخص الإجابات.
    /// - Note: الأسئلة المكررة بنفس المعرّف تُحتسب مرة واحدة،
    ///   والإجابات على معرّفات غير موجودة في الأسئلة تُتجاهل.
    static func summarize(
        questions: [DiagnosisQuestion],
        answers: [String: Bool]
    ) -> DiagnosisAnswerSummary {
        var seenIDs = Set<String>()
        var evaluable = 0
        var matching = 0
        var mismatching = 0
        var unanswered = 0
        var hasSafetyCriticalMismatch = false

        for question in questions {
            guard seenIDs.insert(question.id).inserted else { continue }

            if question.expectedAnswer != nil {
                evaluable += 1
            }

            guard let answer = answers[question.id] else {
                unanswered += 1
                continue
            }

            guard let expected = question.expectedAnswer else { continue }

            if answer == expected {
                matching += 1
            } else {
                mismatching += 1
                if question.isSafetyCritical {
                    hasSafetyCriticalMismatch = true
                }
            }
        }

        return DiagnosisAnswerSummary(
            evaluableCount: evaluable,
            matchingCount: matching,
            mismatchingCount: mismatching,
            unansweredCount: unanswered,
            hasSafetyCriticalMismatch: hasSafetyCriticalMismatch
        )
    }

    /// يقيّم الإجابات الحالية.
    ///
    /// - Parameters:
    ///   - questions: أسئلة المشكلة.
    ///   - answers: إجابات المستخدم مفهرسة بمعرّف السؤال.
    ///   - policy: قاعدة التقييم المستخدمة.
    /// - Returns: نتيجة التقييم.
    static func evaluate(
        questions: [DiagnosisQuestion],
        answers: [String: Bool],
        policy: DiagnosisEvaluationPolicy = .majority
    ) -> DiagnosisResult {
        let summary = summarize(questions: questions, answers: answers)

        if summary.hasSafetyCriticalMismatch {
            return .unsafe
        }

        if summary.unansweredCount > 0 {
            return .inProgress
        }

        return verdict(for: summary, policy: policy)
    }

    /// أقل عدد من الإجابات غير المطابقة يُظهر التنبيه.
    ///
    /// مع قاعدة الأغلبية: 3 أسئلة ← 2، 4 ← 3، 5 ← 3، 6 ← 4.
    ///
    /// - Parameters:
    ///   - evaluableCount: عدد الأسئلة القابلة للتقييم.
    ///   - policy: قاعدة التقييم المستخدمة.
    /// - Returns: الحد الأدنى، أو `nil` إذا لم توجد أسئلة قابلة للتقييم.
    static func minimumMismatchesForWarning(
        evaluableCount: Int,
        policy: DiagnosisEvaluationPolicy = .majority
    ) -> Int? {
        guard evaluableCount > 0 else { return nil }
        let limit = policy.mismatchRatioThreshold * Double(evaluableCount)
        return Int(limit.rounded(.down)) + 1
    }

    // MARK: Private

    /// يطبّق قاعدة التقييم بعد اكتمال الإجابات.
    private static func verdict(
        for summary: DiagnosisAnswerSummary,
        policy: DiagnosisEvaluationPolicy
    ) -> DiagnosisResult {
        guard summary.evaluableCount > 0 else {
            return policy.resultWhenNothingToEvaluate
        }

        let limit = policy.mismatchRatioThreshold * Double(summary.evaluableCount)
        return Double(summary.mismatchingCount) > limit ? .mismatch : .matches
    }
}

// MARK: - Session

/// حالة جلسة تشخيص واحدة: السؤال الحالي والإجابات المسجّلة.
///
/// نوع قيمة بسيط يُحفظ في `@State` داخل ``DiagnosisFlowView``،
/// ويمكن اختباره بالكامل دون واجهة.
struct DiagnosisSession {

    // MARK: Properties

    /// أسئلة الجلسة بعد إزالة أي تكرار في المعرّفات.
    let questions: [DiagnosisQuestion]

    /// قاعدة التقييم المستخدمة.
    let policy: DiagnosisEvaluationPolicy

    /// إجابات المستخدم مفهرسة بمعرّف السؤال.
    private(set) var answers: [String: Bool] = [:]

    /// موضع البطاقة الحالية. يساوي عدد الأسئلة بعد الإجابة عنها جميعاً.
    private(set) var currentIndex = 0

    // MARK: Initialization

    /// ينشئ جلسة جديدة.
    ///
    /// - Parameters:
    ///   - questions: أسئلة المشكلة.
    ///   - policy: قاعدة التقييم.
    init(questions: [DiagnosisQuestion], policy: DiagnosisEvaluationPolicy = .majority) {
        var seenIDs = Set<String>()
        self.questions = questions.filter { seenIDs.insert($0.id).inserted }
        self.policy = policy
    }

    // MARK: State

    /// السؤال المعروض حالياً، أو `nil` بعد انتهاء الأسئلة.
    var currentQuestion: DiagnosisQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    /// النتيجة الحالية حسب الإجابات المسجّلة.
    var result: DiagnosisResult {
        DiagnosisResultEvaluator.evaluate(
            questions: questions,
            answers: answers,
            policy: policy
        )
    }

    // MARK: Actions

    /// يسجّل إجابة السؤال الحالي وينتقل إلى السؤال التالي.
    ///
    /// - Parameter answer: `true` عند «نعم»، و`false` عند «لا».
    /// - Returns: النتيجة بعد تسجيل الإجابة، أو `nil` إذا لم تُسجَّل
    ///   (انتهت الأسئلة، أو حُسمت النتيجة مسبقاً، أو سبقت الإجابة).
    @discardableResult
    mutating func answerCurrentQuestion(_ answer: Bool) -> DiagnosisResult? {
        guard result == .inProgress,
              let question = currentQuestion,
              answers[question.id] == nil else {
            return nil
        }

        answers[question.id] = answer
        currentIndex += 1
        return result
    }
}


// MARK: - Data

/// مصدر بيانات الخدمات والأقسام والمشكلات في التطبيق كله.
///
/// لإضافة مشكلة: أضفها إلى قائمة القسم المناسب. لإضافة جهاز: أضف قسماً فرعياً
/// إلى ``homeAppliances``. لا حاجة لأي شاشة جديدة.
enum DiagnosisData {

    // MARK: Lookup

    /// الخدمات الأربع في الشاشة الرئيسية. في RTL يظهر الأول على اليمين.
    static let services: [ServiceCategory] = [water, furniture, electricity, homeAppliances]

    /// يبحث عن خدمة أو قسم فرعي بالمعرّف، في أي مستوى.
    static func category(id: String) -> ServiceCategory? {
        allCategories.first { $0.id == id }
    }

    /// يبحث عن مشكلة بالمعرّف في جميع الأقسام.
    static func problem(id: String) -> DiagnosisProblem? {
        allProblems.first { $0.id == id }
    }

    /// جميع الخدمات والأقسام الفرعية في قائمة واحدة.
    static var allCategories: [ServiceCategory] {
        flatten(services)
    }

    /// جميع المشكلات في التطبيق.
    static var allProblems: [DiagnosisProblem] {
        allCategories.flatMap(\.problems)
    }

    private static func flatten(_ categories: [ServiceCategory]) -> [ServiceCategory] {
        categories.flatMap { [$0] + flatten($0.subcategories) }
    }

    // MARK: Services

    static let water = ServiceCategory(
        id: "water",
        title: "مشاكل المياه",
        icon: "drop",
        problems: [
            faucetLeak,
            sinkClog,
            showerLowFlow,
            toiletRunningWater,
            showerConnectionLeak
        ]
    )

    static let furniture = ServiceCategory(
        id: "furniture",
        title: "الأبواب والأثاث",
        icon: "homekit",
        problems: [
            looseDrawer,
            doorTilt,
             chairWobble,
            doorHandleLoose
        ]
    )

    static let electricity = ServiceCategory(
        id: "electricity",
        title: "مشاكل الكهرباء",
        icon: "bolt",
        subcategories: [lighting, outlets, breakers]
    )

    static let homeAppliances = ServiceCategory(
        id: "home-appliances",
        title: "الأجهزة المنزلية",
        icon: "washer",
        subcategories: [washers, fridges, airConditioners, gasOvens, vacuumCleaners, waterHeaters]
    )

    static let lighting = ServiceCategory(
        id: "lighting",
        title: "الأنوار والإضاءة",
        imageName: "lights",
        problems: [
            bulbBurnt,
            bulbFlickering,
            bulbMismatch,
            bulbDim
        ]
    )

    static let outlets = ServiceCategory(
        id: "outlets",
        title: "المقابس والتوصيلات",
        imageName: "sockets_wiring",
        problems: [
            deviceNotWorking,
            plugHot,
            outletSparks
        ]
    )

    static let breakers = ServiceCategory(
        id: "breakers",
        title: "القواطع وانقطاع الكهرباء",
        imageName: "power_outage",
        problems: [
            oneRoomOutage,
            wholeHouseOutage,
            clickingBurningSmell
        ]
    )

    // MARK: Home Appliances

    static let washers = ServiceCategory(
        id: "washers",
        title: "الغسالات",
        imageName: "device_washer",
        problems: [
            washerNotDraining,
            washerDrumNotSpinning,
            washerInletHoseLeak
        ]
    )

    static let fridges = ServiceCategory(
        id: "fridges",
        title: "الثلاجات",
        imageName: "device_fridge",
        problems: [
            fridgeNotCooling,
            fridgeDoorNotSealing,
            fridgeWaterLeak
        ]
    )

    static let airConditioners = ServiceCategory(
        id: "air-conditioners",
        title: "المكيفات",
        imageName: "device_ac",
        problems: [
            acWaterDrip,
            acClickingNoise,
            acBadSmell
        ]
    )

    static let gasOvens = ServiceCategory(
        id: "gas-ovens",
        title: "أفران الغاز",
        imageName: "device_oven",
        problems: [
            ovenGasChange,
            ovenFlameStops,
            ovenWeakFlame
        ]
    )

    static let vacuumCleaners = ServiceCategory(
        id: "vacuum-cleaners",
        title: "المكانس الكهربائية",
        imageName: "device_vacuum",
        problems: [
            vacuumLoudNoise,
            vacuumDirtyFilter,
            vacuumCloggedHose
        ]
    )

    static let waterHeaters = ServiceCategory(
        id: "water-heaters",
        title: "سخانات المياه",
        imageName: "water_heater2",
        problems: [
            heaterInstall,
            heaterValveReplace,
            heaterWeakHotWater
        ]
    )

    // MARK: Problems — Furniture

    static let looseDrawer = DiagnosisProblem(
            id: "drawer-loose",
            title: "ارتخاء الأدراج",
            description: "قد يصبح الدرج مائلاً أو غير ثابت، مما يصعب فتحه وإغلاقه بسلاسة. غالباً بسبب ارتخاء المسامير أو تلف مسارات الدرج.",
            illustrationAsset: "drawer_loose",
            questions: [
                DiagnosisQuestion(id: "drawer-loose-q1", text: "هل تلاحظين أن الدرج يهتز أو يتحرك من جانب إلى آخر عند سحبه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "drawer-loose-q2", text: "هل يميل الدرج إلى أحد الجانبين أثناء فتحه أو إغلاقه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "drawer-loose-q3", text: "هل تشعرين بأن الدرج غير ثابت على مساره عند تحريكه؟", expectedAnswer: true)
            ],
            solutionSteps: [
                SolutionStep(
                    order: 1,
                    title: "إفراغ الدرج",
                    text: "أخرجي جميع الأغراض من الدرج لتخفيف وزنه وتسهيل فحصه.",
                    illustrationAsset: "drawer_step1"
                ),
                SolutionStep(
                    order: 2,
                    title: "إزالة الدرج",
                    text: "اسحبي الدرج للخارج، ثم حرري مشابك السحّابات إن وُجدت، وأخرجيه برفق حسب طريقة طرازه.",
                    illustrationAsset: "drawer_step2"
                ),
                SolutionStep(
                    order: 3,
                    title: "فحص السحّابات",
                    text: "افحصي السحّابات المعدنية على جانبي الدرج وداخل الخزانة، وحددي البراغي المرتخية أو المفقودة.",
                    illustrationAsset: "drawer_step3"
                ),
                SolutionStep(
                    order: 4,
                    title: "تثبيت البراغي",
                    text: "استخدمي مفكًا مناسبًا لشد البراغي المرتخية باتجاه عقارب الساعة، دون شد مفرط أو تغيير محاذاة السحّابات.",
                    illustrationAsset: "drawer_step4",
                    warning: "تنبيه: إذا كانت فتحات البراغي متآكلة، أو السحّابات مكسورة أو منحنية، فلا تكتفي بشد البراغي؛ فقد يحتاج الدرج إلى إصلاح إضافي أو استبدال السحّابات."
                ),
                SolutionStep(
                    order: 5,
                    title: "إعادة تركيب الدرج",
                    text: "حاذي الدرج مع السحّابات على الجانبين، ثم ادفعيه برفق حتى يستقر في مكانه وتتعشق مشابك التثبيت إن وُجدت.",
                    illustrationAsset: "drawer_step5"
                ),
                SolutionStep(
                    order: 6,
                    title: "اختبار الدرج",
                    text: "افتحي الدرج وأغلقيه عدة مرات، وتأكدي من ثباته وحركته بسلاسة دون اهتزاز أو ميلان.",
                    illustrationAsset: "drawer_step6"
                )
            ]
        )

    static let doorTilt = DiagnosisProblem(
            id: "door-tilt",
            title: "ميلان الأبواب",
            description: "يظهر ميلان في الأبواب مما يمنع إغلاقها بإحكام أو الاحتكاك بالأرضية، وغالباً ما يحتاج تعديل المفصلات.",
            illustrationAsset: "door_tilt",
            questions: [
                DiagnosisQuestion(id: "door-tilt-q1", text: "هل تلاحظين أن الباب مائل أو أن المسافة بينه وبين الإطار غير متساوية؟", expectedAnswer: true),
                DiagnosisQuestion(id: "door-tilt-q2", text: "هل يحتك الباب بالأرض أو بإطاره أثناء فتحه أو إغلاقه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "door-tilt-q3", text: "هل أصبح إغلاق الباب أصعب من المعتاد بسبب عدم استقامته؟", expectedAnswer: true)
            ],
            solutionSteps: [
                SolutionStep(
                    order: 1,
                    title: "فحص ميلان الباب",
                    text: "أغلقي الباب ببطء ولاحظي مكان احتكاكه بالإطار أو الأرض، وتحققي من اختلاف المسافات حول حوافه.",
                    illustrationAsset: "door_tilt_step1"
                ),
                SolutionStep(
                    order: 2,
                    title: "فحص المفصلات",
                    text: "افتحي الباب قليلًا، وافحصي المفصلات والبراغي الموجودة على جانب الباب والإطار لتحديد أي ارتخاء.",
                    illustrationAsset: "door_tilt_step2"
                ),
                SolutionStep(
                    order: 3,
                    title: "شد براغي المفصلات",
                    text: "استخدمي مفكًا مناسبًا لشد البراغي المرتخية باتجاه عقارب الساعة، مع التركيز على المفصلة العلوية، دون شد مفرط.",
                    illustrationAsset: "door_tilt_step3"
                ),
                SolutionStep(
                    order: 4,
                    title: "فحص ثبات المفصلات",
                    text: "تأكدي من ثبات المفصلات وعدم تحركها. إذا كان البرغي يدور دون أن يثبت، فتوقفي؛ فقد تكون فتحة تثبيته متآكلة وتحتاج إصلاحًا مختلفًا.",
                    illustrationAsset: "door_tilt_step4",
                ),
                SolutionStep(
                    order: 5,
                    title: "اختبار الباب",
                    text: "افتحي الباب وأغلقيه ببطء للتأكد من استقامته وعدم احتكاكه بالأرض أو الإطار.",
                    illustrationAsset: "door_tilt_step5",
                )
            ]
        )
    static let chairWobble = DiagnosisProblem(
            id: "chair-wobble",
            title: "اهتزاز الكراسي",
            description: "تصبح الكراسي غير متوازنة أو مهتزة عند الجلوس عليها بسبب تفكك المسامير أو تخلخل الوصلات الخشبية.",
            illustrationAsset: "chair_wobble",
            questions: [
                DiagnosisQuestion(id: "chair-wobble-q1", text: "هل تلاحظين أن الكرسي يهتز أو يميل من جانب إلى آخر عند تحريكه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "chair-wobble-q2", text: "هل يتحرك أحد أرجل الكرسي أو يبدو غير ثابت مقارنة ببقية الأرجل؟", expectedAnswer: true),
                DiagnosisQuestion(id: "chair-wobble-q3", text: "هل يستمر اهتزاز الكرسي عند وضعه على أرضية مستوية وصلبة؟", expectedAnswer: true)
            ],
            solutionSteps: [
                SolutionStep(
                    order: 1,
                    title: "وضع الكرسي على سطح ثابت",
                    text: "أفرغي الكرسي، ثم ضعيه على أرضية مستوية للتأكد من وجود اهتزاز.",
                    illustrationAsset: "chair_wobble_step1"
                ),
                SolutionStep(
                    order: 2,
                    title: "قلب الكرسي بحذر",
                    text: "اقلبي الكرسي على سطح ناعم وثابت للوصول إلى البراغي الموجودة أسفل المقعد، مع حماية مسند الظهر.",
                    illustrationAsset: "chair_wobble_step2"
                ),
                SolutionStep(
                    order: 3,
                    title: "فحص تثبيت الأرجل",
                    text: "افحصي نقاط اتصال الأرجل بالمقعد، وحددي البراغي المرتخية أو أي تشققات ظاهرة.",
                    illustrationAsset: "chair_wobble_step3"
                ),
                SolutionStep(
                    order: 4,
                    title: "شد البراغي",
                    text: "استخدمي مفكًا أو مفتاح ألن مناسبًا، وشدّي البراغي المرتخية باتجاه عقارب الساعة دون شد مفرط.",
                    illustrationAsset: "chair_wobble_step4",
                ),
                SolutionStep(
                    order: 5,
                    title: "إعادة الكرسي إلى وضعه",
                    text: "أعيدي الكرسي إلى وضعه الطبيعي، وتأكدي من ملامسة الأرجل الأربع للأرض بصورة مستقرة.",
                    illustrationAsset: "chair_wobble_step5"
                ),
                SolutionStep(
                    order: 6,
                    title: "اختبار ثبات الكرسي",
                    text: "حرّكي الكرسي برفق دون الجلوس عليه، وتحققي من اختفاء الاهتزاز وثبات الأرجل قبل استخدامه.",
                    illustrationAsset: "chair_wobble_step6",
                )
            ]
        )
    static let doorHandleLoose = DiagnosisProblem(
            id: "door-handle-loose",
            title: "مقابض الأبواب مفكوكة",
            description: "تتحرك المقابض من مكانها أو ترتخي أثناء الاستخدام نتيجة تآكل أو ارتخاء براغي التثبيت الداخلية.",
            illustrationAsset: "handle_loose",
            questions: [
                DiagnosisQuestion(id: "door-handle-loose-q1", text: "هل يتحرك مقبض الباب أو يهتز عند الإمساك به؟", expectedAnswer: true),
                DiagnosisQuestion(id: "door-handle-loose-q2", text: "هل تلاحظين أن المقبض غير ثابت في مكانه عند فتح الباب أو إغلاقه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "door-handle-loose-q3", text: "هل توجد مسافة أو حركة غير طبيعية بين المقبض وقاعدته المثبتة على الباب؟", expectedAnswer: true)
            ],
            solutionSteps: [
                SolutionStep(
                    order: 1,
                    title: "فحص المقبض",
                    text: "افتحي الباب واتركيه مفتوحًا، ثم حرّكي المقبض برفق لتحديد ما إذا كان الارتخاء في المقبض نفسه أو في قاعدته.",
                    illustrationAsset: "handle_loose_step1"
                ),
                SolutionStep(
                    order: 2,
                    title: "تحديد مسمار التثبيت",
                    text: "ابحثي عن المسمار الصغير الموجود أسفل المقبض أو على جانبه، وحددي الأداة المناسبة له.",
                    illustrationAsset: "handle_loose_step2"
                ),
                SolutionStep(
                    order: 3,
                    title: "شد مسمار المقبض",
                    text: "ثبّتي المقبض في مكانه، ثم استخدمي مفتاح ألن أو مفكًا مناسبًا لإحكام مسمار التثبيت وفق اتجاه الربط الخاص بطرازه.",
                    illustrationAsset: "handle_loose_step3"
                ),
                SolutionStep(
                    order: 4,
                    title: "فحص براغي القاعدة",
                    text: "إذا استمرت حركة القاعدة، افحصي براغيها. وإذا كانت مخفية خلف غطاء دائري، أزيلي الغطاء بالطريقة الموضحة في دليل المقبض.",
                    illustrationAsset: "handle_loose_step4"
                ),
                SolutionStep(
                    order: 5,
                    title: "تثبيت قاعدة المقبض",
                    text: "شدّي براغي القاعدة المرتخية دون شد مفرط، ثم أعيدي الغطاء إلى مكانه إن أزلتِه.",
                    illustrationAsset: "handle_loose_step5",
                ),
                SolutionStep(
                    order: 6,
                    title: "اختبار المقبض",
                    text: "حرّكي المقبض عدة مرات والباب مفتوح، ثم اختبري فتح الباب وإغلاقه للتأكد من ثبات المقبض وعمل لسان القفل بشكل طبيعي.",
                    illustrationAsset: "handle_loose_step6",
                )
            ]
        )
    // MARK: Problems — Air Conditioners

    static let acWaterDrip = DiagnosisProblem(
        id: "ac-water-drip",
        title: "تقطير الماء من مكيف الأسبلت",
        description: "قد يتسرب الماء من  المكيف أثناء تشغيله، وغالبًا ما يحدث ذلك بسبب انسداد أنبوب تصريف المياه أو تراكم الأوساخ، مما يمنع تصريف الماء بشكل طبيعي ويؤدي إلى تقطيره داخل الغرفة.",
        illustrationAsset: "ac_water_drip",
        questions: [
            DiagnosisQuestion(id: "ac-water-drip-q1", text: "هل الماء ينقط بشكل متواصل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-water-drip-q2", text: "هل في كتل وأوساخ على مجرى فتحة التصريف؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-water-drip-q3", text: "هل الماء يخرج من الواجهة الأمامية للمكيف؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-water-drip-q4", text: "هل يوجد تجمع ماء داخل المكيف؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-water-drip-q5", text: "هل فتحة التصريف مسدودة أو متسخة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-water-drip-q6", text: "هل الماء يخرج من نفس المكان كل مرة؟", expectedAnswer: true),
            // REVIEW: "Yes" does not confirm the problem, so this question is not evaluated.
            DiagnosisQuestion(id: "ac-water-drip-q7", text: "هل سبق تنظيف فتحة التصريف من قبل؟", expectedAnswer: nil)
        ],
        // Suggested images: front panel, filters, screws, grille clips, drain hose, drain opening.
        solutionSteps: [
            SolutionStep(order: 1, text: "اقفل المكيف عن الكهرباء."),
            SolutionStep(order: 2, text: "فك الباب الاماميه للمكيف.\n• نسحب الفلاتر.\n• فك البراغي."),
            SolutionStep(order: 3, text: "فك كلبسات الشبك باليد."),
            SolutionStep(order: 4, text: "تتبع خرطوم التصريف."),
            SolutionStep(order: 5, text: "تاكد من فتح فتحة التصريف اذا كانت مسدوده."),
            SolutionStep(order: 6, text: "اجلب مصاص شرب و ضعه على فتحة التصريف و انفخ ليفتح المجرى."),
            SolutionStep(order: 7, text: "ارجع واجهه المكيف بالترتيب.")
        ]
    )

    static let acClickingNoise = DiagnosisProblem(
        id: "ac-clicking-noise",
        title: "طقطقة المكيف",
        description: "قد تصدر من المكيف أصوات طقطقة أثناء التشغيل أو بعد إيقافه، وقد تنتج عن تمدد وانكماش الأجزاء البلاستيكية بسبب تغير درجة الحرارة، أو اهتزاز بعض الأجزاء غير المثبتة جيدًا.",
        illustrationAsset: "ac_clicking_noise",
        questions: [
            DiagnosisQuestion(id: "ac-clicking-noise-q1", text: "هل تسمع صوت طقطقة عند تشغيل المكيف؟", expectedAnswer: true),
            // REVIEW: An either/or question can't be answered with yes/no, so it is not evaluated.
            DiagnosisQuestion(id: "ac-clicking-noise-q2", text: "هل الطقطقة مستمرة أو تظهر أحيانًا فقط؟", expectedAnswer: nil),
            DiagnosisQuestion(id: "ac-clicking-noise-q3", text: "هل الصوت يخرج من الواجهة الأمامية؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-clicking-noise-q4", text: "هل الصوت يخرج من جهة الشبك أو الغطاء؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-clicking-noise-q5", text: "هل يوجد اهتزاز مع صوت الطقطقة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-clicking-noise-q6", text: "هل توجد براغي غير ثابتة؟", expectedAnswer: true)
        ],
        // Suggested images: opened front panel, filters, loose screws, grille clips, where to trace the sound.
        solutionSteps: [
            SolutionStep(order: 1, text: "اغلق الكهرباء عن المكيف."),
            SolutionStep(order: 2, text: "افتح واجهه المكيف.\n• سحب الفلاتر.\n• فك البراغي.\n• فك كلبسات الشبك باليد."),
            SolutionStep(
                order: 3,
                text: "قم بتشغيل المكيف للتتبع فقط.",
                warning: "تحذير شديد: لا تلمس المكيف او اي اجزاء خلال تشغيله، هذا فقط للتتبع."
            ),
            SolutionStep(order: 4, text: "يوجد براغي تحتاج الى شد."),
            SolutionStep(order: 5, text: "اجلب مفك وقم بشدها.")
        ]
    )

    static let acBadSmell = DiagnosisProblem(
        id: "ac-bad-smell",
        title: "الرائحة الكريهة في المكيف",
        description: "قد تظهر رائحة كريهة عند تشغيل المكيف بسبب تراكم الغبار أو الرطوبة داخل الجهاز، مما يؤثر على نقاء الهواء في الغرفة.",
        illustrationAsset: "ac_bad_smell",
        questions: [
            DiagnosisQuestion(id: "ac-bad-smell-q1", text: "هل الفلتر متسخ؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-bad-smell-q2", text: "هل هناك طبقه طينيه ملتصقه بالمكيف؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-bad-smell-q3", text: "هل مروحة الدفع متسخه؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-bad-smell-q4", text: "هل الرائحة تظهر مباشرة عند تشغيل المكيف؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-bad-smell-q5", text: "هل الرائحة تزداد مع قوة الهواء؟", expectedAnswer: true),
            // REVIEW: "Yes" does not confirm the problem, so this question is not evaluated.
            DiagnosisQuestion(id: "ac-bad-smell-q6", text: "هل تم تنظيف الفلاتر من قبل؟", expectedAnswer: nil),
            DiagnosisQuestion(id: "ac-bad-smell-q7", text: "هل توجد أوساخ واضحة داخل الواجهة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-bad-smell-q8", text: "هل المروحة عليها غبار أو طبقة متراكمة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "ac-bad-smell-q9", text: "هل الرائحة تشبه العفن أو الرطوبة؟", expectedAnswer: true)
        ],
        // Suggested images: dirty filter, muddy layer inside, blower fan, before and after cleaning.
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "قم بإيقاف تشغيل المكيف وفصل الكهرباء قبل البدء بالتنظيف."
            ),
            SolutionStep(
                order: 2,
                title: "فتح واجهة المكيف",
                text: "افتح الواجهة الأمامية للمكيف واسحب فلاتر الهواء برفق."
            ),
            SolutionStep(
                order: 3,
                title: "تنظيف الفلاتر",
                text: "اغسل الفلاتر القابلة للغسل بالماء لإزالة الأتربة والأوساخ، ثم اتركها حتى تجف تمامًا."
            ),
            SolutionStep(
                order: 4,
                title: "فحص مروحة الدفع",
                text: "تحقق من وجود أوساخ أو طبقة طينية متراكمة على مروحة الدفع والأجزاء الداخلية الظاهرة. نظّف الأتربة السطحية التي يمكن الوصول إليها بأمان دون فك الأجزاء الكهربائية."
            ),
            SolutionStep(
                order: 5,
                title: "تنظيف الأجزاء الداخلية",
                text: "نظّف الأوساخ الظاهرة باستخدام أداة تنظيف مناسبة.",
                warning: "لا ترش الماء مباشرة على التوصيلات أو المكونات الكهربائية. الأوساخ العميقة التي تتطلب تفكيك المروحة تحتاج تنظيفًا متخصصًا."
            ),
            SolutionStep(
                order: 6,
                title: "إعادة تركيب الأجزاء",
                text: "أعد الفلاتر إلى مكانها، ثم أغلق الواجهة الأمامية للمكيف بإحكام."
            ),
            SolutionStep(
                order: 7,
                title: "التأكد من اختفاء الرائحة",
                text: "بعد اكتمال التجفيف والتركيب، شغّل المكيف وتحقق من اختفاء الرائحة."
            )
        ]
    )

    // MARK: Problems — Fridges

    static let fridgeNotCooling = DiagnosisProblem(
        id: "fridge-not-cooling",
        title: "الثلاجة لا تبرد جيدًا",
        description: "قد تضعف برودة الثلاجة بسبب تراكم الأوساخ أو ضعف تهوية الهواء داخلها، مما يؤثر على حفظ الأطعمة.",
        illustrationAsset: "fridge_not_cooling",
        questions: [
            DiagnosisQuestion(id: "fridge-not-cooling-q1", text: "هل تبريد الثلاجة أضعف من المعتاد رغم أنها تعمل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-not-cooling-q2", text: "هل توجد طبقة واضحة من الغبار أو الأوساخ على ملفات المكثف التي يمكن رؤيتها بأمان؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-not-cooling-q3", text: "هل درجة الحرارة مضبوطة على الإعداد الموصى به في دليل الثلاجة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-not-cooling-q4", text: "هل باب الثلاجة يغلق بإحكام؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "افصل الثلاجة من مصدر الكهرباء قبل البدء بالتنظيف."
            ),
            SolutionStep(
                order: 2,
                title: "تحديد مكان المكثف",
                text: "راجع دليل الثلاجة لمعرفة مكان ملفات المكثف وطريقة الوصول المسموح بها.",
                warning: "لا تفتح أي غطاء غير مخصص للمستخدم."
            ),
            SolutionStep(
                order: 3,
                title: "إزالة الغبار",
                text: "إذا سمحت تعليمات الجهاز، استخدم مكنسة كهربائية بفرشاة ناعمة لإزالة الغبار دون ثني الأنابيب أو إتلافها."
            ),
            SolutionStep(
                order: 4,
                title: "إعادة التشغيل",
                text: "أعيد الأجزاء المسموح بفكها إلى مكانها، ثم وصّل الثلاجة بالكهرباء وتحقق من درجة التبريد بعد استقرارها.",
                warning: "إذا استمرت المشكلة، فقد تحتاج إلى فحص مختص."
            )
        ]
    )

    static let fridgeDoorNotSealing = DiagnosisProblem(
        id: "fridge-door-seal",
        title: "باب الثلاجة لا يغلق بإحكام",
        description: "قد تلاحظ أن باب الثلاجة لا يُغلق جيدًا أو يترك فراغًا بسيطًا، وقد يكون ذلك بسبب اتساخ الإطار المطاطي للباب أو وجود عائق يمنعه من الإغلاق بإحكام.",
        illustrationAsset: "fridge_door_seal",
        questions: [
            DiagnosisQuestion(id: "fridge-door-seal-q1", text: "هل تلاحظ أن باب الثلاجة لا يغلق بالكامل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-door-seal-q2", text: "هل توجد أطعمة أو عبوات تمنع إغلاق الباب؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-door-seal-q3", text: "هل توجد أوساخ أو بقايا طعام على جلدة الباب المطاطية؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-door-seal-q4", text: "هل جلدة الباب سليمة دون تشققات أو تمزقات ظاهرة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إزالة العوائق",
                text: "تحقق من ترتيب العبوات والأطعمة داخل الثلاجة، وأبعد أي شيء يمنع الباب من الإغلاق."
            ),
            SolutionStep(
                order: 2,
                title: "تنظيف جلدة الباب",
                text: "امسح الجلدة المطاطية بقطعة قماش ناعمة وماء دافئ مع صابون خفيف، ثم جففها."
            ),
            SolutionStep(
                order: 3,
                title: "فحص الإغلاق",
                text: "أغلق الباب وتأكد من أنه يستقر في مكانه دون وجود فراغات واضحة."
            ),
            SolutionStep(
                order: 4,
                title: "التحقق من النتيجة",
                text: "إذا استمر عدم الإغلاق أو كانت الجلدة ممزقة، فقد تحتاج إلى استبدال مناسب للطراز أو مساعدة فني."
            )
        ]
    )

    static let fridgeWaterLeak = DiagnosisProblem(
        id: "fridge-water-drops",
        title: "تسريب المياه من الثلاجة",
        description: "قد تلاحظ تجمع الماء داخل الثلاجة أو على الأرض أسفلها، وقد يكون السبب انسداد فتحة التصريف أو تراكم الثلج وذوبانه.",
        illustrationAsset: "fridge_water_drops",
        questions: [
            DiagnosisQuestion(id: "fridge-water-drops-q1", text: "هل توجد مياه متجمعة داخل الثلاجة أو أسفل أدراج الخضار؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-water-drops-q2", text: "هل توجد عبوة مفتوحة أو مسكوبة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-water-drops-q3", text: "هل تحتوي الثلاجة على فلتر ماء، وهل توجد مياه حوله؟", expectedAnswer: true),
            DiagnosisQuestion(id: "fridge-water-drops-q4", text: "هل يتكرر تجمع الماء بعد تنظيفه؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "تحديد مصدر الماء",
                text: "أخرج العبوات القريبة من موضع التسرب وتحقق من عدم انسكاب محتوياتها."
            ),
            SolutionStep(
                order: 2,
                title: "تجفيف المكان",
                text: "امسح الماء بقطعة قماش نظيفة وجفف السطح."
            ),
            SolutionStep(
                order: 3,
                title: "فحص فلتر الماء",
                text: "إذا كانت الثلاجة تحتوي على فلتر ماء، فتحقق من عدم وجود تسرب ظاهر حوله، واتبع دليل الجهاز للتأكد من تثبيته الصحيح دون فك الأجزاء الداخلية."
            ),
            SolutionStep(
                order: 4,
                title: "مراقبة التسرب",
                text: "راقب المكان بعد التنظيف.",
                warning: "إذا عاد الماء دون مصدر واضح، أو بدا أن مصدره نظام التصريف الداخلي، فلا تحاول فك أنابيب التصريف أو إزالة الأغطية الداخلية، واستعن بفني."
            )
        ]
    )

    // MARK: Problems — Washers

    static let washerNotDraining = DiagnosisProblem(
        id: "washer-drain",
        title: "الغسالة لا تصرّف الماء",
        description: "يبقى الماء داخل حوض الغسيل بعد اختيار وضع التصريف، ولا يخرج من الغسالة بالشكل الطبيعي.",
        illustrationAsset: "washer_drain",
        questions: [
            DiagnosisQuestion(id: "washer-drain-q1", text: "هل يبقى الماء داخل حوض الغسيل عند اختيار وضع التصريف؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-drain-q2", text: "هل خرطوم التصريف مثني أو مضغوط؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-drain-q3", text: "هل توجد أوساخ أو أجسام عالقة عند فتحة التصريف الظاهرة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "افصل قابس الغسالة بيدين جافتين، وأغلق مصدر الماء. ضع منشفة ووعاءً منخفضًا لاستقبال الماء المتبقي."
            ),
            SolutionStep(
                order: 2,
                title: "فحص خرطوم التصريف",
                text: "تأكد من أن الخرطوم غير مضغوط أو ملتف، وأن ارتفاعه مطابق لدليل الغسالة. بعض غسالات الحوضين تحتاج إلى وضع الخرطوم منخفضًا."
            ),
            SolutionStep(
                order: 3,
                title: "تحديد منفذ تنظيف الصمام",
                text: "راجع دليل طراز الغسالة. إذا كان يحتوي على غطاء مخصص للمستخدم لتنظيف صمام التصريف، حدد مكانه واتبع تعليمات فتحه."
            ),
            SolutionStep(
                order: 4,
                title: "إزالة الانسداد",
                text: "إذا سمح دليل الجهاز، افتح غطاء الصمام المخصص للصيانة، وأزل الوبر والأجسام الغريبة الظاهرة دون استخدام أدوات حادة أو شد آلية الصمام."
            ),
            SolutionStep(
                order: 5,
                title: "إعادة التركيب والاختبار",
                text: "أعد الأغطية المخصصة للصيانة إلى مكانها وفق تعليمات الدليل. بعد التأكد من جفاف الأجزاء وعدم وجود تسرب ظاهر، اعد اختبار تصريف الماء.",
                warning: "إذا استمرت المشكلة أو ظهر تسرب، أوقف الغسالة وافحص السبب قبل تكرار المحاولة."
            )
        ]
    )

    static let washerDrumNotSpinning = DiagnosisProblem(
        id: "washer-drum",
        title: "حوض الغسيل لا يدور",
        description: "يتوقف قرص التحريك داخل حوض الغسيل عن الدوران عند تشغيل الغسالة.",
        illustrationAsset: "washer_drum",
        questions: [
            DiagnosisQuestion(id: "washer-drum-q1", text: "هل يتوقف قرص التحريك عن الدوران عند بدء الغسيل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-drum-q2", text: "هل الحوض ممتلئ بالملابس بما يتجاوز الحد المسموح؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-drum-q3", text: "هل توجد قطع ملابس عالقة حول قرص التحريك؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إيقاف الغسالة",
                text: "أوقف تشغيل الغسالة، وافصل القابس من مصدر الكهرباء بيدين جافتين."
            ),
            SolutionStep(
                order: 2,
                title: "تقليل كمية الملابس",
                text: "أخرج جزءًا من الملابس حتى تصبح الحمولة ضمن السعة المسموحة في دليل الغسالة."
            ),
            SolutionStep(
                order: 3,
                title: "فحص الحوض",
                text: "تأكد بصريًا من عدم وجود ملابس ملتفة حول قرص التحريك أو أجسام ظاهرة تعيق حركته."
            ),
            SolutionStep(
                order: 4,
                title: "إعادة التشغيل",
                text: "بعد التأكد من خلو الحوض من العوائق الظاهرة، أعد تشغيل دورة الغسيل."
            )
        ]
    )

    static let washerInletHoseLeak = DiagnosisProblem(
        id: "washer-hose-leak",
        title: "تسرب الماء من وصلة خرطوم دخول الماء",
        description: "قد تلاحظ تسرب الماء من مكان توصيل خرطوم الغسالة بالصنبور أو بمدخل الماء، وقد يكون ذلك بسبب ارتخاء الوصلة أو تلف الحلقة المطاطية.",
        illustrationAsset: "washer_hose_leak",
        questions: [
            DiagnosisQuestion(id: "washer-hose-leak-q1", text: "هل يتسرب الماء من نقطة اتصال الخرطوم بالصنبور أو بالغسالة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-hose-leak-q2", text: "هل الوصلة مرتخية أو غير مثبتة بشكل مستقيم؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-hose-leak-q3", text: "هل توجد تشققات أو تلف ظاهر في الخرطوم؟", expectedAnswer: true),
            DiagnosisQuestion(id: "washer-hose-leak-q4", text: "هل يظهر التسرب عند فتح صنبور الماء؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إيقاف الماء وفصل الكهرباء",
                text: "أغلق صنبور الماء، وأوقف تشغيل الغسالة وافصل قابس الكهرباء بيدين جافتين."
            ),
            SolutionStep(
                order: 2,
                title: "تحديد مكان التسرب",
                text: "افحص وصلة الخرطوم عند الصنبور وعند مدخل الماء في الغسالة، وحدد النقطة التي يتسرب منها الماء."
            ),
            SolutionStep(
                order: 3,
                title: "إعادة تثبيت الوصلة",
                text: "إذا كانت الوصلة مرتخية، أعد تثبيتها بشكل مستقيم وفق تعليمات الجهاز، دون المبالغة في الشد."
            ),
            SolutionStep(
                order: 4,
                title: "فحص الخرطوم والحلقة المطاطية",
                text: "إذا استمر التسرب، تحقق من وجود تشققات في الخرطوم أو تلف في الحلقة المطاطية الموجودة داخل الوصلة. استبدل الجزء التالف بقطعة متوافقة مع الجهاز."
            ),
            SolutionStep(
                order: 5,
                title: "التأكد من توقف التسرب",
                text: "افتح صنبور الماء تدريجيًا، وراقب الوصلة للتأكد من عدم خروج الماء.",
                warning: "إذا استمر التسرب، أغلق الصنبور ولا تستخدم الغسالة حتى تُعالج المشكلة."
            )
        ]
    )

    // MARK: Problems — Gas Ovens

    static let ovenGasChange = DiagnosisProblem(
        id: "oven-gas-change",
        title: "تبديل الغاز",
        description: "قد تحتاج أسطوانة الغاز إلى التبديل عند نفاد الغاز وتوقف عيون الموقد عن الاشتعال.",
        illustrationAsset: "oven_gas_change 1",
        questions: [
            DiagnosisQuestion(id: "oven-gas-change-q1", text: "هل توقفت شعلة الموقد عن العمل رغم محاولة تشغيلها؟", expectedAnswer: true),
            DiagnosisQuestion(id: "oven-gas-change-q2", text: "هل جميع عيون الموقد لا تشتعل رغم التأكد من أن منظّم الغاز مفتوح؟", expectedAnswer: true),
            DiagnosisQuestion(id: "oven-gas-change-q3", text: "هل يشير مؤشر الأسطوانة إلى نفاد الغاز، أو تأكدت من أنها فارغة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إغلاق المنظّم وفصله",
                text: "تأكد من إغلاق منظّم الغاز قبل إزالته، واتبع الطريقة المناسبة لنوع المنظّم:\n• النوع الأول: لف المقبض إلى وضع الإغلاق، ثم افصل المنظّم وفق تعليمات الشركة المصنّعة.\n• النوع الثاني: لف المقبض إلى العلامة الخضراء المخصصة للإغلاق، وليس علامة الشعلة، ثم افصل المنظّم.",
                illustrationAssets: ["type1_step1", "type2_step1"],
                warning: "لا تعتمد على ظهور الزر الأحمر أو العلامة الخضراء بوصفهما دليلًا موحدًا على إغلاق الغاز؛ فطريقة الإغلاق والتركيب تختلف حسب طراز المنظّم."
            ),
            SolutionStep(
                order: 2,
                title: "تجهيز الأسطوانة الجديدة",
                text: "أحضر أسطوانة الغاز الجديدة، وضعها بشكل عمودي على سطح ثابت وجيد التهوية."
            ),
            SolutionStep(
                order: 3,
                title: "إزالة اللاصق من الأسطوانة الجديدة",
                text: "أزل اللاصق الواقي عن مدخل الأسطوانة، وتأكد من سلامة المدخل وعدم وجود تلف ظاهر.",
                illustrationAsset: "oven_step3"
            ),
            SolutionStep(
                order: 4,
                title: "تركيب منظّم الغاز",
                text: "تختلف طريقة التركيب حسب نوع المنظّم:\n• النوع الأول: تأكد من أن المنظّم مغلق، ثم ثبّته على مدخل الأسطوانة.\n• النوع الثاني: ارفع الجزء الأسود السفلي المخصص للتثبيت، وركّب المنظّم على مدخل الأسطوانة.",
                illustrationAsset: "oven_step4"
            ),
            SolutionStep(
                order: 5,
                title: "فتح الغاز والتأكد من السلامة",
                text: "بعد التأكد من ثبات المنظّم وتركيبه بشكل صحيح، افتحه بالطريقة المخصصة لنوعه، وتحقق من عدم وجود تسريب قبل تشغيل الموقد.\n\nللتأكد من عدم وجود تسريب، استخدم محلول كشف التسرب أو الماء والصابون على الوصلات؛ ظهور الفقاعات يدل على تسريب.",
                warning: "لا تستخدم اللهب للاختبار.\nوإذا ظهرت رائحة غاز، أغلق المصدر إن أمكن بأمان، وتجنب المفاتيح الكهربائية ومصادر الاشتعال، واطلب مساعدة مختص."
            )
        ]
    )

    static let ovenFlameStops = DiagnosisProblem(
        id: "oven-flame-stops",
        title: "مشكلة توقف النار بعد التشغيل",
        description: "تشتعل عين الموقد في البداية، لكنها تنطفئ بعد ترك مقبض التشغيل، وقد يكون السبب اتساخ حساس الأمان أو وجود خلل في عمله.",
        illustrationAsset: "oven_flame_stops 1",
        questions: [
            DiagnosisQuestion(id: "oven-flame-stops-q1", text: "هل تشتعل عين الموقد عند الضغط على مقبض التشغيل؟", expectedAnswer: true),
            // REVIEW: An either/or question can't be answered with yes/no, so it is not evaluated.
            DiagnosisQuestion(id: "oven-flame-stops-q2", text: "هل تنطفئ الشعلة مباشرة أو بعد ثوانٍ من ترك المقبض؟", expectedAnswer: nil),
            DiagnosisQuestion(id: "oven-flame-stops-q3", text: "هل تتكرر المشكلة في نفس العين بينما تعمل بقية العيون بشكل طبيعي؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إغلاق الغاز",
                text: "أغلق مقبض عين الموقد، وانتظر حتى تبرد جميع أجزائها تمامًا قبل البدء بالتنظيف."
            ),
            SolutionStep(
                order: 2,
                title: "إزالة غطاء العين",
                text: "ارفع الغطاء الأسود الموجود أعلى عين الموقد برفق.",
                illustrationAsset: "oven_lifting_step2"
            ),
            SolutionStep(
                order: 3,
                title: "إزالة القطعة المعدنية",
                text: "ارفع القطعة المعدنية الموجودة أسفل الغطاء الأسود، إذا كانت مصممة للإزالة بواسطة المستخدم.",
                illustrationAsset: "oven_lifting_step3"
            ),
            SolutionStep(
                order: 4,
                title: "فحص حساس الأمان",
                text: "حدد مكان حساس الأمان، وهو عادةً قطعة معدنية صغيرة بجوار الشعلة، وتحقق من وجود أوساخ أو ترسبات حوله.",
                illustrationAsset: "oven_safety_step4"
            ),
            SolutionStep(
                order: 5,
                title: "تنظيف الأجزاء",
                text: "استخدم فرشاة ناعمة غير معدنية لإزالة الأوساخ والترسبات الظاهرة، وفق تعليمات دليل الموقد.",
                illustrationAsset: "oven_clean_step5",
                warning: "تجنب استخدام ورق الصنفرة على حساس الأمان ما لم تسمح الشركة المصنّعة بذلك، ولا تحاول ثنيه أو فكه."
            ),
            SolutionStep(
                order: 6,
                title: "إعادة تركيب الأجزاء",
                text: "بعد التأكد من جفاف الأجزاء تمامًا، أعد القطعة المعدنية والغطاء الأسود إلى مواضعهما الصحيحة."
            ),
            SolutionStep(
                order: 7,
                title: "اختبار الشعلة",
                text: "شغّل عين الموقد وفق تعليمات الجهاز، واستمر بالضغط على المقبض للمدة المحددة في الدليل، ثم تأكد من استمرار اشتعال الشعلة بعد تركه.",
                warning: "إذا استمرت المشكلة، أوقف استخدام العين واستعن بفني مختص لفحص حساس الأمان."
            )
        ]
    )

    static let ovenWeakFlame = DiagnosisProblem(
        id: "oven-weak-flame",
        title: "نار العين ضعيفة أو تقطع",
        description: "تكون شعلة عين الموقد أضعف من المعتاد أو تشتعل بشكل غير منتظم، وقد يكون السبب تراكم الأوساخ أو انسداد فتحات الشعلة.",
        illustrationAsset: "oven_weak_flame",
        questions: [
            DiagnosisQuestion(id: "oven-weak-flame-q1", text: "هل شعلة عين الموقد ضعيفة مقارنة بالمعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "oven-weak-flame-q2", text: "هل تلاحظ أن النار تخرج بشكل غير منتظم أو تنقطع من بعض فتحات العين؟", expectedAnswer: true),
            DiagnosisQuestion(id: "oven-weak-flame-q3", text: "هل تظهر المشكلة في عين واحدة بينما تعمل بقية عيون الموقد بشكل طبيعي؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إغلاق مصدر الغاز",
                text: "أغلق جميع مقابض الموقد، ثم أغلق محبس الغاز الرئيسي قبل البدء بالتنظيف."
            ),
            SolutionStep(
                order: 2,
                title: "التأكد من برودة الموقد",
                text: "انتظر حتى تبرد عين الموقد وجميع أجزائها تمامًا."
            ),
            SolutionStep(
                order: 3,
                title: "إزالة أجزاء عين الموقد",
                text: "ارفع الغطاء الأسود، ثم أزل القطعة المعدنية الموجودة أسفله برفق، إذا كانت قابلة للإزالة حسب تصميم الموقد.",
                illustrationAssets: ["ovenn_prob3_step3", "oven_prob3_step3"]
            ),
            SolutionStep(
                order: 4,
                title: "تنظيف القطع المعدنية",
                text: "نظّف الغطاء والقطعة المعدنية باستخدام فرشاة ناعمة ومنظف مناسب لإزالة الدهون والأوساخ والترسبات المتراكمة.",
                illustrationAsset: "oven_prob3_step4"
            ),
            SolutionStep(
                order: 5,
                title: "تنظيف فتحات الشعلة",
                text: "افحص الفتحات الصغيرة المحيطة بعين الموقد. إذا كانت مسدودة، نظّفها برفق شديد وفق تعليمات الشركة المصنّعة.",
                illustrationAsset: "oven_prob3_step5",
                warning: "تسمح بعض الطرازات باستخدام إبرة رفيعة لتنظيف هذه الفتحات، دون توسيعها أو تغيير شكلها."
            ),
            SolutionStep(
                order: 6,
                title: "إعادة تركيب الأجزاء",
                text: "تأكد من جفاف القطع تمامًا، ثم أعد القطعة المعدنية والغطاء الأسود إلى أماكنهما الصحيحة، مع التأكد من ثباتهما."
            ),
            SolutionStep(
                order: 7,
                title: "إعادة تشغيل الغاز",
                text: "بعد التأكد من سلامة الأجزاء وتركيبها، افتح محبس الغاز الرئيسي، ثم شغّل عين الموقد بالطريقة المعتادة وتحقق من انتظام الشعلة."
            )
        ]
    )

    // MARK: Problems — Vacuum Cleaners

    static let vacuumLoudNoise = DiagnosisProblem(
        id: "vacuum-loud-noise",
        title: "ارتفاع صوت المكنسة بسبب انسداد مسار الهواء",
        description: "تصدر المكنسة صوتًا أعلى من المعتاد أثناء التشغيل، وقد يكون السبب انسداد مسار الهواء نتيجة تراكم الغبار أو الأوساخ.",
        illustrationAsset: "vacuum_loud_noise",
        questions: [
            DiagnosisQuestion(id: "vacuum-loud-noise-q1", text: "هل أصبح صوت المكنسة أعلى من المعتاد أثناء التشغيل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "vacuum-loud-noise-q2", text: "هل لاحظت ضعفًا في قوة الشفط بالتزامن مع ارتفاع الصوت؟", expectedAnswer: true),
            DiagnosisQuestion(id: "vacuum-loud-noise-q3", text: "هل توجد أوساخ متراكمة أو انسدادات ظاهرة في حاوية الغبار أو الخرطوم أو رأس المكنسة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "أوقف تشغيل المكنسة وافصل القابس من مصدر الكهرباء قبل البدء بالفحص."
            ),
            SolutionStep(
                order: 2,
                title: "فحص مسار الهواء",
                text: "افحص حاوية الغبار والخرطوم ورأس المكنسة والفلتر، بحثًا عن الأوساخ أو الأجسام التي قد تعيق مرور الهواء.",
                illustrationAsset: "Vacuum_clean_step2",
            ),
            SolutionStep(
                order: 3,
                title: "إزالة الأوساخ والانسدادات",
                text: "أفرغ حاوية الغبار، وأزل الأوساخ والانسدادات الظاهرة من الأجزاء التي يسمح دليل الجهاز بتنظيفها.",
                illustrationAsset: "Vacuum_clean_step3",
            ),
            SolutionStep(
                order: 4,
                title: "إعادة تركيب الأجزاء",
                text: "تأكد من جفاف الأجزاء التي غُسلت تمامًا، ثم أعد تركيب الحاوية والخرطوم والفلتر ورأس المكنسة بشكل صحيح."
            ),
            SolutionStep(
                order: 5,
                title: "اختبار المكنسة",
                text: "شغّل المكنسة لفترة قصيرة، وتحقق من عودة الصوت إلى مستواه المعتاد وتحسن قوة الشفط.",
                warning: "إذا استمر الصوت المرتفع، أو ظهرت رائحة احتراق أو سخونة غير طبيعية، فأوقف المكنسة وافصلها عن الكهرباء، واستعن بفني مختص."
            )
        ]
    )

    static let vacuumDirtyFilter = DiagnosisProblem(
        id: "vacuum-dirty-filter",
        title: "اتساخ فلتر المكنسة الكهربائية",
        description: "قد يؤدي تراكم الغبار والأوساخ داخل فلتر المكنسة إلى تقليل تدفق الهواء وإضعاف قوة الشفط.",
        illustrationAsset: "vacuum_dirty_filter",
        questions: [
            DiagnosisQuestion(id: "vacuum-dirty-filter-q1", text: "هل أصبحت قوة شفط المكنسة أضعف من المعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "vacuum-dirty-filter-q2", text: "هل تلاحظ تراكم الغبار أو الأوساخ على فلتر المكنسة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "vacuum-dirty-filter-q3", text: "هل لا يزال الشفط ضعيفًا رغم تفريغ حاوية الغبار والتأكد من عدم انسداد الخرطوم؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "أوقف تشغيل المكنسة وافصل القابس من مصدر الكهرباء قبل البدء بالتنظيف."
            ),
            SolutionStep(
                order: 2,
                title: "تحديد مكان الفلتر",
                text: "راجع دليل المكنسة لمعرفة موقع الفلتر وطريقة إخراجه، ثم أزله برفق وفق التعليمات."
                
            ),
            SolutionStep(
                order: 3,
                title: "إزالة الغبار المتراكم",
                text: "أزل الغبار والأوساخ باستخدام فرشاة ناعمة أو بالطريقة المناسبة لنوع الفلتر، دون إتلاف طبقاته.",
                illustrationAsset: "Vacuum_clean_step3",
            ),
            SolutionStep(
                order: 4,
                title: "غسل الفلتر عند السماح بذلك",
                text: "إذا كان الفلتر قابلًا للغسل، نظّفه بالماء وفق تعليمات الشركة المصنّعة. أما إذا كان غير قابل للغسل، فاكتفِ بطريقة التنظيف المسموح بها أو استبدله عند الحاجة."
            ),
            SolutionStep(
                order: 5,
                title: "تجفيف الفلتر",
                text: "اترك الفلتر المغسول حتى يجف تمامًا، مع الالتزام بمدة التجفيف المحددة في دليل المكنسة."
            ),
            SolutionStep(
                order: 6,
                title: "إعادة التركيب واختبار الشفط",
                text: "أعد الفلتر إلى مكانه بشكل صحيح، ثم شغّل المكنسة وتحقق من تحسن قوة الشفط.",
                warning: "لا تغسل الفلاتر غير القابلة للغسل، ولا تشغّل المكنسة بفلتر رطب أو دون الفلاتر المطلوبة."
            )
        ]
    )

    static let vacuumCloggedHose = DiagnosisProblem(
        id: "vacuum-clogged-hose",
        title: "انسداد خرطوم المكنسة أو رأسها",
        description: "قد تتجمع الأوساخ أو الأجسام الصغيرة داخل خرطوم المكنسة أو رأسها، مما يعيق مرور الهواء ويضعف قوة الشفط.",
        illustrationAsset: "vacuum_clogged_hose",
        questions: [
            DiagnosisQuestion(id: "vacuum-clogged-hose-q1", text: "هل أصبحت قوة شفط المكنسة أضعف من المعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "vacuum-clogged-hose-q2", text: "هل توجد أوساخ أو أجسام عالقة داخل الخرطوم أو في فتحات رأس المكنسة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "vacuum-clogged-hose-q3", text: "هل يستمر ضعف الشفط رغم تفريغ حاوية الغبار والتأكد من نظافة الفلتر؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "أوقف تشغيل المكنسة وافصل القابس من مصدر الكهرباء قبل البدء بالفحص."
            ),
            SolutionStep(
                order: 2,
                title: "فصل الخرطوم ورأس المكنسة",
                text: "افصل الخرطوم ورأس المكنسة برفق، إذا كانا قابلين للفصل، وفق تعليمات الجهاز."
            ),
            SolutionStep(
                order: 3,
                title: "فحص أماكن الانسداد",
                text: "افحص الخرطوم من طرفيه، وتحقق من فتحات رأس المكنسة بحثًا عن الأوساخ أو الشعر أو الأجسام العالقة.",
                illustrationAsset: "Vacuum_clean_step2",
            ),
            SolutionStep(
                order: 4,
                title: "إزالة الانسداد",
                text: "أزل الأوساخ والأجسام العالقة برفق باستخدام أداة تنظيف مناسبة غير حادة، مع تجنب دفعها إلى داخل الخرطوم أو إتلاف أجزائه."
            ),
            SolutionStep(
                order: 5,
                title: "إعادة تركيب الأجزاء",
                text: "بعد التأكد من إزالة الانسداد، أعد توصيل الخرطوم ورأس المكنسة وتحقق من تثبيتهما بإحكام."
            ),
            SolutionStep(
                order: 6,
                title: "اختبار قوة الشفط",
                text: "شغّل المكنسة لفترة قصيرة، وتحقق من عودة قوة الشفط إلى مستواها الطبيعي.",
                warning: "تجنب استخدام الأدوات الحادة أو المعدنية التي قد تثقب الخرطوم أو تتلف الأجزاء الداخلية. وإذا تعذر إخراج جسم عالق، فلا تحاول دفعه بالقوة."
            )
        ]
    )

    // MARK: Problems — Water Heaters

    static let heaterInstall = DiagnosisProblem(
        id: "heater-install",
        title: "تركيب السخان",
        description: "عند شراء سخان مياه جديد أو استبدال السخان القديم، يحتاج الجهاز إلى تركيب وتوصيل آمن بمصادر المياه والكهرباء لضمان عمله بشكل صحيح.",
        illustrationAsset: "heater_install",
        questions: [
            DiagnosisQuestion(id: "heater-install-q1", text: "هل لديك سخان مياه جديد أو بديل لم يتم تركيبه بعد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "heater-install-q2", text: "هل المكان المخصص لتركيب السخان مجهز بتوصيلات المياه الباردة والساخنة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "heater-install-q3", text: "هل تحتاج إلى تركيب السخان وتوصيله بمصادر المياه والكهرباء لأول مرة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "تجهيز السخان وملحقاته",
                text: "أزل التغليف عن السخان، وتأكد من وجود الوصلات المرفقة معه، وحدد مدخل الماء البارد المميز عادةً بالأزرق، ومخرج الماء الساخن المميز بالأحمر، بالإضافة إلى مفتاح التحكم بدرجة الحرارة.",
                illustrationAsset: "heater_step1",
                warning: "تنفيذ التركيب والتوصيلات يكون بواسطة فني مؤهل ووفق دليل الطراز."
            ),
            SolutionStep(
                order: 2,
                title: "تجهيز وصلات المياه",
                text: "تحقق من نوع الوصلات وتأكد من وجدها ، ويستخدم شريط التفلون على الوصلات الملولبة التي تتطلبه وفق تعليمات الشركة المصنّعة.",
                illustrationAsset: "heater_step2"
            ),
            SolutionStep(
                order: 3,
                title: "تركيب الوصلات",
                text: "ركب الوصلات والصمامات المخصصة لمدخل الماء البارد ومخرج الماء الساخن، مع التأكد من توافقها مع السخان. ويُركّب صمام تخفيف الضغط والحرارة وتصريفه إذا كان مطلوبًا للطراز.",
                illustrationAsset: "heater_step3"
            ),
            SolutionStep(
                order: 4,
                title: "توصيل خراطيم المياه",
                text: "تُوصل خراطيم التغذية المناسبة بمدخل الماء البارد ومخرج الماء الساخن، مع التأكد من إحكام التوصيلات بالطريقة المحددة في دليل الجهاز.",
                illustrationAsset: "heater_step4"
            ),
            SolutionStep(
                order: 5,
                title: "تثبيت السخان على الجدار",
                text: "حدد موضع التركيب المناسب، وتحقق من قدرة الجدار على تحمّل وزن السخان وهو ممتلئ بالماء، ثم ثبت الحوامل والمسامير المعتمدة ويركب السخان عليها.",
                illustrationAsset: "heater_step5",
                warning: "قد يؤدي التثبيت غير الصحيح إلى سقوط السخان وحدوث إصابات أو تلف."
            ),
            SolutionStep(
                order: 6,
                title: "توصيل مصادر المياه",
                text: "وصل مدخل الماء البارد بمصدر المياه المخصص له، ومخرج الماء الساخن بشبكة المياه الساخنة.",
                illustrationAsset: "heater_step6"
            ),
            SolutionStep(
                order: 7,
                title: "تعبئة السخان وتفريغ الهواء",
                text: "مع بقاء الكهرباء مفصولة، يُفتح محبس الماء البارد وأحد صنابير الماء الساخن، ويُترك الماء يتدفق حتى يخرج بانتظام دون هواء، مما يساعد على التأكد من امتلاء الخزان."
            ),
            SolutionStep(
                order: 8,
                title: "فحص التسريبات",
                text: "تحقق من إحكام التوصيلات وعدم وجود تسريب عند مداخل المياه ومخارجها والصمامات."
            ),
            SolutionStep(
                order: 9,
                title: "توصيل الكهرباء",
                text: "بعد التأكد من امتلاء الخزان وسلامة التوصيلات، قم بتوصيل السخان بمصدر الكهرباء المناسب."
            ),
            SolutionStep(
                order: 10,
                title: "ضبط درجة الحرارة",
                text: "بعد تشغيل السخان، اضبط درجة حرارة المياه باستخدام مقبض التحكم المخصص حسب تعليمات الجهاز، مع تجنب درجات الحرارة المرتفعة التي قد تسبب الحروق.",
                illustrationAsset: "heater_step10"
            )
        ]
    )

    static let heaterValveReplace = DiagnosisProblem(
        id: "heater-valve",
        title: "تغيير البلف",
        description: "قد يحتاج بلف السخان إلى الاستبدال عند حدوث تسريب للماء منه أو ظهور خلل في عمله، مما قد يؤثر على سلامة السخان.\n\nالتسرب وحده لا يؤكد وجود عطل؛ فبعض صمامات الأمان تصرّف الماء عند ارتفاع الضغط أو الحرارة.",
        illustrationAsset: "heater_valve",
        questions: [
            DiagnosisQuestion(id: "heater-valve-q1", text: "هل تلاحظ تسرب الماء من البلف الموجود عند مدخل الماء البارد للسخان؟", expectedAnswer: true),
            DiagnosisQuestion(id: "heater-valve-q2", text: "هل يستمر التسرب حتى بعد التأكد من سلامة وصلة الخرطوم وعدم وجود تسريب منها؟", expectedAnswer: true),
            DiagnosisQuestion(id: "heater-valve-q3", text: "هل يظهر على البلف تلف واضح، مثل تشقق أو صدأ شديد أو تسرب من جسمه؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء",
                text: "افصل التيار الكهربائي عن السخان من القاطع المخصص له، وتأكد من توقفه عن العمل."
            ),
            SolutionStep(
                order: 2,
                title: "إغلاق مصدر المياه",
                text: "أغلق محبس الماء المغذي للسخان، وانتظر حتى تبرد المياه لتجنب الحروق."
            ),
            SolutionStep(
                order: 3,
                title: "فصل خرطوم الماء البارد",
                text: "افصل الخرطوم الماء البارد المتصل بالبلف باستخدام الأداة المناسبة.",
                illustrationAsset: "Disconnecting_step3"
            ),
            SolutionStep(
                order: 4,
                title: "استبدال البلف",
                text: "افصل البلف القديم ويركب بلفًا جديدًا مطابقًا لمواصفات السخان، مع مراعاة اتجاه التركيب ومتطلبات الإحكام."
            ),
            SolutionStep(
                order: 5,
                title: "إعادة تركيب الخرطوم",
                text: "اعد توصيل خرطوم الماء البارد بالبلف الجديد، وتأكد من تثبيت جميع الوصلات بصورة صحيحة."
            ),
            SolutionStep(
                order: 6,
                title: "فحص التسريب",
                text: "يُعاد فتح مصدر المياه، ثم يُفحص البلف والوصلات للتأكد من عدم وجود تسريب، مع تفريغ الهواء والتأكد من امتلاء السخان قبل إعادة تشغيل الكهرباء."
            )
        ]
    )

    static let heaterWeakHotWater = DiagnosisProblem(
        id: "heater-weak-hot-water",
        title: "ضعف المياه الساخنة في السخان",
        description: "يكون تدفق الماء الساخن من الصنبور أضعف من المعتاد، وقد يكون السبب انسداد خرطوم المياه أو أحد الصمامات المتصلة بالسخان.\n\nيحتاج السبب إلى فحص قبل تحديد القطعة التي يجب استبدالها.",
        illustrationAsset: "heater_weak_hot_water",
        questions: [
            DiagnosisQuestion(id: "heater-weak-hot-water-q1", text: "هل تدفق الماء الساخن من الصنبور أضعف من المعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "heater-weak-hot-water-q2", text: "هل يتدفق الماء البارد بضغط طبيعي مقارنة بالماء الساخن؟", expectedAnswer: true),
            DiagnosisQuestion(id: "heater-weak-hot-water-q3", text: "هل يظهر ضعف تدفق الماء الساخن في أكثر من صنبور متصل بالسخان؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فصل الكهرباء وإغلاق الماء",
                text: "افصل الكهرباء عن السخان من القاطع المخصص له، ثم أغلق محبس الماء البارد وانتظر حتى تبرد المياه."
            ),
            SolutionStep(
                order: 2,
                title: "فحص محبس الماء",
                text: "تأكد من أن محبس الماء البارد المغذي للسخان مفتوح بالكامل أثناء الاستخدام، وأن خرطوم المياه لا يحتوي على التواءات أو انثناءات ظاهرة."
            ),
            SolutionStep(
                order: 3,
                title: "فحص خرطوم الماء البارد",
                text: "بعد فصل الكهرباء وإغلاق المياه وتخفيف الضغط، يفصل الفني خرطوم الماء البارد المتصل بالسخان لفحصه والتأكد من عدم وجود انسداد أو تلف داخله."
            ),
            SolutionStep(
                order: 4,
                title: "التحقق من تدفق المياه",
                text: "يفحص الفني تدفق المياه من مصدر التغذية باستخدام وعاء مناسب، وفق إجراءات السلامة وتعليمات الجهاز، لتحديد ما إذا كان ضعف التدفق ناتجًا عن مصدر المياه أو التوصيلات."
            ),
            SolutionStep(
                order: 5,
                title: "فحص الصمام والخرطوم",
                text: "إذا كان تدفق المياه من المصدر طبيعيًا، يفحص الفني الصمام والخرطوم وفلتر المدخل إن وجد، للتأكد من عدم وجود انسداد أو تلف."
            ),
            SolutionStep(
                order: 6,
                title: "استبدال الجزء المتضرر",
                text: "إذا ثبت وجود انسداد لا يمكن تنظيفه أو تلف في الخرطوم أو الصمام، يستبدل الفني الجزء المتضرر بقطعة متوافقة مع مواصفات السخان."
            ),
            SolutionStep(
                order: 7,
                title: "إعادة تركيب التوصيلات",
                text: "يعيد الفني تركيب خرطوم الماء البارد، ويتأكد من تثبيت الوصلات بإحكام وبالطريقة الصحيحة."
            ),
            SolutionStep(
                order: 8,
                title: "إعادة تشغيل المياه وفحص التدفق",
                text: "يُفتح محبس الماء البارد، ويُفرّغ الهواء عبر صنبور الماء الساخن حتى يتدفق الماء بانتظام، ثم تُفحص التوصيلات للتأكد من عدم وجود تسريب.",
                warning: "لا تُعاد الكهرباء إلا بعد التأكد من امتلاء خزان السخان بالماء."
            )
        ]
    )

    // MARK: Problems — Lighting

    static let bulbBurnt = DiagnosisProblem(
        id: "lighting-bulb-burnt",
        title: "اللمبة محترقة ولا تضيء",
        description: "",
        illustrationAsset: "lighting_bulb_burnt",
        questions: [
            DiagnosisQuestion(id: "lighting-bulb-burnt-q1", text: "هل اللمبة لا تضيء عند تشغيل مفتاح الإنارة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-burnt-q2", text: "هل تعمل بقية الأنوار في الغرفة بشكل طبيعي؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-burnt-q3", text: "هل لا توجد رائحة احتراق أو آثار تلف على وحدة الإنارة؟", expectedAnswer: true, isSafetyCritical: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "أطفئ المفتاح واترك اللمبة تبرد", text: "إطفاء مفتاح الإنارة وترك اللمبة تبرد."),
            SolutionStep(order: 2, title: "فك اللمبة القديمة", text: "فك اللمبة القديمة بالطريقة المناسبة لنوعها."),
            SolutionStep(order: 3, title: "ركّب لمبة جديدة", text: "تركيب لمبة جديدة متوافقة مع وحدة الإنارة."),
            SolutionStep(order: 4, title: "شغّل المفتاح واختبرها", text: "تشغيل المفتاح واختبارها.")
        ]
    )

    static let bulbFlickering = DiagnosisProblem(
        id: "lighting-bulb-flickering",
        title: "اللمبة تومض باستمرار",
        description: "",
        illustrationAsset: "lighting_bulb_flickering",
        questions: [
            DiagnosisQuestion(id: "lighting-bulb-flickering-q1", text: "هل تومض اللمبة بشكل متكرر أثناء تشغيلها؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-flickering-q2", text: "هل تعمل بقية الأنوار في الغرفة بشكل طبيعي؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-flickering-q3", text: "هل لا توجد رائحة احتراق أو سخونة غير طبيعية أو أصوات طقطقة؟", expectedAnswer: true, isSafetyCritical: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "أطفئ الإنارة وانتظر", text: "إطفاء الإنارة والانتظار حتى تبرد اللمبة."),
            SolutionStep(order: 2, title: "استبدل اللمبة", text: "استبدالها بلمبة جديدة متوافقة."),
            SolutionStep(order: 3, title: "راقب استمرار الوميض", text: "إذا استمر الوميض، فقد تكون المشكلة في وحدة الإنارة أو التوصيلات؛ عندها يجب إيقاف الاستخدام والاستعانة بكهربائي مختص.")
        ]
    )

    static let bulbMismatch = DiagnosisProblem(
        id: "lighting-bulb-mismatch",
        title: "اللمبة الجديدة لا تناسب وحدة الإنارة",
        description: "",
        illustrationAsset: "lighting_bulb_mismatch",
        questions: [
            DiagnosisQuestion(id: "lighting-bulb-mismatch-q1", text: "هل اشتريت لمبة جديدة لاستبدال القديمة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-mismatch-q2", text: "هل قاعدة اللمبة الجديدة لا تتناسب مع وحدة الإنارة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-mismatch-q3", text: "هل يمكنك قراءة مواصفات اللمبة المناسبة من ملصق وحدة الإنارة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "اقرأ مواصفات وحدة الإنارة", text: "قراءة نوع القاعدة والقدرة المسموح بها على ملصق وحدة الإنارة."),
            SolutionStep(order: 2, title: "اشترِ لمبة مطابقة", text: "شراء لمبة بنفس نوع القاعدة وبقدرة متوافقة."),
            SolutionStep(order: 3, title: "ركّب اللمبة بأمان", text: "تركيب اللمبة بعد إطفاء مفتاح الإنارة والتأكد من برودتها.")
        ]
    )

    static let bulbDim = DiagnosisProblem(
        id: "lighting-bulb-dim",
        title: "إضاءة اللمبة ضعيفة",
        description: "",
        illustrationAsset: "lighting_bulb_dim",
        questions: [
            DiagnosisQuestion(id: "lighting-bulb-dim-q1", text: "هل إضاءة اللمبة أضعف من المعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-dim-q2", text: "هل ما زالت اللمبة تعمل ولكنها لا تعطي إضاءة كافية؟", expectedAnswer: true),
            DiagnosisQuestion(id: "lighting-bulb-dim-q3", text: "هل يوجد غبار أو اتساخ ظاهر على الغطاء الخارجي لوحدة الإنارة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "أطفئ الإنارة وافصل الكهرباء", text: "إطفاء الإنارة وفصل الكهرباء قبل التنظيف."),
            SolutionStep(order: 2, title: "نظّف الغطاء الخارجي", text: "تنظيف الغطاء الخارجي إذا كان قابلًا للإزالة والتنظيف بأمان."),
            SolutionStep(order: 3, title: "جرّب لمبة جديدة", text: "تجربة لمبة جديدة متوافقة إذا استمرت الإضاءة الضعيفة."),
            SolutionStep(order: 4, title: "اطلب فحص وحدة الإنارة", text: "إذا بقيت الإضاءة ضعيفة، يجب فحص وحدة الإنارة لدى مختص.")
        ]
    )

    // MARK: Problems — Outlets

    static let deviceNotWorking = DiagnosisProblem(
        id: "outlets-device-not-working",
        title: "الجهاز لا يعمل عند توصيله بالكهرباء",
        description: "",
        illustrationAsset: "outlets_device_not_working",
        questions: [
            DiagnosisQuestion(id: "outlets-device-not-working-q1", text: "هل الجهاز لا يعمل عند توصيله بالمقبس؟", expectedAnswer: true),
            DiagnosisQuestion(id: "outlets-device-not-working-q2", text: "هل تأكدت من تشغيل الجهاز وتوصيله بالطريقة الصحيحة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "outlets-device-not-working-q3", text: "هل يعمل الجهاز عند تجربته في مقبس آخر سليم وجاف؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "تأكد من التشغيل والتوصيل", text: "التأكد من تشغيل الجهاز وتوصيله بالطريقة الصحيحة."),
            SolutionStep(order: 2, title: "افحص القابس", text: "فصل القابس وفحصه بصريًا بحثًا عن تلف، دون لمس الأجزاء المعدنية المتضررة."),
            SolutionStep(order: 3, title: "جرّب مقبسًا آخر", text: "تجربة الجهاز في مقبس آخر سليم وجاف، بشرط عدم وجود أي علامات خطر."),
            SolutionStep(order: 4, title: "اطلب فحص المقبس", text: "إذا عمل الجهاز في المقبس الآخر، فقد يحتاج المقبس الأول إلى فحص كهربائي مختص.")
        ]
    )

    static let plugHot = DiagnosisProblem(
        id: "outlets-plug-hot",
        title: "القابس أو التوصيلة ساخنة بشكل غير طبيعي",
        description: "",
        illustrationAsset: "outlets_plug_hot",
        questions: [
            DiagnosisQuestion(id: "outlets-plug-hot-q1", text: "هل لاحظت سخونة غير طبيعية في القابس أو التوصيلة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "outlets-plug-hot-q2", text: "هل تستمر السخونة أثناء استخدام الجهاز؟", expectedAnswer: true),
            DiagnosisQuestion(id: "outlets-plug-hot-q3", text: "هل لاحظت تغيرًا في لون البلاستيك أو تشوهًا في القابس أو التوصيلة؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "توقف عن الاستخدام", text: "التوقف عن استخدام الجهاز والتوصيلة."),
            SolutionStep(order: 2, title: "لا تلمس القابس الساخن", text: "عدم لمس القابس إذا كان شديد السخونة أو يصدر شررًا."),
            SolutionStep(order: 3, title: "افصل الكهرباء من القاطع", text: "فصل الكهرباء من القاطع المناسب إذا أمكن ذلك بأمان."),
            SolutionStep(order: 4, title: "استبدل التوصيلة واطلب فحصًا", text: "استبدال التوصيلة المتضررة، وطلب فحص المقبس لدى كهربائي قبل إعادة استخدامه.")
        ]
    )

    static let outletSparks = DiagnosisProblem(
        id: "outlets-sparks",
        title: "وجود شرر عند توصيل القابس",
        description: "",
        illustrationAsset: "outlets_sparks",
        questions: [
            DiagnosisQuestion(id: "outlets-sparks-q1", text: "هل لاحظت شررًا عند توصيل القابس بالمقبس؟", expectedAnswer: true),
            DiagnosisQuestion(id: "outlets-sparks-q2", text: "هل تكرر الشرر أو صاحبه صوت طقطقة؟", expectedAnswer: true),
            DiagnosisQuestion(id: "outlets-sparks-q3", text: "هل لاحظت رائحة احتراق أو آثارًا سوداء حول المقبس؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "لا تكرر التوصيل", text: "عدم تكرار توصيل القابس لاختبار المشكلة."),
            SolutionStep(order: 2, title: "ابتعد عن المقبس", text: "إذا تكرر الشرر أو صاحبه صوت طقطقة أو رائحة احتراق، يجب الابتعاد عن المقبس وعدم لمسه."),
            SolutionStep(order: 3, title: "افصل الدائرة من القاطع", text: "فصل الدائرة من القاطع إذا أمكن ذلك بأمان."),
            SolutionStep(order: 4, title: "اطلب كهربائيًا مختصًا", text: "طلب كهربائي مختص لفحص المقبس والجهاز قبل إعادة استخدامهما.")
        ]
    )

    // MARK: Problems — Breakers

    static let oneRoomOutage = DiagnosisProblem(
        id: "breakers-one-room-outage",
        title: "انقطاع الكهرباء عن غرفة واحدة",
        description: "",
        illustrationAsset: "breakers_one_room_outage",
        questions: [
            DiagnosisQuestion(id: "breakers-one-room-outage-q1", text: "هل انقطعت الكهرباء عن غرفة واحدة فقط؟", expectedAnswer: true),
            DiagnosisQuestion(id: "breakers-one-room-outage-q2", text: "هل تعمل الكهرباء في بقية غرف المنزل بشكل طبيعي؟", expectedAnswer: true),
            DiagnosisQuestion(id: "breakers-one-room-outage-q3", text: "هل لا توجد رائحة احتراق أو أصوات طقطقة قرب لوحة القواطع؟", expectedAnswer: true, isSafetyCritical: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "حدد ما انقطع في الغرفة", text: "التأكد مما إذا كانت المشكلة تشمل الإنارة والمقابس في الغرفة أو أحدهما فقط."),
            SolutionStep(order: 2, title: "تأكد أن المشكلة في الغرفة فقط", text: "التحقق من أن المشكلة محصورة في الغرفة، بينما تعمل الكهرباء في بقية المنزل."),
            SolutionStep(order: 3, title: "افحص لوحة القواطع", text: "فحص لوحة القواطع من الخارج بحثًا عن قاطع مفصول."),
            SolutionStep(order: 4, title: "أعد القاطع مرة واحدة", text: "إذا كان القاطع مفصولًا ولا توجد علامات خطر، يمكن إعادته مرة واحدة وفق تعليمات اللوحة."),
            SolutionStep(order: 5, title: "تواصل مع كهربائي مختص", text: "إذا لم تعد الكهرباء أو فصل القاطع مجددًا، يجب التواصل مع كهربائي مختص.")
        ]
    )

    static let wholeHouseOutage = DiagnosisProblem(
        id: "breakers-whole-house-outage",
        title: "انقطاع الكهرباء عن المنزل بالكامل",
        description: "",
        illustrationAsset: "breakers_whole_house_outage",
        questions: [
            DiagnosisQuestion(id: "breakers-whole-house-outage-q1", text: "هل انقطعت الكهرباء عن جميع غرف المنزل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "breakers-whole-house-outage-q2", text: "هل توقفت الإنارة والأجهزة عن العمل في المنزل بالكامل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "breakers-whole-house-outage-q3", text: "هل لا توجد رائحة احتراق أو أصوات غير طبيعية قرب لوحة القواطع؟", expectedAnswer: true, isSafetyCritical: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "تأكد من شمول الانقطاع للمنزل", text: "التأكد من أن الانقطاع يشمل المنزل بالكامل، وليس غرفة واحدة فقط."),
            SolutionStep(order: 2, title: "تحقق من المنازل المجاورة", text: "التحقق مما إذا كانت المنازل المجاورة أو إنارة الشارع متأثرة."),
            SolutionStep(order: 3, title: "أطفئ الأجهزة عالية الاستهلاك", text: "إطفاء الأجهزة ذات الاستهلاك العالي، مثل المكيفات، لحماية الأجهزة عند عودة الكهرباء."),
            SolutionStep(order: 4, title: "أبلغ شركة الكهرباء", text: "إذا كان الانقطاع عامًا، التواصل مع الشركة السعودية للكهرباء على الرقم 933 للإبلاغ عن انقطاع الخدمة."),
            SolutionStep(order: 5, title: "استعن بكهربائي مختص", text: "إذا كان الانقطاع في المنزل وحده ولم تُحل المشكلة بعد التحقق من القواطع، يجب الاستعانة بكهربائي مختص.")
        ]
    )

    static let clickingBurningSmell = DiagnosisProblem(
        id: "breakers-clicking-burning-smell",
        title: "انقطاع الكهرباء مع صدور صوت طقطقة أو رائحة احتراق",
        description: "",
        illustrationAsset: "breakers_clicking_burning_smell",
        questions: [
            DiagnosisQuestion(id: "breakers-clicking-burning-smell-q1", text: "هل انقطعت الكهرباء بالتزامن مع صوت طقطقة أو رائحة احتراق؟", expectedAnswer: true),
            DiagnosisQuestion(id: "breakers-clicking-burning-smell-q2", text: "هل يصدر الصوت أو تظهر الرائحة بالقرب من لوحة القواطع أو أحد المقابس؟", expectedAnswer: true),
            DiagnosisQuestion(id: "breakers-clicking-burning-smell-q3", text: "هل لاحظت آثار احتراق أو دخانًا بالقرب من مصدر الكهرباء؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(order: 1, title: "لا تلمس لوحة القواطع أو المقبس", text: "عدم لمس لوحة القواطع أو المقبس المتضرر."),
            SolutionStep(order: 2, title: "ابتعد عن المنطقة", text: "الابتعاد عن المنطقة وعدم محاولة إعادة تشغيل القاطع."),
            SolutionStep(order: 3, title: "اطلب كهربائيًا بصورة عاجلة", text: "طلب كهربائي مختص بصورة عاجلة."),
            SolutionStep(order: 4, title: "اتصل بالطوارئ عند ظهور دخان", text: "إذا ظهر دخان أو اندلع حريق، يجب الابتعاد عن المكان والاتصال بالطوارئ.")
        ]
    )

    // MARK: Problems — Water

    static let faucetLeak = DiagnosisProblem(
        id: "faucet-leak",
        title: "تسرب الصنبور",
        description: "تسرّب الماء من الصنبور على شكل قطرات مستمرة",
        illustrationAsset: "water_faucet_leak_icon",
        questions: [
            DiagnosisQuestion(id: "faucet-leak-q1", text: "هل تخرج قطرات ماء من فوهة الصنبور رغم إغلاقه بالكامل؟", expectedAnswer: true),
            DiagnosisQuestion(id: "faucet-leak-q2", text: "هل يستمر تقطير الماء بعد مرور عدة دقائق من إغلاق الصنبور؟", expectedAnswer: true),
            DiagnosisQuestion(id: "faucet-leak-q3", text: "هل يتكرر تسرب الماء عند استخدام الصنبور وإغلاقه مرة أخرى؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إغلاق مصدر الماء",
                text: "أغلق محبسي الماء البارد والساخن أسفل المغسلة، ثم افتح الصنبور لتخفيف الضغط والتأكد من توقف الماء",
                illustrationAsset: "leakingـfaucet_step1"
            ),
            SolutionStep(
                order: 2,
                title: "فك مقبض الصنبور",
                text: "1. أزل الغطاء الدائري الصغير الموجود على جانب المقبض، إن وُجد.\n2. أدخل مفتاح ألن المناسب ولفّه عكس عقارب الساعة حتى يرتخي مسمار التثبيت.\n3. اسحب المقبض برفق لإزالته.",
                illustrationAsset: "leakingـfaucet_step2",
                warning: "لا تحتاج لإخراج المسمار بالكامل، ولا تسحب المقبض بالقوة إذا لم يتحرك."
            ),
            SolutionStep(
                order: 3,
                title: "إزالة الخرطوشة القديمة",
                text: "1. أزل الغطاء المعدني الداخلي، إن وُجد.\n2. فُكّ صامولة تثبيت الخرطوشة عكس عقارب الساعة باستخدام مفتاح مناسب، إذا كان طراز الصنبور يحتوي عليها.\n3. امسك الجزء العلوي من الخرطوشة واسحبها للأعلى برفق.\n4. لاحظ اتجاه الخرطوشة قبل إخراجها لتسهيل تركيب الجديدة.",
                illustrationAsset: "leakingـfaucet_step3",
                warning: "إذا لم تتحرك الخرطوشة، فلا تحاول لفّها أو سحبها بالقوة. راجع دليل الصنبور لمعرفة طريقة تثبيتها."
            ),
            SolutionStep(
                order: 4,
                title: "تركيب الخرطوشة الجديدة",
                text: "1. تأكد من توافق الخرطوشة الجديدة مع الصنبور.\n2. أدخلها في مكانها بالاتجاه الصحيح.\n3. أعد صامولة التثبيت وأحكم ربطها دون شد مفرط، إن وُجدت.\n4. أعد تركيب الغطاء المعدني والمقبض.",
                illustrationAsset: "leakingـfaucet_step4",
                warning: "لا تضغط على الخرطوشة بالقوة إذا لم تدخل بسهولة."
            ),
            SolutionStep(
                order: 5,
                title: "اختبار الصنبور",
                text: "افتح محابس الماء تدريجيًا، ثم شغّل الصنبور وأغلقه للتأكد من توقف التقطير وعدم وجود أي تسرب.",
                illustrationAsset: "leakingـfaucet_step5"
            )
        ]
    )

    static let sinkClog = DiagnosisProblem(
        id: "sink-clog",
        title: "انسداد المغسلة",
        description: "تصريف الماء من المغسلة ببطء أو تجمعه داخل الحوض دون نزوله بشكل طبيعي",
        illustrationAsset: "water_sink_slow_drain_icon",
        questions: [
            DiagnosisQuestion(id: "sink-clog-q1", text: "هل تلاحظ أن الماء ينزل من المغسلة ببطء أكثر من المعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "sink-clog-q2", text: "هل يتجمع الماء داخل المغسلة عند فتح الصنبور؟", expectedAnswer: true),
            DiagnosisQuestion(id: "sink-clog-q3", text: "هل يستغرق الماء وقتًا طويلًا حتى يختفي من الحوض بعد إغلاق الصنبور؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "تنظيف فتحة التصريف",
                text: "ارتدي قفازات، وأزل غطاء التصريف إذا كان قابلًا للإزالة، ثم تخلص من الشعر والأوساخ الظاهرة حول الفتحة.",
                illustrationAsset: "sink_clog_step1"
            ),
            SolutionStep(
                order: 2,
                title: "إزالة الانسداد الداخلي",
                text: "إذا استمر بطء التصريف، أدخل أداة تسليك بلاستيكية مخصصة للمغاسل برفق داخل الفتحة، ثم اسحبها لإزالة الشعر والأوساخ العالقة، إذا كان تصميم المصرف يسمح بذلك.",
                illustrationAsset: "sink_clog_step2"
            ),
            SolutionStep(
                order: 3,
                title: "استخدام أداة الشفط",
                text: "إذا لم يزل الانسداد، قم بتغطية فتحة فائض الماء بقطعة قماش مبللة، وضع قليلًا من الماء في الحوض، ثم استخدم شفاط المغسلة بحركات متكررة لمدة 15–30 ثانية.",
                illustrationAsset: "sink_clog_step3"
            ),
            SolutionStep(
                order: 4,
                title: "اختبار تصريف الماء",
                text: "أعد غطاء التصريف إلى مكانه، ثم افتح الصنبور وتحقق من نزول الماء بشكل طبيعي دون تجمعه في الحوض.",
                illustrationAsset: "sink_clog_step4"
            )
        ]
    )

    static let showerLowFlow = DiagnosisProblem(
        id: "shower-low-flow",
        title: "ضعف تدفق الماء من رأس الدش",
        description: "خروج الماء من رأس الدش بكمية أقل من المعتاد ",
        illustrationAsset: "water_low_pressure_icon",
        questions: [
            DiagnosisQuestion(id: "shower-low-flow-q1", text: "هل تلاحظ أن الماء يخرج من رأس الدش بكمية أقل من المعتاد؟", expectedAnswer: true),
            DiagnosisQuestion(id: "shower-low-flow-q2", text: "هل تدفق الماء من رأس الدش ضعيف، بينما يكون طبيعيًا في صنابير المنزل الأخرى؟", expectedAnswer: true),
            DiagnosisQuestion(id: "shower-low-flow-q3", text: "هل تلاحظ ترسبات بيضاء أو انسدادًا في بعض فتحات رأس الدش؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إغلاق الماء وتنظيف فتحات رأس الدش",
                text: "1. أغلق صنبور الدش تمامًا واترك رأس الدش يبرد قبل البدء بالتنظيف.\n2. نظّف فتحات خروج الماء بأصابعك أو بفرشاة ناعمة لإزالة الترسبات والأوساخ الظاهرة.",
                illustrationAsset: "shower_low_flow_step1"
            ),
            SolutionStep(
                order: 2,
                title: "تنظيف الترسبات المتبقية",
                text: "1. إذا استمر الانسداد، ضع محلولًا من الخل الأبيض المخفف بالماء داخل كيس، ثم ثبته حول رأس الدش بحيث تُغمر الفتحات.\n2. ثم أزل الكيس واشطف الرأس جيدًا.",
                illustrationAsset: "shower_low_flow_step2"
            ),
            SolutionStep(
                order: 3,
                title: "تنظيف المصفاة الداخلية",
                text: "إذا استمر ضعف التدفق، وكان رأس الدش قابلًا للفك، أزله وفق تعليمات طرازه ونظّف مصفاة مدخل الماء إن وُجدت، ثم أعد تركيبها.",
                illustrationAsset: "shower_low_flow_step3"
            ),
            SolutionStep(
                order: 4,
                title: "اختبار تدفق الماء",
                text: "شغّل الدش وتحقق من خروج الماء بشكل طبيعي ومنتظم، وعدم وجود تسرب عند التوصيلات.",
                illustrationAsset: "shower_low_flow_step4",
                warning: "إذا استمر ضعف التدفق بعد التنظيف، أو كان موجودًا في صنابير أخرى، فقد تكون المشكلة من ضغط الماء أو التوصيلات، ويُفضّل الاستعانة بفني مختص."
            )
        ]
    )

    static let toiletRunningWater = DiagnosisProblem(
        id: "toilet-running-water",
        title: "استمرار تدفق المياه في المرحاض",
        description: "استمرار نزول الماء داخل المرحاض بعد استخدام السيفون، أو سماع صوت تدفق الماء باستمرار رغم عدم استخدامه",
        illustrationAsset: "water_toilet_running_icon",
        questions: [
            DiagnosisQuestion(id: "toilet-running-water-q1", text: "هل تلاحظ استمرار نزول الماء داخل المرحاض بعد استخدام السيفون؟", expectedAnswer: true),
            DiagnosisQuestion(id: "toilet-running-water-q2", text: "هل يستمر صوت تدفق الماء بعد مرور عدة دقائق من استخدام السيفون؟", expectedAnswer: true),
            DiagnosisQuestion(id: "toilet-running-water-q3", text: "هل تلاحظ نزول الماء أو سماع صوت تعبئة الخزان حتى دون استخدام السيفون؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "فحص الخزان",
                text: "أزل غطاء خزان المرحاض بحذر، ثم اضغط السيفون وراقب مستوى الماء بعد امتلاء الخزان.",
                illustrationAsset: "toilet_running_water_step1"
            ),
            SolutionStep(
                order: 2,
                title: "فحص جلدة التصريف",
                text: "تأكد من أن جلدة التصريف الموجودة أسفل الخزان تعود إلى مكانها وتغلق الفتحة بالكامل بعد استخدام السيفون، إذا كان الخزان يحتوي على هذا النوع.",
                illustrationAsset: "toilet_running_water_step2"
            ),
            SolutionStep(
                order: 3,
                title: "ضبط سلسلة السيفون",
                text: "إذا كانت السلسلة مشدودة وتمنع الجلدة من الإغلاق، عدّل طولها لتبقى مرتخية قليلًا دون أن تتشابك.",
                illustrationAsset: "toilet_running_water_step3"
            ),
            SolutionStep(
                order: 4,
                title: "تنظيف جلدة التصريف",
                text: "1. أغلق محبس الماء، ثم اضغط السيفون لتفريغ الخزان.\n2. نظّف الجلدة وحافة فتحة التصريف من الرواسب برفق، ثم تأكد من استقرارها في مكانها.",
                illustrationAsset: "toilet_running_water_step4"
            ),
            SolutionStep(
                order: 5,
                title: "فحص مستوى العوامة",
                text: "إذا كان الماء يصب داخل أنبوب الفائض، اضبط العوامة وفق تعليمات الطراز حتى يتوقف الماء عند المستوى المحدد داخل الخزان، أسفل فتحة الفائض.",
                illustrationAsset: "toilet_running_water_step5"
            ),
            SolutionStep(
                order: 6,
                title: "اختبار المرحاض",
                text: "1. افتح محبس الماء، ثم اضغط السيفون وانتظر امتلاء الخزان.\n2. تأكد من توقف الماء وعدم استمرار تدفقه داخل المرحاض.",
                illustrationAsset: "toilet_running_water_step6",
                warning: "إذا كانت الجلدة تالفة أو استمر صمام التعبئة في العمل، فقد تحتاج القطعة إلى الاستبدال. لا تفك الصمامات أو التوصيلات دون معرفة طرازها. وإذا استمر تدفق الماء، أغلق محبس التغذية واستعن بفني."
            )
        ]
    )

    static let showerConnectionLeak = DiagnosisProblem(
        id: "shower-connection-leak",
        title: "تسريب وصلة رأس الدش",
        description: "تسرب الماء من نقطة اتصال رأس الدش بالأنبوب أو الخرطوم أثناء تشغيله",
        illustrationAsset: "water_shower_clog_icon",
        questions: [
            DiagnosisQuestion(id: "shower-connection-leak-q1", text: "هل تلاحظ خروج الماء من الوصلة المتصلة برأس الدش أثناء تشغيله؟", expectedAnswer: true),
            DiagnosisQuestion(id: "shower-connection-leak-q2", text: "هل تتجمع قطرات الماء حول صامولة الوصلة أو تتساقط منها؟", expectedAnswer: true),
            DiagnosisQuestion(id: "shower-connection-leak-q3", text: "هل يستمر التسرب من الوصلة أثناء تدفق الماء، حتى دون تحريك رأس الدش؟", expectedAnswer: true)
        ],
        solutionSteps: [
            SolutionStep(
                order: 1,
                title: "إغلاق الماء",
                text: "أغلق صنبور الدش تمامًا، وانتظر حتى يبرد رأس الدش قبل البدء.",
                illustrationAsset: "shower_connection_leak_step1"
            ),
            SolutionStep(
                order: 2,
                title: "فك رأس الدش",
                text: "1. أمسك أنبوب الدش بثبات، ثم لفّ صامولة رأس الدش عكس عقارب الساعة لفكها.\n2. استخدم مفتاحًا مناسبًا مع قطعة قماش لحماية السطح عند الحاجة.",
                illustrationAsset: "shower_connection_leak_step2"
            ),
            SolutionStep(
                order: 3,
                title: "فحص الوصلة",
                text: "1. افحص القلاوظ وحلقة الإحكام المطاطية، إن وُجدت.\n2. تأكد من عدم وجود تشققات أو تلف أو أوساخ تمنع إحكام الاتصال.",
                illustrationAsset: "shower_connection_leak_step3"
            ),
            SolutionStep(
                order: 4,
                title: "تنظيف الوصلة",
                text: "أزل بقايا شريط العزل القديم والرواسب من القلاوظ بقطعة قماش أو فرشاة مناسبة، دون خدش الوصلة.",
                illustrationAsset: "shower_connection_leak_step4"
            ),
            SolutionStep(
                order: 5,
                title: "إعادة إحكام الوصلة",
                text: "1. إذا كان طراز رأس الدش يتطلب شريط عزل، لفّ شريط السباكة باتجاه عقارب الساعة حول القلاوظ مرتين إلى ثلاث مرات، ثم أعد تركيب الرأس وأحكم ربطه دون شد مفرط.\n2. أما الوصلات التي تعتمد على جلدة مطاطية، فتأكد من سلامتها وتركيبها الصحيح، ولا تضف الشريط إلا إذا أوصى دليل الطراز بذلك.",
                illustrationAsset: "shower_connection_leak_step5"
            ),
            SolutionStep(
                order: 6,
                title: "اختبار التسرب",
                text: "شغّل الدش وراقب الوصلة للتأكد من توقف تسرب الماء وعدم ظهور قطرات حولها.",
                illustrationAsset: "shower_connection_leak_step6",
                warning: "إذا ظهرت تشققات في الصامولة أو الوصلة، أو استمر التسرب بعد إعادة التركيب، أوقف الاستخدام واستعن بفني مختص."
            )
        ]
    )

    // MARK: - Template for new problems
    //
    // To add a problem, copy this block, fill it in, then add its name to the
    // `problems` list of its category above (e.g. `problems: [..., myNewProblem]`).
    //
    // Rules:
    // - Every `id` must be unique. Questions use "<problem-id>-q1", "-q2", ...
    // - Write every question so that "نعم" confirms the problem → expectedAnswer: true.
    //   If "نعم" does not confirm it, use expectedAnswer: nil (not evaluated).
    // - Safety questions: "نعم" must be the safe state, and add isSafetyCritical: true.
    // - `title` and `warning` on a step are optional.
    //
    // static let myNewProblem = DiagnosisProblem(
    //     id: "device-short-name",
    //     title: "عنوان المشكلة",
    //     description: "وصف قصير يظهر في شاشة المقدمة، أو اتركه فارغاً",
    //     illustrationAsset: "image_name_in_assets",
    //     questions: [
    //         DiagnosisQuestion(id: "device-short-name-q1", text: "هل ...؟", expectedAnswer: true),
    //         DiagnosisQuestion(id: "device-short-name-q2", text: "هل ...؟", expectedAnswer: true)
    //     ],
    //     solutionSteps: [
    //         SolutionStep(order: 1, title: "فصل الكهرباء", text: "..."),
    //         SolutionStep(order: 2, text: "...", warning: "تحذير ...")
    //     ]
    // )
}
