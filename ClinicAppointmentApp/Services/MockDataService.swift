import Foundation
import Combine

class MockDataService: ObservableObject {
    static let shared = MockDataService()

    @Published var specialties: [Specialty] = [
        Specialty(id: 1, name: "General Physician"), Specialty(id: 2, name: "Cardiology"),
        Specialty(id: 3, name: "Gastroenterology"), Specialty(id: 4, name: "Dentistry"),
        Specialty(id: 5, name: "Pediatrics"), Specialty(id: 6, name: "Orthopedics"),
        Specialty(id: 7, name: "Dermatology"), Specialty(id: 8, name: "Neurology")
    ]

    @Published var services: [Service] = [
        Service(id: 1, name: "General Consultation", duration: 20, price: 50, specialtyId: 1),
        Service(id: 2, name: "Follow-up Visit", duration: 15, price: 40, specialtyId: 1),
        Service(id: 3, name: "Cardiac Consultation", duration: 30, price: 120, specialtyId: 2),
        Service(id: 4, name: "ECG / Heart Check", duration: 25, price: 80, specialtyId: 2),
        Service(id: 5, name: "Gastro Consultation", duration: 30, price: 100, specialtyId: 3),
        Service(id: 6, name: "Dental Check-up", duration: 30, price: 70, specialtyId: 4),
        Service(id: 7, name: "Pediatric Consultation", duration: 25, price: 60, specialtyId: 5)
    ]

    @Published var doctors: [Doctor] = [
        Doctor(id: 1, name: "Dr. Michael Anderson", title: "MBBS, MD – General Physician", specialties: [1], experience: "15 years", imageURL: "", workingHours: WorkingHours(mon: DayHours(start:"09:00",end:"17:00"), tue: DayHours(start:"09:00",end:"17:00"), wed: DayHours(start:"09:00",end:"17:00"), thu: DayHours(start:"09:00",end:"17:00"), fri: DayHours(start:"09:00",end:"15:00"), sat: nil, sun: nil), leaveDates: [], locationId: 1),
        Doctor(id: 2, name: "Dr. Sarah Patel", title: "MBBS, MD – Cardiologist", specialties: [2], experience: "12 years", imageURL: "", workingHours: WorkingHours(mon: DayHours(start:"10:00",end:"18:00"), tue: DayHours(start:"10:00",end:"18:00"), wed: DayHours(start:"10:00",end:"18:00"), thu: DayHours(start:"10:00",end:"18:00"), fri: DayHours(start:"10:00",end:"16:00"), sat: DayHours(start:"09:00",end:"13:00"), sun: nil), leaveDates: [], locationId: 1),
        Doctor(id: 3, name: "Dr. Emily Chen", title: "DDS – Dentist", specialties: [4], experience: "8 years", imageURL: "", workingHours: WorkingHours(mon: DayHours(start:"09:00",end:"17:00"), tue: DayHours(start:"09:00",end:"17:00"), wed: DayHours(start:"09:00",end:"17:00"), thu: DayHours(start:"09:00",end:"17:00"), fri: DayHours(start:"09:00",end:"15:00"), sat: DayHours(start:"10:00",end:"14:00"), sun: nil), leaveDates: [], locationId: 1)
    ]

    @Published var patients: [Patient] = [
        Patient(id: 1, name: "Sarah Mitchell", email: "sarah.m@example.com", phone: "+1 555-0101", dob: "1988-04-12"),
        Patient(id: 2, name: "Robert Chen", email: "robert.c@example.com", phone: "+1 555-0102", dob: "1975-11-03"),
        Patient(id: 3, name: "Emily Lawson", email: "emily.l@example.com", phone: "+1 555-0103", dob: "1992-07-22")
    ]

    @Published var locations: [Location] = [
        Location(id: 1, name: "Harlay Clinic – Main Branch", address: "1248 Wellness Avenue, Suite 200, Springfield", phone: "(555) 234-5678"),
        Location(id: 2, name: "Harlay Clinic – North Wing", address: "450 Oak Street, Springfield", phone: "(555) 234-5690")
    ]

    @Published var appointments: [Appointment] = []
    @Published var feedback: [Feedback] = []
    @Published var waitingList: [WaitingEntry] = []
    @Published var notifications: [AppNotification] = [
        AppNotification(id: 1, type: "Email", message: "Appointment confirmed for Sarah Mitchell", time: "2 hours ago", read: false),
        AppNotification(id: 2, type: "WhatsApp", message: "Reminder: Dr. Anderson has 3 patients today", time: "5 hours ago", read: false),
        AppNotification(id: 3, type: "System", message: "New patient registered", time: "Yesterday", read: true)
    ]

    private init() { seed() }

