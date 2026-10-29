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

    /// صورة توضيحية للخطوة، أو `nil` لعرض مكان فارغ.
    var illustrationAsset: String? = nil

    /// ملاحظة تحذيرية تظهر أسفل الخطوة، أو `nil`.
    var warning: String? = nil

    var id: Int { order }

    init(
        order: Int,
        title: String? = nil,
        text: String,
        illustrationAsset: String? = nil,
        warning: String? = nil
    ) {
        self.order = order
        self.title = title
        self.text = text
        self.illustrationAsset = illustrationAsset
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
            problems: [
                looseDrawer,
                doorTilt,
            //    chairWobble,
               // doorHandleLoose
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
                .pending(id: "lighting-bulb-burnt", title: "اللمبة محترقة ولا تضيء", image: "lighting_bulb_burnt"),
                .pending(id: "lighting-bulb-flickering", title: "اللمبة تومض باستمرار", image: "lighting_bulb_flickering"),
                .pending(id: "lighting-bulb-mismatch", title: "اللمبة الجديدة لا تناسب وحدة الإنارة", image: "lighting_bulb_mismatch"),
                .pending(id: "lighting-bulb-dim", title: "إضاءة اللمبة ضعيفة", image: "lighting_bulb_dim")
            ]
        )

        static let outlets = ServiceCategory(
            id: "outlets",
            title: "المقابس والتوصيلات",
            imageName: "sockets_wiring",
            problems: [
                .pending(id: "outlets-device-not-working", title: "الجهاز لا يعمل عند توصيله بالكهرباء", image: "outlets_device_not_working"),
                .pending(id: "outlets-plug-hot", title: "القابس أو التوصيلة ساخنة بشكل غير طبيعي", image: "outlets_plug_hot"),
                .pending(id: "outlets-sparks", title: "وجود شرر عند توصيل القابس", image: "outlets_sparks")
            ]
        )

        static let breakers = ServiceCategory(
            id: "breakers",
            title: "القواطع وانقطاع الكهرباء",
            imageName: "power_outage",
            problems: [
                .pending(id: "breakers-one-room-outage", title: "انقطاع الكهرباء عن غرفة واحدة", image: "breakers_one_room_outage"),
                .pending(id: "breakers-whole-house-outage", title: "انقطاع الكهرباء عن المنزل بالكامل", image: "breakers_whole_house_outage"),
                .pending(id: "breakers-clicking-burning-smell", title: "انقطاع الكهرباء مع صدور صوت طقطقة أو رائحة احتراق", image: "breakers_clicking_burning_smell")
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
            description: "قد يصبح الدرج مائلاً أو غير ثابت، مما يصعب فتحه وإغلاقه بسلاسة. غالباً بسبب ارتخاء المسامير أو تلف مسارات الدرج.",
            illustrationAsset: "drawer_loose",
            questions: [
                DiagnosisQuestion(id: "drawer-loose-q1", text: "هل يتحرك درج الخزانة أو السكة من مكان تثبيتها عند سحبه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "drawer-loose-q2", text: "هل لاحظتِ وجود مسامير مفكوكة أو ساقطة في أسفل الدرج أو على الجوانب؟", expectedAnswer: true),
                DiagnosisQuestion(id: "drawer-loose-q3", text: "هل صوت احتكاك الخشب ببعضه واضح ومزعج عند فتح وإغلاق الدرج؟", expectedAnswer: true)
            ],
            solutionSteps: [
                SolutionStep(
                    order: 1,
                    title: "أفرغ الدرج",
                    text: "أخرج جميع الأغراض من الدرج لتخفيف وزنه وتسهيل فحصه.",
                    illustrationAsset: "drawer_step1"
                ),
                SolutionStep(
                    order: 2,
                    title: "أخرج الدرج من مكانه",
                    text: "اسحب الدرج بحذر، وإذا كانت له آلية تحرير للمسارات، اتبع تعليمات الشركة المصنعة لإخراجه بأمان.",
                    illustrationAsset: "drawer_step2"
                ),
                SolutionStep(
                    order: 3,
                    title: "افحص براغي التثبيت",
                    text: "افحص البراغي التي تثبت المسارات بجوانب الدرج وهيكل الدولاب، وتحقق من وجود براغٍ مرتخية.",
                    illustrationAsset: "drawer_step3"
                ),
                SolutionStep(
                    order: 4,
                    title: "أحكم تثبيت البراغي",
                    text: "استخدم المفك المناسب لشد البراغي المرتخية برفق، دون المبالغة في الشد حتى لا تتلف فتحات التثبيت.",
                    illustrationAsset: "drawer_step4"
                ),
                SolutionStep(
                    order: 5,
                    title: "أعد تركيب الدرج",
                    text: "أعد الدرج إلى مساراته، وتأكد من دخوله في مكانه الصحيح.",
                    illustrationAsset: "drawer_step5"
                ),
                SolutionStep(
                    order: 6,
                    title: "اختبر حركة الدرج",
                    text: "افتح الدرج وأغلقه عدة مرات، وتحقق من استقامته وسلاسة حركته.",
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
                DiagnosisQuestion(id: "door-tilt-q1", text: "هل يحتك الباب بالأرض عند فتحه أو إغلاقه؟", expectedAnswer: true),
                DiagnosisQuestion(id: "door-tilt-q2", text: "هل توجد براغٍ مرتخية أو مفصلات غير مثبتة بإحكام في الباب؟", expectedAnswer: true),
                DiagnosisQuestion(id: "door-tilt-q3", text: "هل تلاحظ أن الباب مائل أو هابط من جهة المقبض؟", expectedAnswer: true)
            ],
            solutionSteps: [
                SolutionStep(
                    order: 1,
                    title: "افحص مفصلات الباب",
                    text: "افتح الباب قليلًا، وافحص المفصلات الموجودة على جانبه. تحقق من وجود براغٍ مرتخية أو مفصلات تتحرك من مكانها، ولاحظ إن كان الباب يهبط من جهة المقبض.",
                    illustrationAsset: "door_tilt_step1"
                ),
                SolutionStep(
                    order: 2,
                    title: "جهّز الباب قبل الإصلاح",
                    text: "إذا كان الباب ثقيلًا أو يهبط بوضوح، لا تحاول رفعه أو إصلاحه وحدك. اطلب مساعدة شخص بالغ أو مختص لتثبيته ودعم وزنه قبل التعامل مع المفصلات.",
                    illustrationAsset: "door_tilt_step2"
                ),
                SolutionStep(
                    order: 3,
                    title: "أحكم تثبيت البراغي المرتخية",
                    text: "بعد تثبيت الباب بأمان، استخدم مفكًا مناسبًا لشد البراغي المرتخية برفق. إذا كانت البراغي تدور دون أن تثبت أو كانت فتحاتها متضررة، فلا تواصل شدها بالقوة.",
                    illustrationAsset: "door_tilt_step3"
                ),
                SolutionStep(
                    order: 4,
                    title: "افحص استقامة الباب",
                    text: "تحقق من أن المفصلات مثبتة جيدًا وأن الباب عاد إلى موضعه الصحيح. إذا كانت المفصلات مثنية أو كان إطار الباب متضررًا، فقد يحتاج إلى إصلاح إضافي.",
                    illustrationAsset: "door_tilt_step4"
                ),
                SolutionStep(
                    order: 5,
                    title: "اختبر فتح الباب وإغلاقه",
                    text: "بعد التأكد من ثبات المفصلات، حرّك الباب بهدوء وتحقق من سهولة فتحه وإغلاقه ومن عدم احتكاكه بالأرض. إذا استمر الميلان، فقد تكون المشكلة في المفصلات أو الإطار نفسه.",
                    illustrationAsset: "door_tilt_step5"
                )
            ]
        )
    
    // MARK: Air Conditioners

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

    // MARK: Fridges

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

    // MARK: Washers

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
