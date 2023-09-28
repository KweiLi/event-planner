//
//  EventSchedulerView.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-09-26.
//

import SwiftUI

struct EventSchedulerView: View {
    
    let locationAnnotation:LocationAnnotation
            
    // Save Event to Firebase
    @StateObject var firebaseAPIManager = FirebaseAPIManager()
    
    // Flag to Show Alert when Saving Fails
    @State private var showingAlert = false

    // Store the Event Date
    @State private var selectedDate = Date()
    
    // Flag to control the Display of Selected Date
    @State private var isDateSelected = false
    
    // Store the current Month
    @State private var centeredDate = Date()
    
    // Store the Time
    @State private var selectedTimeIndex: Int? = nil
    
    // Control the Popover for not picking a Date
    @State private var showDateWarning = false
    
    // Store the Alert Message for Event Save Failure
    @State private var alertMessage = ""
    
    @State private var eventDateString = ""
    @State private var eventTimeString = ""
    
    let times = Array(stride(from: 0, to: 24, by: 1)).map { $0 }
    
    var datesInCenteredMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: centeredDate) ?? 1..<32
        return range.map { day in
            var components = calendar.dateComponents([.year, .month, .day], from: centeredDate)
            components.day = day
            return calendar.date(from: components) ?? centeredDate
        }
    }
    
    var body: some View {
        VStack {
            // Month and Year Information with arrows
            HStack {
                Button(action: {
                    centeredDate = Calendar.current.date(byAdding: .month, value: -1, to: centeredDate) ?? centeredDate
                }) {
                    Image(systemName: "chevron.left")
                        .frame(width: 35, height: 44)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(22)
                }
                
                Spacer()
                
                Text(monthYearString(from: centeredDate))
                    .font(.title)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    centeredDate = Calendar.current.date(byAdding: .month, value: 1, to: centeredDate) ?? centeredDate
                }) {
                    Image(systemName: "chevron.right")
                        .frame(width: 35, height: 44)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(22)
                }
            }
            .padding()
            
            // Horizontal Date Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(datesInCenteredMonth, id: \.self) { date in
                        DateView(date: date, isSelected: selectedDate == date)
                            .onTapGesture {
                                selectedDate = date
                                isDateSelected = true
                            }
                    }
                }
                .padding()
            }
            
            // Vertical Time Picker
            ScrollView(showsIndicators: false) {
                ForEach(Array(stride(from: 0, to: 24 * 60, by: 30)), id: \.self) { minutes in
                    let time = minutes / 60
                    let minuteString = minutes % 60 == 0 ? "00" : "30"
                    Button(action: {
                        if isDateSelected {
                            selectedTimeIndex = minutes
                            let hours = minutes / 60
                            let minutesComponent = minutes % 60
                            if let selectedDateTime = Calendar.current.date(bySettingHour: hours, minute: minutesComponent, second: 0, of: selectedDate) {
                                // DateFormatter for Date
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                dateFormatter.timeZone = TimeZone.current
                                eventDateString = dateFormatter.string(from: selectedDateTime)
                                
                                // DateFormatter for Time
                                let timeFormatter = DateFormatter()
                                timeFormatter.dateFormat = "HH:mm"
                                timeFormatter.timeZone = TimeZone.current
                                eventTimeString = timeFormatter.string(from: selectedDateTime)
                            }
                        } else {
                            showDateWarning = true
                        }
                    }){
                        HStack {
                            Text("\(time):\(minuteString)")
                                .frame(width: 60, alignment: .leading)
                                .padding()
                                .background(minutes == selectedTimeIndex ? Color.purple.opacity(0.6) : Color.clear)
                            
                            Spacer()
                            
                            if minutes == selectedTimeIndex {
                                Text("This row is clicked")
                                    .padding()
                            }
                        }
                        .frame(height: 44)
                        .background(Color.purple.opacity(minutes == selectedTimeIndex ? 0.3 : 0))
                    }
                    .foregroundColor(.black)
                }
            }
            .popover(isPresented: $showDateWarning, arrowEdge: .top) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Oops! Do you want to pick a date first?")
                }
                .padding()
            }
            
            VStack {
                Button(action:{
                    if isDateSelected == false || selectedTimeIndex == nil {
                        showDateWarning =  true
                    } else{
                        Task {
                            await saveEvent()
                        }
                    }
                }) {
                    Text("Add to Calendar")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.purple)
                        )
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func saveEvent() async {
        let event = Event(fsq_id: locationAnnotation.fsq_id, place_name: locationAnnotation.title , place_addr: locationAnnotation.address, eventTime: eventTimeString, eventDate: eventDateString)
        
        do {
            try await firebaseAPIManager.writeEvent(event: event)
            alertMessage = "Event saved successfully!"
        } catch {
            alertMessage = (error as? CustomizedError)?.localizedDescription ?? "An error occurred"
        }
        showingAlert = true
        print(event)
    }
}

struct DateView: View {
    var date: Date
    var isSelected: Bool
    
    var body: some View {
        VStack (spacing: 5) {
            Text(weekdayString(from: date))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)

            Text("\(Calendar.current.component(.day, from: date))")
                .font(.title)
                .foregroundColor(isSelected ? .white : .black)
        }
        .frame(width: 70, height: 70)
        .padding(5)
        .background(isSelected ? Color.purple.opacity(0.9) : Color.clear)
        .border(
            Color.gray.opacity(0.7)
        )
    }
    
    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let weekdayString = formatter.string(from: date)
        return String(weekdayString.prefix(3)).uppercased()
    }
}

//struct EventSchedulerView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventSchedulerView()
//    }
//}
