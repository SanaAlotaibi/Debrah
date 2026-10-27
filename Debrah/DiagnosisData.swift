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

    /// نص الخطوة.
    let text: String

    /// صورة توضيحية للخطوة، أو `nil` لعرض مكان فارغ.
    var illustrationAsset: String? = nil

    /// ملاحظة تحذيرية تظهر أسفل الخطوة، أو `nil`.
    var warning: String? = nil

    var id: Int { order }
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
            .pending(id: "water-faucet-leak", title: "تسرّب الصنبور", image: "water_faucet_leak"),
            .pending(id: "water-sink-slow-drain", title: "انسداد المغسلة", image: "water_sink_slow_drain"),
            .pending(id: "water-low-pressure", title: "ضعف تدفق رأس الدش", image: "water_low_pressure"),
            .pending(id: "water-toilet-running", title: "استمرار تدفق المياه في المرحاض", image: "water_toilet_running"),
            .pending(id: "water-shower-clog", title: "تسريب وصلة رأس الدش", image: "water_shower_clog")
        ]
    )

    static let furniture = ServiceCategory(
        id: "furniture",
        title: "الأبواب والأثاث",
        icon: "homekit",
        problems: [looseDrawer]
    )

    static let electricity = ServiceCategory(
        id: "electricity",
        title: "مشاكل الكهرباء",
        icon: "bolt"
    )

    static let homeAppliances = ServiceCategory(
        id: "home-appliances",
        title: "الأجهزة المنزلية",
        icon: "washer",
        subcategories: [washers, fridges, airConditioners, gasOvens, vacuumCleaners, waterHeaters]
    )

    // MARK: Home Appliances

    static let washers = ServiceCategory(
        id: "washers",
        title: "الغسالات",
        imageName: "device_washer",
        problems: [
            .pending(id: "washer-drain", title: "الغسالة لا تصرّف الماء", image: "washer_drain"),
            .pending(id: "washer-drum", title: "حوض الغسيل لا يدور", image: "washer_drum"),
            .pending(id: "washer-hose-leak", title: "تسرب الماء من وصلة خرطوم دخول الماء", image: "washer_hose_leak")
        ]
    )

    static let fridges = ServiceCategory(
        id: "fridges",
        title: "الثلاجات",
        imageName: "device_fridge",
        problems: [
            .pending(id: "fridge-not-cooling", title: "الثلاجة لا تبرد جيدًا", image: "fridge_not_cooling"),
            .pending(id: "fridge-door-seal", title: "باب الثلاجة لا يغلق بإحكام", image: "fridge_door_seal"),
            .pending(id: "fridge-water-drops", title: "تسريب المياه من الثلاجة", image: "fridge_water_drops")
        ]
    )

    static let airConditioners = ServiceCategory(
        id: "air-conditioners",
        title: "المكيفات",
        imageName: "device_ac",
        problems: [
            .pending(id: "ac-water-drip", title: "تقطر الماء من مكيف الأسبلت", image: "ac_water_drip"),
            .pending(id: "ac-clicking-noise", title: "طقطقة المكيف", image: "ac_clicking_noise"),
            .pending(id: "ac-bad-smell", title: "الرائحة الكريهة في المكيف", image: "ac_bad_smell")
        ]
    )

    static let gasOvens = ServiceCategory(
        id: "gas-ovens",
        title: "أفران الغاز",
        imageName: "device_oven",
        problems: [
            .pending(id: "oven-gas-change", title: "تبديل الغاز", image: "oven_gas_change 1"),
            .pending(id: "oven-flame-stops", title: "مشكلة توقف النار بعد التشغيل", image: "oven_flame_stops 1"),
            .pending(id: "oven-weak-flame", title: "نار العين ضعيفة أو تقطع", image: "oven_weak_flame")
        ]
    )

    static let vacuumCleaners = ServiceCategory(
        id: "vacuum-cleaners",
        title: "المكانس الكهربائية",
        imageName: "device_vacuum",
        problems: [
            .pending(id: "vacuum-loud-noise", title: "ارتفاع صوت المكنسة", image: "vacuum_loud_noise"),
            .pending(id: "vacuum-dirty-filter", title: "اتساخ فلتر المكنسة الكهربائية", image: "vacuum_dirty_filter"),
            .pending(id: "vacuum-clogged-hose", title: "انسداد خرطوم المكنسة أو رأسها", image: "vacuum_clogged_hose")
        ]
    )

    static let waterHeaters = ServiceCategory(
        id: "water-heaters",
        title: "سخانات المياه",
        imageName: "water_heater",
        problems: [
            .pending(id: "heater-install", title: "تركيب السخان", image: "heater_install"),
            .pending(id: "heater-valve", title: "تغيير البلف", image: "heater_valve"),
            .pending(id: "heater-weak-hot-water", title: "ضعف المياه الساخنة في السخان", image: "heater_weak_hot_water"),
            .pending(id: "heater-low-temp", title: "درجة حرارة الماء منخفضة", image: "heater_low_temp")
        ]
    )

    // MARK: Problems

    static let looseDrawer = DiagnosisProblem(
        id: "drawer-loose",

        title: "ارتخاء الأدراج",

        description:
            "قد يصبح الدرج مائلاً أو غير ثابت، مما يصعّب فتحه وإغلاقه بسلاسة. غالباً بسبب ارتخاء المسامير أو تلف مسارات الدرج.",

        illustrationAsset: "drawer-loose-illustration",

        questions: [
            DiagnosisQuestion(
                id: "drawer-loose-q1",
                text: "هل تتحرك السكة من مكان تثبيتها؟",
                expectedAnswer: true
            ),

            DiagnosisQuestion(
                id: "drawer-loose-q2",
                text: "سؤال تجريبي ٢ — استبدله بسؤال التشخيص الحقيقي",
                expectedAnswer: true
            ),

            DiagnosisQuestion(
                id: "drawer-loose-q3",
                // TODO: Write the real question so that "Yes" confirms the problem.
                text: "سؤال تجريبي ٣ — استبدله بسؤال التشخيص الحقيقي",
                expectedAnswer: true
            )
        ],

        solutionSteps: [
            SolutionStep(
                order: 1,
                text: "أفرغ الدرج من محتوياته لتسهيل التعامل معه",
                warning: "تنبيه: إذا كان الدرج مائلاً أو خرج من مساره، لا تجبره على الحركة:\nفقد يحتاج إلى إعادة تركيب السكة أو إصلاحها"
            ),

            SolutionStep(
                order: 2,
                text: "نص تجريبي للخطوة الثانية"
            ),

            SolutionStep(
                order: 3,
                text: "نص تجريبي للخطوة الثالثة"
            )
        ]
    )
}
