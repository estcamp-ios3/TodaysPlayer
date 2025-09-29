//
//  QuestionView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import Foundation

private enum InquiryType: String, CaseIterable, Identifiable {
    case account = "계정/로그인"
    case payment = "결제/환불"
    case match = "경기/매치"
    case bug = "버그 제보"
    case feedback = "개선 제안"
    case other = "기타"

    var id: String { rawValue }
    var title: String { rawValue }
}

private struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct QuestionView: View {
    // MARK: - State
    @Environment(\.dismiss) private var dismiss

    @State private var inquiryType: InquiryType? = nil
    @State private var subject: String = ""
    @State private var bodyText: String = ""
    @State private var contactEmail: String = ""

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    // MARK: - Data
    private let faqs: [FAQItem] = [
        FAQItem(
            question: "용병 신청은 어떻게 하나요?",
            answer: "용병 모집 페이지에서 원하는 경기를 선택하고 '신청하기' 버튼을 클릭하면 됩니다. 주최자가 승인하면 경기 참여가 확정됩니다."
        ),
        FAQItem(
            question: "경기 참여비는 언제 결제하나요?",
            answer: "경기 당일 현장에서 주최자에게 직접 결제하시면 됩니다. 일부 경기는 사전 결제가 필요할 수 있으니 경기 상세 정보를 확인해주세요."
        ),
        FAQItem(
            question: "경기 취소는 언제까지 가능한가요?",
            answer: "경기 시작 2시간 전까지 취소 가능합니다. 그 이후 취소 시에는 패널티가 부과될 수 있습니다."
        ),
        FAQItem(
            question: "평점은 어떻게 매겨지나요?",
            answer: "경기 종료 후 함께 플레이한 다른 참가자들이 매너, 실력, 협력도 등을 종합적으로 평가하여 1~5점으로 평점을 매깁니다."
        )
    ]

    // MARK: - Layout
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                inquiryCard
                faqSection
                contactSection
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("운영자에게 문의하기").font(.headline)
            }
        }
        .alert("알림", isPresented: $showAlert, actions: {
            Button("확인", role: .cancel) {}
        }, message: {
            Text(alertMessage)
        })
    }

    // MARK: - Sections
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("문의하기")
                .font(.headline)
                .foregroundColor(.primary)
            Text("궁금한 점이나 문제가 있으시면 언제든지 문의해주세요.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var inquiryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 문의 유형
            LabeledContainer(label: "문의 유형") {
                Menu {
                    ForEach(InquiryType.allCases) { type in
                        Button(type.title) { inquiryType = type }
                    }
                } label: {
                    HStack {
                        Text(inquiryType?.title ?? "문의 유형을 선택해주세요")
                            .foregroundColor(inquiryType == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // 제목
            LabeledContainer(label: "제목") {
                TextField("문의 제목을 입력해주세요", text: $subject)
                    .textInputAutocapitalization(.sentences)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // 문의 내용
            LabeledContainer(label: "문의 내용") {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 140)
                        .padding(8)
                        .background(fieldBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    if bodyText.isEmpty {
                        Text("문의하실 내용을 자세히 작성해주세요. 문제 상황, 발생 시간, 사용 환경 등을 포함해주시면 더 빠른 답변이 가능합니다.")
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                            .padding(.horizontal, 18)
                            .allowsHitTesting(false)
                    }
                }
            }

            // 이메일
            LabeledContainer(label: "연락받을 이메일") {
                TextField("example@email.com", text: $contactEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // 전송 버튼
            Button(action: sendInquiry) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("문의 보내기")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.label)) // dark on light, adapts
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("자주 묻는 질문")
                .font(.headline)
                .foregroundColor(.primary)
            VStack(spacing: 10) {
                ForEach(faqs) { item in
                    FAQCard(item: item)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("연락처 정보")
                .font(.headline)
            ContactRow(icon: "envelope.fill", title: "이메일", detail: "support@futsalmatch.com")
            ContactRow(icon: "phone.fill", title: "고객센터", detail: "1588-1234 (평일 09:00~18:00)")
            ContactRow(icon: "clock.fill", title: "운영시간", detail: "평일 09:00~18:00 (주말 및 공휴일 제외)")
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private var fieldBackground: Color { Color.gray.opacity(0.12) }

    private var isFormValid: Bool {
        guard let inquiryType else { return false }
        _ = inquiryType // silence unused warning if builds strip usage
        return !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               isValidEmail(contactEmail)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.contains("@"), trimmed.contains(".") else { return false }
        return true
    }

    private func sendInquiry() {
        // In a real app, send to server here.
        alertMessage = "문의가 정상적으로 접수되었습니다. 빠른 시일 내에 답변드리겠습니다."
        showAlert = true
        // Optionally reset fields
        subject = ""
        bodyText = ""
        // keep email & type for convenience
    }
}

// MARK: - Subviews
private struct LabeledContainer<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            content()
        }
    }
}

private struct FAQCard: View {
    let item: FAQItem
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut) { expanded.toggle() }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text("Q.")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.question)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            .buttonStyle(.plain)

            if expanded {
                Text(item.answer)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct ContactRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(detail)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        QuestionView()
    }
}
