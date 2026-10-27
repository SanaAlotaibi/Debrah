import SwiftUI
import UIKit

// MARK: - Theme (colors, fonts, shared styles)

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum Theme {
    // Colors matched by eye from the Sketch screens — adjust to your exact values.
    static let brown = Color(hex: 0x5E4630)
    static let mintLabel = Color(hex: 0x86B09D)
    static let mintButton = Color(hex: 0xD3DFD8)
    static let mintAction = Color(hex: 0x8FAC9F)
    static let danger = Color(hex: 0xC8312A)
    static let cardBackground = Color(hex: 0xFFFBF7)
    static let screenGlow = Color(hex: 0xBFE3D3)

    /// ⚠️ Replace with the verified PostScript name of your bundled Thmanyah font.
    /// If the name is wrong, the system serif font is used instead.
    static let fontName = "Thmanyahserif-Regular"

    static func font(size: CGFloat) -> Font {
        if UIFont(name: fontName, size: size) != nil {
            return .custom(fontName, size: size)
        }
        return .system(size: size, design: .serif)
    }

    // Animations
    static let cardSpring = Animation.spring(response: 0.5, dampingFraction: 0.82)
    static let modalSpring = Animation.spring(response: 0.4, dampingFraction: 0.85)
}

/// Applies the app font; the size grows with Dynamic Type.
private struct ThemedFont: ViewModifier {
    @ScaledMetric private var size: CGFloat

    init(size: CGFloat, style: Font.TextStyle) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
    }

    func body(content: Content) -> some View {
        content.font(Theme.font(size: size))
    }
}

extension View {
    func themed(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> some View {
        modifier(ThemedFont(size: size, style: style))
    }

    /// Off-white rounded card with a soft shadow.
    func cardSurface(cornerRadius: CGFloat = 28, shadowOpacity: Double = 0.12) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Theme.cardBackground)
                .shadow(color: .black.opacity(shadowOpacity), radius: 14, x: 0, y: 6)
        )
    }
}

/// White background with a very subtle mint glow near the bottom.
struct ScreenBackground: View {
    var body: some View {
        ZStack {
            Color.white
            RadialGradient(
                colors: [Theme.screenGlow.opacity(0.35), Theme.screenGlow.opacity(0)],
                center: .bottom,
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}

struct ScreenTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .typography(.screenTitle)
            .foregroundStyle(Theme.brown)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Mint rounded button ("ابدأ التشخيص" and the warning buttons).
struct MintButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typography(.button)
            .foregroundStyle(Theme.brown)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Theme.mintButton, in: Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// زر ثانوي بإطار نعناعي («رجوع»).
struct MintOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typography(.button)
            .foregroundStyle(Theme.brown)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 44)
            .overlay(Capsule().stroke(Theme.mintButton, lineWidth: 1.5))
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Spacing, Radius & Shadow

extension Theme {

    /// مقياس المسافات الموحّد (مضاعفات 4).
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
        static let huge: CGFloat = 64
    }

    /// أنصاف أقطار الزوايا.
    enum Radius {
        /// بطاقات الأسئلة ونافذة التنبيه.
        static let card: CGFloat = 30

        /// بطاقة شاشة المقدمة وبطاقة خطوة الحل.
        static let largeCard: CGFloat = 32

        /// بطاقات الخدمات في الشاشة الرئيسية.
        static let tile: CGFloat = 40

        /// صفوف قوائم المشكلات.
        static let row: CGFloat = 24

        /// الصور داخل البطاقات.
        static let image: CGFloat = 20
    }

    /// شفافية الظلال حسب ارتفاع العنصر.
    enum Shadow {
        static let card: Double = 0.12
        static let raisedCard: Double = 0.14
        static let overlay: Double = 0.18
    }
}

// MARK: - Typography

/// أنماط النصوص الموحّدة في التطبيق.
///
/// كل نمط يستخدم خط التطبيق العربي عبر `themed(_:relativeTo:)`،
/// فيكبر تلقائياً مع Dynamic Type.
enum AppTypography {

    /// عنوان كبير لشاشة الإنجاز («تم الإصلاح!»).
    case displayTitle

    /// عنوان الشاشة (اسم الخدمة أو المشكلة).
    case screenTitle

    /// عنوان بطاقة الخدمة.
    case cardTitle

    /// عنوان صف في قائمة المشكلات.
    case rowTitle

    /// الكلمة الصغيرة أعلى البطاقة («التشخيص»، «الخطوة ١»).
    case eyebrow

    /// النصوص الوصفية.
    case body

    /// نص السؤال ونص خطوة الحل.
    case question

    /// عنوان نافذة التنبيه.
    case alertTitle

    /// نص نافذة التنبيه.
    case alertBody

    /// نص الأزرار.
    case button

    /// نصوص صغيرة: الملاحظات ورقاقة «استكشف».
    case caption

    /// الحجم الأساسي قبل تطبيق Dynamic Type.
    var size: CGFloat {
        switch self {
        case .displayTitle: 32
        case .screenTitle: 28
        case .cardTitle: 18
        case .rowTitle: 17
        case .eyebrow: 14
        case .body: 15
        case .question: 17
        case .alertTitle: 20
        case .alertBody: 15
        case .button: 15
        case .caption: 13
        }
    }

    /// نمط النظام الذي يُقاس عليه التكبير.
    var textStyle: Font.TextStyle {
        switch self {
        case .displayTitle: .largeTitle
        case .screenTitle: .title
        case .cardTitle: .headline
        case .eyebrow: .subheadline
        case .rowTitle, .body, .question, .alertBody: .body
        case .alertTitle: .title3
        case .button: .callout
        case .caption: .footnote
        }
    }

    /// المسافة بين الأسطر. أوسع قليلاً في النصوص الطويلة لوضوح الخط العربي.
    var lineSpacing: CGFloat {
        switch self {
        case .displayTitle, .screenTitle, .cardTitle, .eyebrow, .alertTitle, .button: 0
        case .rowTitle, .caption: 4
        case .body, .question: 6
        case .alertBody: 5
        }
    }
}

extension View {

    /// يطبّق نمطاً من ``AppTypography``.
    func typography(_ style: AppTypography) -> some View {
        themed(style.size, relativeTo: style.textStyle)
            .lineSpacing(style.lineSpacing)
    }
}

// MARK: - Problem Illustration

/// رسمة المشكلة من Assets، بنسبتها الأصلية دون تمديد.
///
/// إذا لم توجد الصورة في Assets تظهر أيقونة بديلة بدلاً من مساحة فارغة.
struct ProblemIllustration: View {

    /// اسم الصورة في Assets.
    let assetName: String

    var body: some View {
        if UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Theme.mintLabel)
                .scaleEffect(0.5)
        }
    }
}

// MARK: - Preview Support

extension View {

    /// البيئة المشتركة للمعاينات: Router، واتجاه RTL، واللغة العربية.
    func appPreviewEnvironment() -> some View {
        environment(Router())
            .environment(\.layoutDirection, .rightToLeft)
            .environment(\.locale, Locale(identifier: "ar"))
    }
}
