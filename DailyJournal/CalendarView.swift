//
//  CalendarView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import SwiftUI
import SwiftData

// MARK: - Calendar Configuration
// Tweak these values to customize the calendar appearance

struct CalendarStyle {
    // Colors
    var accentColor: Color = .purple
    var todayColor: Color = .blue
    var backgroundColor: Color = .clear
    var headerTextColor: Color = .primary
    var dayTextColor: Color = .primary
    var outsideMonthTextColor: Color = .secondary
    var entryDotColor: Color = .purple

    // Sizing
    var dayCellSize: CGFloat = 40
    var dayCellCornerRadius: CGFloat = 10
    var dayFont: Font = .system(size: 16, weight: .medium)
    var headerFont: Font = .system(size: 24, weight: .bold)
    var monthLabelFont: Font = .system(size: 20, weight: .bold)
    var weekdayFont: Font = .system(size: 13, weight: .semibold)
    var spacing: CGFloat = 8

    // How many months to show before/after the current month
    var monthsBefore: Int = 12
    var monthsAfter: Int = 12
}

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [JournalEntry]
    @State private var selectedDay: SelectedDay?
    @State private var hasScrolledToToday = false

    // Customize this to change appearance
    var style = CalendarStyle()

    private var calendar: Calendar { Calendar.current }

    private var months: [Date] {
        let today = Date()
        let totalMonths = style.monthsBefore + 1 + style.monthsAfter
        return (-style.monthsBefore..<(style.monthsAfter + 1)).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: calendar.startOfMonth(for: today))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(months, id: \.self) { month in
                            VStack(spacing: 0) {
                                monthHeader(for: month)
                                monthGrid(for: month)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    guard !hasScrolledToToday else { return }
                    hasScrolledToToday = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let today = calendar.startOfMonth(for: Date())
                        proxy.scrollTo(today, anchor: .top)
                    }
                }
            }
            .background(style.backgroundColor)
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(item: $selectedDay) { day in
                JournalEntryView(
                    date: day.date,
                    entry: entryFor(date: day.date)
                )
            }
        }
    }

    // MARK: - Month header

    private func monthHeader(for month: Date) -> some View {
        Text(month.formatted(.dateTime.month(.wide).year()))
            .font(style.monthLabelFont)
            .foregroundStyle(style.headerTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.bottom, 4)
            .background(.regularMaterial)
    }

    // MARK: - Weekday labels (shown per month)

    private var weekdayHeader: some View {
        let symbols = calendar.shortWeekdaySymbols
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { day in
                Text(day.uppercased())
                    .font(style.weekdayFont)
                    .foregroundStyle(style.outsideMonthTextColor)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Grid for a single month

    private func monthGrid(for month: Date) -> some View {
        let days = daysInMonthGrid(for: month)
        let rows = days.chunked(into: 7)

        return VStack(spacing: style.spacing) {
            weekdayHeader

            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(rows[rowIndex].indices, id: \.self) { colIndex in
                        let day = rows[rowIndex][colIndex]
                        dayCellView(for: day, in: month)
                    }
                }
            }
        }
        .id(month)
    }

    // MARK: - Individual day cell

    private func dayCellView(for day: DayItem, in month: Date) -> some View {
        let isToday = calendar.isDateInToday(day.date)
        let isCurrentMonth = calendar.isDate(day.date, equalTo: month, toGranularity: .month)
        let hasEntry = entryFor(date: day.date) != nil

        return Button {
            selectedDay = SelectedDay(date: day.date)
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(style.dayFont)
                    .foregroundStyle(
                        isToday ? .white :
                        isCurrentMonth ? style.dayTextColor : style.outsideMonthTextColor
                    )
                    .frame(width: style.dayCellSize, height: style.dayCellSize)
                    .background {
                        if isToday {
                            RoundedRectangle(cornerRadius: style.dayCellCornerRadius)
                                .fill(style.todayColor)
                        }
                    }

                Circle()
                    .fill(hasEntry ? style.entryDotColor : .clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func entryFor(date: Date) -> JournalEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func daysInMonthGrid(for month: Date) -> [DayItem] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = firstWeekday - calendar.firstWeekday
        let adjustedLeading = leadingEmptyDays < 0 ? leadingEmptyDays + 7 : leadingEmptyDays

        var days: [DayItem] = []

        for i in (0..<adjustedLeading).reversed() {
            if let date = calendar.date(byAdding: .day, value: -(i + 1), to: firstOfMonth) {
                days.append(DayItem(date: date))
            }
        }

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(DayItem(date: date))
            }
        }

        let remaining = 7 - (days.count % 7)
        if remaining < 7 {
            if let lastDay = days.last?.date {
                for i in 1...remaining {
                    if let date = calendar.date(byAdding: .day, value: i, to: lastDay) {
                        days.append(DayItem(date: date))
                    }
                }
            }
        }

        return days
    }
}

// MARK: - Calendar extension

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: self.dateComponents([.year, .month], from: date)) ?? date
    }
}

struct DayItem {
    let date: Date
}

struct SelectedDay: Identifiable {
    let id = UUID()
    let date: Date
}

// MARK: - Array chunking helper

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