    private func dateString(offset: Int) -> String {
        let d = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d)
    }

    private func seed() {
        appointments = [
            Appointment(id: 1001, patientId: 1, doctorId: 1, serviceId: 1, locationId: 1, date: dateString(offset: 2), time: "10:00", status: .confirmed, source: "Patient", notes: "", prescription: "", checkInStatus: "Scheduled", createdAt: dateString(offset: -3)),
            Appointment(id: 1002, patientId: 2, doctorId: 2, serviceId: 3, locationId: 1, date: dateString(offset: 5), time: "14:30", status: .confirmed, source: "Admin", notes: "Cardiac follow-up", prescription: "", checkInStatus: "Scheduled", createdAt: dateString(offset: -1)),
            Appointment(id: 1004, patientId: 1, doctorId: 3, serviceId: 6, locationId: 1, date: dateString(offset: -5), time: "15:00", status: .completed, source: "Patient", notes: "Routine dental check. No cavities.", prescription: "Fluoride toothpaste twice daily.", checkInStatus: "Completed", createdAt: dateString(offset: -12)),
            Appointment(id: 1009, patientId: 1, doctorId: 2, serviceId: 3, locationId: 1, date: dateString(offset: 4), time: "10:30", status: .pending, source: "Patient", notes: "", prescription: "", checkInStatus: "Scheduled", createdAt: dateString(offset: -1)),
            Appointment(id: 1010, patientId: 1, doctorId: 3, serviceId: 6, locationId: 1, date: dateString(offset: 6), time: "11:00", status: .awaitingPatientResponse, source: "Admin", notes: "Reschedule requested", prescription: "", checkInStatus: "Scheduled", createdAt: dateString(offset: -2), originalDate: dateString(offset: 3), originalTime: "09:00"),
            Appointment(id: 1011, patientId: 1, doctorId: 1, serviceId: 2, locationId: 1, date: dateString(offset: -9), time: "09:30", status: .cancelled, source: "Patient", notes: "", prescription: "", checkInStatus: "Scheduled", createdAt: dateString(offset: -12)),
            Appointment(id: 1008, patientId: 1, doctorId: 1, serviceId: 1, locationId: 1, date: dateString(offset: -20), time: "11:00", status: .completed, source: "Patient", notes: "Mild hypertension. Lifestyle advice given.", prescription: "Amlodipine 5mg once daily.", checkInStatus: "Completed", createdAt: dateString(offset: -25))
        ]
        waitingList = [
            WaitingEntry(id: 1, patientId: 2, doctorId: 1, serviceId: 1, locationId: 1, preferredDate: dateString(offset: 3), notes: "Prefers morning", status: "Waiting")
        ]
        feedback = [
            Feedback(id: 1, appointmentId: 1004, patientId: 1, doctorId: 3, rating: 5, comment: "Excellent care", createdAt: dateString(offset: -4))
        ]
    }

    func doctor(by id: Int) -> Doctor? { doctors.first { $0.id == id } }
    func patient(by id: Int) -> Patient? { patients.first { $0.id == id } }
    func service(by id: Int) -> Service? { services.first { $0.id == id } }
    func specialty(by id: Int) -> Specialty? { specialties.first { $0.id == id } }
    func location(by id: Int) -> Location? { locations.first { $0.id == id } }

    func availableSlots(for doctorId: Int, on dateString: String) -> [TimeSlot] {
        guard let doctor = doctor(by: doctorId) else { return [] }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dateString) else { return [] }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard date >= today else { return [] }
        if let maxD = cal.date(byAdding: .day, value: ClinicRules.maxAdvanceDays, to: today), date > maxD { return [] }

        let weekday = cal.component(.weekday, from: date)
        let hours: DayHours?
        switch weekday {
        case 1: hours = doctor.workingHours.sun
        case 2: hours = doctor.workingHours.mon
        case 3: hours = doctor.workingHours.tue
        case 4: hours = doctor.workingHours.wed
        case 5: hours = doctor.workingHours.thu
        case 6: hours = doctor.workingHours.fri
        case 7: hours = doctor.workingHours.sat
        default: hours = nil
        }
        guard let dayHours = hours, !doctor.leaveDates.contains(dateString) else { return [] }

        var slots: [TimeSlot] = []
        let sp = dayHours.start.split(separator: ":").compactMap { Int($0) }
        let ep = dayHours.end.split(separator: ":").compactMap { Int($0) }
        guard sp.count == 2, ep.count == 2 else { return [] }
        var cur = sp[0]*60 + sp[1]
        let end = ep[0]*60 + ep[1]
        while cur + ClinicRules.defaultSlotDurationMinutes <= end {
            let h = cur/60; let m = cur%60
            let timeStr = String(format: "%02d:%02d", h, m)
            var comps = cal.dateComponents([.year,.month,.day], from: date)
            comps.hour = h; comps.minute = m
            if let slotDate = cal.date(from: comps), slotDate.timeIntervalSince(Date())/3600 < Double(ClinicRules.minNoticeHours) {
                cur += ClinicRules.defaultSlotDurationMinutes; continue
            }
            let booked = appointments.contains { $0.doctorId == doctorId && $0.date == dateString && $0.time == timeStr && ![.cancelled,.rescheduled].contains($0.status) }
            slots.append(TimeSlot(time: timeStr, available: !booked))
            cur += ClinicRules.defaultSlotDurationMinutes
        }
        return slots
    }

    func updateStatus(appointmentId: Int, to status: AppointmentStatus) {
        if let i = appointments.firstIndex(where: { $0.id == appointmentId }) {
            appointments[i].status = status
        }
    }

    func updateNotes(appointmentId: Int, notes: String, prescription: String, markCompleted: Bool = false) {
        if let i = appointments.firstIndex(where: { $0.id == appointmentId }) {
            appointments[i].notes = notes
            appointments[i].prescription = prescription
            if markCompleted { appointments[i].status = .completed }
        }
    }

    func setCheckIn(appointmentId: Int, status: String) {
        if let i = appointments.firstIndex(where: { $0.id == appointmentId }) {
            appointments[i].checkInStatus = status
            if status == "Completed" { appointments[i].status = .completed }
        }
    }

    func addAppointment(_ a: Appointment) { appointments.append(a) }

    @discardableResult
    func addPatient(name: String, email: String, phone: String, dob: String) -> (patient: Patient, isNew: Bool) {
        let emailNorm = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let phoneNorm = phone.replacingOccurrences(of: " ", with: "")
        if let existing = patients.first(where: {
            (!$0.email.isEmpty && $0.email.lowercased() == emailNorm) ||
            (!$0.phone.isEmpty && $0.phone.replacingOccurrences(of: " ", with: "") == phoneNorm)
        }) {
            return (existing, false)
        }
        let nextId = (patients.map(\.id).max() ?? 0) + 1
        let p = Patient(id: nextId, name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                        dob: dob)
        patients.append(p)
        return (p, true)
    }

    func addService(name: String, specialtyId: Int, duration: Int, price: Double) {
        let id = (services.map(\.id).max() ?? 0) + 1
        services.append(Service(id: id, name: name, duration: duration, price: price, specialtyId: specialtyId))
    }

    func addSpecialty(name: String) {
        let id = (specialties.map(\.id).max() ?? 0) + 1
        specialties.append(Specialty(id: id, name: name))
    }

    func addLocation(name: String, address: String, phone: String) {
        let id = (locations.map(\.id).max() ?? 0) + 1
        locations.append(Location(id: id, name: name, address: address, phone: phone))
    }

    func addDoctor(name: String, title: String, specialtyId: Int, experience: String) {
        let id = (doctors.map(\.id).max() ?? 0) + 1
        let hours = WorkingHours(mon: DayHours(start:"09:00",end:"17:00"), tue: DayHours(start:"09:00",end:"17:00"), wed: DayHours(start:"09:00",end:"17:00"), thu: DayHours(start:"09:00",end:"17:00"), fri: DayHours(start:"09:00",end:"15:00"), sat: nil, sun: nil)
        doctors.append(Doctor(id: id, name: name, title: title, specialties: [specialtyId], experience: experience, imageURL: "", workingHours: hours, leaveDates: [], locationId: 1))
    }

    func addFeedback(appointmentId: Int, patientId: Int, doctorId: Int, rating: Int, comment: String) {
        let id = (feedback.map(\.id).max() ?? 0) + 1
        feedback.append(Feedback(id: id, appointmentId: appointmentId, patientId: patientId, doctorId: doctorId, rating: rating, comment: comment, createdAt: dateString(offset: 0)))
    }

    func reportStats() -> (total: Int, completed: Int, revenue: Double, avgRating: String, waiting: Int) {
        let completed = appointments.filter { $0.status == .completed }
        let revenue = completed.reduce(0.0) { $0 + (service(by: $1.serviceId)?.price ?? 0) }
        let avg: String
        if feedback.isEmpty { avg = "—" }
        else {
            let s = Double(feedback.reduce(0) { $0 + $1.rating }) / Double(feedback.count)
            avg = String(format: "%.1f", s)
        }
        return (appointments.count, completed.count, revenue, avg, waitingList.filter { $0.status == "Waiting" }.count)
    }

    func todayQueue(locationId: Int? = nil) -> [Appointment] {
        let today = dateString(offset: 0)
        return appointments.filter {
            $0.date == today &&
            [.confirmed, .pending].contains($0.status) &&
            (locationId == nil || $0.locationId == locationId)
        }.sorted { $0.time < $1.time }
    }
}
