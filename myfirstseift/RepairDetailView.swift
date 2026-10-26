//
//  RepairDetailView.swift
//  Debrah
//
//  Created by Sana Alotaibi on 14/05/1448 AH.
//
import SwiftUI

struct RepairDetailView: View {
    let item: RepairItem
    
    let brown = Color(red: 0.40, green: 0.29, blue: 0.20)
    let mint = Color(red: 0.52, green: 0.70, blue: 0.63)
    
    @Environment(\.dismiss) var dismiss // للسماح للزر بالرجوع للصفحة السابقة
    
    var body: some View {
        VStack(spacing: 0) {
            
            // الهيدر (العنوان وزر الرجوع المتطابق مع الصفحة الرئيسية)
            ZStack {
                Text(item.title)
                    .font(.system(size: 32, design: .serif))
                    .foregroundStyle(brown)
                
                HStack {
                    Spacer()
                    
                    // زر الرجوع بنفس لون وسُمك سهم الصفحة الرئيسية
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 22))
                            .foregroundStyle(mint)
                    }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 26)
            
            // البطاقة الوسطية (الصورة والوصف)
            VStack(spacing: 16) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 130)
                    .padding(.top, 10)
                
                Text(item.description)
                    .font(.system(size: 17, design: .serif))
                    .foregroundStyle(brown.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(Color(red: 1.0, green: 0.99, blue: 0.98))
            .clipShape(RoundedRectangle(cornerRadius: 34))
            .overlay {
                RoundedRectangle(cornerRadius: 34)
                    .stroke(Color.gray.opacity(0.08), lineWidth: 1)
            }
            .shadow(
                color: Color(red: 0.25, green: 0.36, blue: 0.31).opacity(0.15),
                radius: 7,
                x: 0,
                y: 5
            )
            .padding(.horizontal, 16)
            
            Spacer()
            
            // زر "ابدأ التشخيص" في الأسفل
            Button(action: {
                // إجراء التشخيص لاحقاً
            }) {
                Text("ابدأ التشخيص")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(mint)
                    .clipShape(Capsule())
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 7,
                        x: 0,
                        y: 3
                    )
            }
            .padding(.horizontal, 32)
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
        .toolbar(.hidden, for: .navigationBar) // إخفاء الشريط الافتراضي ليتطابق التصميم بالكامل
    }
}
