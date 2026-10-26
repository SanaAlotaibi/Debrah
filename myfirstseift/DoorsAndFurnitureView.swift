//
//  DoorsAndFurnitureView.swift
//  Debrah
//
//  Created by Sana Alotaibi on 14/05/1448 AH.
//

import SwiftUI

struct RepairItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let description: String //  وصف خاص لكل مشكلة
}

struct DoorsAndFurnitureView: View {

    let repairItems = [
        RepairItem(title: "ارتخاء الأدراج", imageName: "drawer_icon", description: "قد يصبح الدرج مائلاً أو غير ثابت، مما يصعب فتحه وإغلاقه بسلاسة. غالباً بسبب ارتخاء المسامير أو تلف مسارات الدرج."),
        RepairItem(title: "ميلان الأبواب", imageName: "door_icon", description: "يظهر ميلان في الأبواب مما يمنع إغلاقها بإحكام أو الاحتكاك بالأرضية، وغالباً ما يحتاج تعديل المفصلات."),
        RepairItem(title: "اهتزاز الكراسي", imageName: "chair_icon", description: "تصبح الكراسي غير متوازنة أو مهتزة عند الجلوس عليها بسبب تفكك المسامير أو تخلخل الوصلات الخشبية."),
        RepairItem(title: "مقابض الأبواب مفكوكة", imageName: "handle_icon", description: "تتحرك المقابض من مكانها أو ترتخي أثناء الاستخدام نتيجة تآكل أو ارتخاء براغي التثبيت الداخلية."),
        RepairItem(title: "عطل في قفل الباب", imageName: "lock_icon", description: "يواجه قفل الباب صعوبة في الإغلاق أو دوران المفتاح، وغالباً ما ينتج عن احتكاك الألسنة أو تلف الآلية الداخلية.")
    ]

    let brown = Color(red: 0.40, green: 0.29, blue: 0.20)
    let mint = Color(red: 0.52, green: 0.70, blue: 0.63)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // العنوان والسهم
                ZStack {
                    Text("الأبواب والأثاث")
                        .font(.system(size: 32, design: .serif))
                        .foregroundStyle(brown)

                    HStack {
                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 22))
                            .foregroundStyle(mint)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 26)

                // الكروت
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(repairItems) { item in
                            NavigationLink {
                                RepairDetailView(item: item)
                            } label: {
                                RepairCardView(
                                    item: item,
                                    brown: brown,
                                    mint: mint
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                    .padding(.bottom, 12)
                }

                // زر البحث أسفل القائمة
                HStack {
                    Button(action: {
                        // نضيف البحث لاحقًا
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .frame(width: 76, height: 54)
                            .background(mint)
                            .clipShape(Capsule())
                            .shadow(
                                color: .black.opacity(0.15),
                                radius: 7,
                                x: 0,
                                y: 3
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LinearGradient(
                    colors: [
                        .white,
                        .white,
                        Color(red: 0.91, green: 0.97, blue: 0.94)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .environment(\.layoutDirection, .rightToLeft)
          
        }
    }
}

// كرت المشكلة
struct RepairCardView: View {

    let item: RepairItem
    let brown: Color
    let mint: Color

    var body: some View {
        HStack(spacing: 0) {

            // الصورة على اليمين
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 86, height: 82)
                .padding(.horizontal, 10)

            // الخط الأخضر
            RoundedRectangle(cornerRadius: 1)
                .fill(mint)
                .frame(width: 2, height: 54)

            // النص على اليسار
            Text(item.title)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(brown)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .frame(maxWidth: .infinity)
        .frame(height: 106)
        .background(
            Color(red: 1.0, green: 0.99, blue: 0.98)
        )
        .clipShape(RoundedRectangle(cornerRadius: 34))
        .overlay {
            RoundedRectangle(cornerRadius: 34)
                .stroke(
                    Color.gray.opacity(0.08),
                    lineWidth: 1
                )
        }
        .shadow(
            color: Color(red: 0.25, green: 0.36, blue: 0.31)
                .opacity(0.22),
            radius: 7,
            x: 0,
            y: 5
        )
    }
}
