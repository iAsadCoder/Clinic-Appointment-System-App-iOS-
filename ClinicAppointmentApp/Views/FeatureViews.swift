import SwiftUI

// MARK: - Role Portal (routes menu → screens)
struct RolePortalView: View {
    let role: UserRole
    let userId: Int
    var onLogout: () -> Void
    @EnvironmentObject var data: MockDataService
    @State private var selected: MenuItem = .dashboard

    private var userName: String {
        switch role {
        case .patient: return data.patient(by: userId)?.name ?? "Patient"
        case .doctor: return data.doctor(by: userId)?.name ?? "Doctor"
        case .admin: return "Admin User"
        case .receptionist: return "Front Desk"
        }
    }
    private var userSubtitle: String {
        switch role {
        case .patient: return "Patient Portal"
        case .doctor: return data.doctor(by: userId)?.title ?? "Doctor"
        case .admin: return "Super Administrator"
        case .receptionist: return "Reception Desk"
        }
    }

    var body: some View {
        SideMenuShell(role: role, userName: userName, userSubtitle: userSubtitle, selected: $selected, onLogout: onLogout) {
            Group {
                switch selected {
                case .dashboard:
                    if role == .receptionist { QueueView() }
                    else if role == .doctor { DoctorHomeView(doctorId: userId) }
                    else if role == .admin { AdminHomeView() }
                    else { PatientHomeView(patientId: userId) }
                case .queue: QueueView()
                case .book: BookAppointmentView(patientId: userId)
                case .bookForPatient: BookForPatientView()
                case .appointments:
                    if role == .doctor { DoctorAppointmentsView(doctorId: userId) }
                    else if role == .admin { AdminAppointmentsView() }
                    else { PatientAppointmentsView(patientId: userId) }
                case .history: PatientHistoryView(patientId: userId)
                case .feedback: PatientFeedbackView(patientId: userId)
                case .profile: ProfileView(role: role, userId: userId)
                case .availability: DoctorAvailabilityView(doctorId: userId)
                case .patients: PatientsManageView(role: role, doctorId: role == .doctor ? userId : nil)
                case .notes: ClinicalNotesListView(doctorId: userId)
                case .doctors: DoctorsManageView()
                case .services: ServicesManageView()
                case .schedules: SchedulesView()
                case .locations: LocationsManageView()
                case .specialties: SpecialtiesManageView()
                case .waiting: WaitingListView()
                case .billing: BillingView()
                case .reports: ReportsView()
                case .notifications: NotificationsView()
                case .settings: SettingsView()
                case .logout: EmptyView()
                }
            }
        }
        .onAppear {
            selected = MenuItem.items(for: role).first(where: { $0 != .logout }) ?? .dashboard
        }
    }
}

// MARK: - Patient Home
struct PatientHomeView: View {
    let patientId: Int
    @EnvironmentObject var data: MockDataService
    private var my: [Appointment] { data.appointments.filter { $0.patientId == patientId } }
    private var upcoming: [Appointment] { my.filter { [.pending, .confirmed].contains($0.status) }.sorted { $0.date < $1.date } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome back, \((data.patient(by: patientId)?.name ?? "").split(separator: " ").first.map(String.init) ?? "Patient")")
                    .font(.title3.weight(.semibold)).foregroundStyle(Color.navy)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTile(title: "Upcoming", value: "\(upcoming.count)", subtitle: "Appointments", icon: "calendar", color: .brand)
                    StatTile(title: "Completed", value: "\(my.filter{$0.status == .completed}.count)", subtitle: "Visits", icon: "checkmark.circle", color: .green)
                    StatTile(title: "Awaiting", value: "\(my.filter{$0.status == .awaitingPatientResponse}.count)", subtitle: "Action needed", icon: "clock", color: .orange)
                    StatTile(title: "Cancelled", value: "\(my.filter{$0.status == .cancelled}.count)", subtitle: "Appointments", icon: "xmark.circle", color: .red)
                }
                SectionHeader(title: "Upcoming")
                if upcoming.isEmpty {
                    EmptyStateView(icon: "calendar", title: "No upcoming visits", message: "Book an appointment from the menu.")
                } else {
                    VStack(spacing: 0) {
                        ForEach(upcoming.prefix(5)) { a in
                            AppointmentRow(appointment: a)
                            Divider()
                        }
                    }.card(padding: 12)
                }
            }.padding()
        }.background(Color.screenBG)
    }
}

// MARK: - Book
struct BookAppointmentView: View {
    let patientId: Int
    @EnvironmentObject var data: MockDataService
    @State private var doctorId: Int = 1
    @State private var serviceId: Int = 1
    @State private var date = Date().addingTimeInterval(86400 * 2)
    @State private var selectedTime: String?
    @State private var message: String?

    private var dateStr: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
    private var slots: [TimeSlot] { data.availableSlots(for: doctorId, on: dateStr) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Book Appointment").font(.title3.weight(.semibold)).foregroundStyle(Color.navy)
                Picker("Doctor", selection: $doctorId) {
                    ForEach(data.doctors) { d in Text(d.name).tag(d.id) }
                }.pickerStyle(.menu).card(padding: 8)
                Picker("Service", selection: $serviceId) {
                    ForEach(data.services) { s in Text("\(s.name) · $\(Int(s.price))").tag(s.id) }
                }.pickerStyle(.menu).card(padding: 8)
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
                    .card(padding: 12)
                Text("Available slots").font(.subheadline.weight(.semibold))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], spacing: 8) {
                    ForEach(slots) { slot in
                        Button {
                            if slot.available { selectedTime = slot.time }
                        } label: {
                            Text(Formatters.time12(slot.time))
                                .font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTime == slot.time ? Color.brand : (slot.available ? Color.brandLight : Color.gray.opacity(0.15)))
                                .foregroundStyle(selectedTime == slot.time ? .white : (slot.available ? Color.brand : .secondary))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .disabled(!slot.available)
                    }
                }
                if slots.isEmpty {
                    Text("No slots for this day.").font(.caption).foregroundStyle(.secondary)
                }
                Button {
                    guard let t = selectedTime else { message = "Select a time slot."; return }
                    let id = (data.appointments.map(\.id).max() ?? 1000) + 1
                    data.addAppointment(Appointment(id: id, patientId: patientId, doctorId: doctorId, serviceId: serviceId, date: dateStr, time: t, status: .pending, source: "Patient", notes: "", prescription: "", createdAt: dateStr))
                    message = "Appointment #\(id) requested."
                    selectedTime = nil
                } label: {
                    Text("Request Appointment").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.brand).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                if let message { Text(message).font(.footnote).foregroundStyle(Color.brand) }
            }.padding()
        }.background(Color.screenBG)
    }
}

struct BookForPatientView: View {
    @EnvironmentObject var data: MockDataService
    @State private var patientId = 1
    @State private var doctorId = 1
    @State private var serviceId = 1
    @State private var date = Date().addingTimeInterval(86400 * 2)
    @State private var selectedTime: String?
    @State private var message: String?
    private var dateStr: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Book for Patient").font(.title3.weight(.semibold)).foregroundStyle(Color.navy)
                Picker("Patient", selection: $patientId) {
                    ForEach(data.patients) { p in Text(p.name).tag(p.id) }
                }.pickerStyle(.menu).card(padding: 8)
                Picker("Doctor", selection: $doctorId) {
                    ForEach(data.doctors) { d in Text(d.name).tag(d.id) }
                }.pickerStyle(.menu).card(padding: 8)
                Picker("Service", selection: $serviceId) {
                    ForEach(data.services) { s in Text(s.name).tag(s.id) }
                }.pickerStyle(.menu).card(padding: 8)
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date).card(padding: 12)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], spacing: 8) {
                    ForEach(data.availableSlots(for: doctorId, on: dateStr)) { slot in
                        Button { if slot.available { selectedTime = slot.time } } label: {
                            Text(Formatters.time12(slot.time)).font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(selectedTime == slot.time ? Color.brand : Color.brandLight)
                                .foregroundStyle(selectedTime == slot.time ? .white : Color.brand)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }.disabled(!slot.available)
                    }
                }
                Button {
                    guard let t = selectedTime else { return }
                    let id = (data.appointments.map(\.id).max() ?? 1000) + 1
                    data.addAppointment(Appointment(id: id, patientId: patientId, doctorId: doctorId, serviceId: serviceId, date: dateStr, time: t, status: .confirmed, source: "Receptionist", notes: "", prescription: "", createdAt: dateStr))
                    message = "Booked #\(id)"
                } label: {
                    Text("Create Appointment").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.brand).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                if let message { Text(message).foregroundStyle(Color.brand) }
            }.padding()
        }.background(Color.screenBG)
    }
}

// MARK: - Lists
struct PatientAppointmentsView: View {
    let patientId: Int
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.appointments.filter { $0.patientId == patientId }.sorted { $0.date > $1.date }) { a in
                AppointmentRow(appointment: a)
            }
        }.listStyle(.insetGrouped).background(Color.screenBG)
    }
}

struct PatientHistoryView: View {
    let patientId: Int
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.appointments.filter { $0.patientId == patientId && $0.status == .completed }) { a in
                VStack(alignment: .leading, spacing: 6) {
                    AppointmentRow(appointment: a)
                    if !a.notes.isEmpty {
                        Text("Notes: \(a.notes)").font(.caption).foregroundStyle(.secondary)
                    }
                    if !a.prescription.isEmpty {
                        Text("Rx: \(a.prescription)").font(.caption).foregroundStyle(Color.brand)
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct PatientFeedbackView: View {
    let patientId: Int
    @EnvironmentObject var data: MockDataService
    @State private var rating = 5
    @State private var comment = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Leave Feedback").font(.title3.weight(.semibold))
                Stepper("Rating: \(rating)/5", value: $rating, in: 1...5).card()
                TextField("Comment", text: $comment, axis: .vertical).lineLimit(3...6).card()
                Button("Submit") {
                    if let a = data.appointments.first(where: { $0.patientId == patientId && $0.status == .completed }) {
                        data.addFeedback(appointmentId: a.id, patientId: patientId, doctorId: a.doctorId, rating: rating, comment: comment)
                        comment = ""
                    }
                }
                .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.brand).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                SectionHeader(title: "Your reviews")
                ForEach(data.feedback.filter { $0.patientId == patientId }) { f in
                    VStack(alignment: .leading) {
                        Text(String(repeating: "★", count: f.rating)).foregroundStyle(.orange)
                        Text(f.comment).font(.subheadline)
                    }.card()
                }
            }.padding()
        }.background(Color.screenBG)
    }
}

struct ProfileView: View {
    let role: UserRole
    let userId: Int
    @EnvironmentObject var data: MockDataService
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AvatarView(name: displayName, size: 80)
                Text(displayName).font(.title2.weight(.bold))
                Text(role.title).font(.subheadline).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 10) {
                    if role == .patient, let p = data.patient(by: userId) {
                        labeled("Email", p.email)
                        labeled("Phone", p.phone)
                        labeled("DOB", p.dob)
                    } else if role == .doctor, let d = data.doctor(by: userId) {
                        labeled("Title", d.title)
                        labeled("Experience", d.experience)
                    } else {
                        labeled("Portal", role.title + " full access")
                    }
                }.card()
            }.padding()
        }.background(Color.screenBG)
    }
    private var displayName: String {
        switch role {
        case .patient: return data.patient(by: userId)?.name ?? "Patient"
        case .doctor: return data.doctor(by: userId)?.name ?? "Doctor"
        case .admin: return "Admin User"
        case .receptionist: return "Front Desk"
        }
    }
    private func labeled(_ k: String, _ v: String) -> some View {
        HStack { Text(k).foregroundStyle(.secondary); Spacer(); Text(v) }
    }
}

// MARK: - Doctor
struct DoctorHomeView: View {
    let doctorId: Int
    @EnvironmentObject var data: MockDataService
    private var my: [Appointment] { data.appointments.filter { $0.doctorId == doctorId } }
    private var active: [Appointment] { my.filter { ![.cancelled, .completed, .rescheduled].contains($0.status) } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTile(title: "Assigned", value: "\(my.count)", subtitle: "Total", icon: "calendar", color: .brand)
                    StatTile(title: "Active", value: "\(active.count)", subtitle: "Need attention", icon: "clock", color: .orange)
                    StatTile(title: "Done", value: "\(my.filter{$0.status == .completed}.count)", subtitle: "Completed", icon: "checkmark.circle", color: .green)
                    StatTile(title: "Patients", value: "\(Set(my.map(\.patientId)).count)", subtitle: "Unique", icon: "person.2", color: .purple)
                }
                SectionHeader(title: "Active appointments")
                ForEach(active) { a in
                    VStack(alignment: .leading, spacing: 8) {
                        AppointmentRow(appointment: a, showPatient: true)
                        HStack {
                            Button("Complete") { data.updateStatus(appointmentId: a.id, to: .completed) }
                                .buttonStyle(.borderedProminent).tint(.green).controlSize(.small)
                            Button("Cancel") { data.updateStatus(appointmentId: a.id, to: .cancelled) }
                                .buttonStyle(.bordered).tint(.red).controlSize(.small)
                        }
                    }.card(padding: 12)
                }
            }.padding()
        }.background(Color.screenBG)
    }
}

struct DoctorAppointmentsView: View {
    let doctorId: Int
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.appointments.filter { $0.doctorId == doctorId }.sorted { $0.date > $1.date }) { a in
                AppointmentRow(appointment: a, showPatient: true)
            }
        }.listStyle(.insetGrouped)
    }
}

struct DoctorAvailabilityView: View {
    let doctorId: Int
    @EnvironmentObject var data: MockDataService
    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    var body: some View {
        List {
            if let d = data.doctor(by: doctorId) {
                let hours = [d.workingHours.mon, d.workingHours.tue, d.workingHours.wed, d.workingHours.thu, d.workingHours.fri, d.workingHours.sat, d.workingHours.sun]
                ForEach(0..<7, id: \.self) { i in
                    HStack {
                        Text(days[i]).frame(width: 44, alignment: .leading)
                        if let h = hours[i] {
                            Text("\(h.start) – \(h.end)").foregroundStyle(Color.brand)
                        } else {
                            Text("Off").foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct ClinicalNotesListView: View {
    let doctorId: Int
    @EnvironmentObject var data: MockDataService
    @State private var edit: Appointment?
    @State private var notes = ""
    @State private var rx = ""
    var body: some View {
        List {
            ForEach(data.appointments.filter { $0.doctorId == doctorId }) { a in
                Button {
                    edit = a; notes = a.notes; rx = a.prescription
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        AppointmentRow(appointment: a, showPatient: true)
                        if !a.notes.isEmpty { Text(a.notes).font(.caption).foregroundStyle(.secondary).lineLimit(2) }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $edit) { a in
            NavigationStack {
                Form {
                    Section("Clinical Notes") { TextEditor(text: $notes).frame(minHeight: 100) }
                    Section("Prescription") { TextEditor(text: $rx).frame(minHeight: 80) }
                }
                .navigationTitle("Notes & Rx")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { edit = nil } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            data.updateNotes(appointmentId: a.id, notes: notes, prescription: rx)
                            edit = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Patients manage + add
struct PatientsManageView: View {
    let role: UserRole
    var doctorId: Int?
    @EnvironmentObject var data: MockDataService
    @State private var showAdd = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { p in
                    HStack {
                        AvatarView(name: p.name, size: 40)
                        VStack(alignment: .leading) {
                            Text(p.name).font(.subheadline.weight(.semibold))
                            Text(p.phone.isEmpty ? p.email : p.phone).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Label("Add", systemImage: "person.badge.plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddPatientForm { name, email, phone, dob in
                    _ = data.addPatient(name: name, email: email, phone: phone, dob: dob)
                    showAdd = false
                }
            }
        }
    }
    private var filtered: [Patient] {
        if let did = doctorId {
            let ids = Set(data.appointments.filter { $0.doctorId == did }.map(\.patientId))
            return data.patients.filter { ids.contains($0.id) }
        }
        return data.patients
    }
}

struct AddPatientForm: View {
    var onSave: (String, String, String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""; @State private var email = ""; @State private var phone = ""; @State private var dob = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Register unregistered patient") {
                    TextField("Full name *", text: $name)
                    TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    TextField("Phone *", text: $phone).keyboardType(.phonePad)
                    TextField("DOB (yyyy-mm-dd)", text: $dob)
                }
            }
            .navigationTitle("Add Patient")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !name.isEmpty, !phone.isEmpty else { return }
                        onSave(name, email, phone, dob)
                    }.fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Admin screens
struct AdminHomeView: View {
    @EnvironmentObject var data: MockDataService
    private var stats: (total: Int, completed: Int, revenue: Double, avgRating: String, waiting: Int) { data.reportStats() }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTile(title: "Total", value: "\(stats.total)", subtitle: "Appointments", icon: "calendar", color: .purple)
                    StatTile(title: "Completed", value: "\(stats.completed)", subtitle: "Visits", icon: "checkmark.circle", color: .green)
                    StatTile(title: "Revenue", value: String(format: "$%.0f", stats.revenue), subtitle: "Completed", icon: "dollarsign.circle", color: .brand)
                    StatTile(title: "Waiting", value: "\(stats.waiting)", subtitle: "List", icon: "hourglass", color: .orange)
                }
                SectionHeader(title: "Recent")
                VStack(spacing: 0) {
                    ForEach(Array(data.appointments.reversed().prefix(6))) { a in
                        AppointmentRow(appointment: a, showPatient: true)
                        Divider()
                    }
                }.card(padding: 12)
            }.padding()
        }.background(Color.screenBG)
    }
}

struct AdminAppointmentsView: View {
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.appointments.sorted { $0.date > $1.date }) { a in
                VStack(alignment: .leading, spacing: 6) {
                    AppointmentRow(appointment: a, showPatient: true)
                    HStack {
                        Button("Confirm") { data.updateStatus(appointmentId: a.id, to: .confirmed) }.controlSize(.small).buttonStyle(.bordered)
                        Button("Complete") { data.updateStatus(appointmentId: a.id, to: .completed) }.controlSize(.small).buttonStyle(.borderedProminent).tint(.green)
                        Button("Cancel") { data.updateStatus(appointmentId: a.id, to: .cancelled) }.controlSize(.small).buttonStyle(.bordered).tint(.red)
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct DoctorsManageView: View {
    @EnvironmentObject var data: MockDataService
    @State private var showAdd = false
    @State private var name = ""; @State private var title = ""; @State private var spec = 1; @State private var exp = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(data.doctors) { d in
                    HStack {
                        AvatarView(name: d.name, size: 44)
                        VStack(alignment: .leading) {
                            Text(d.name).font(.subheadline.weight(.semibold))
                            Text(d.title).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar { Button { showAdd = true } label: { Label("Add", systemImage: "plus") } }
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $name)
                        TextField("Title", text: $title)
                        Picker("Specialty", selection: $spec) {
                            ForEach(data.specialties) { s in Text(s.name).tag(s.id) }
                        }
                        TextField("Experience", text: $exp)
                    }
                    .navigationTitle("Add Doctor")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAdd = false } }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                data.addDoctor(name: name, title: title, specialtyId: spec, experience: exp)
                                showAdd = false; name = ""; title = ""; exp = ""
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ServicesManageView: View {
    @EnvironmentObject var data: MockDataService
    @State private var showAdd = false
    @State private var name = ""; @State private var spec = 1; @State private var dur = 30; @State private var price = 50.0
    var body: some View {
        NavigationStack {
            List {
                ForEach(data.services) { s in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(s.name).font(.subheadline.weight(.medium))
                            Text(data.specialty(by: s.specialtyId)?.name ?? "").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("$\(Int(s.price)) · \(s.duration)m").font(.caption).foregroundStyle(Color.brand)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar { Button { showAdd = true } label: { Label("Add", systemImage: "plus") } }
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $name)
                        Picker("Specialty", selection: $spec) { ForEach(data.specialties) { s in Text(s.name).tag(s.id) } }
                        Stepper("Duration: \(dur) min", value: $dur, in: 10...120, step: 5)
                        TextField("Price", value: $price, format: .number)
                    }
                    .navigationTitle("Add Service")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAdd = false } }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                data.addService(name: name, specialtyId: spec, duration: dur, price: price)
                                showAdd = false; name = ""
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SchedulesView: View {
    @EnvironmentObject var data: MockDataService
    @State private var doctorId = 1
    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    var body: some View {
        VStack {
            Picker("Doctor", selection: $doctorId) {
                ForEach(data.doctors) { d in Text(d.name).tag(d.id) }
            }.pickerStyle(.menu).padding()
            List {
                if let d = data.doctor(by: doctorId) {
                    let hours = [d.workingHours.mon, d.workingHours.tue, d.workingHours.wed, d.workingHours.thu, d.workingHours.fri, d.workingHours.sat, d.workingHours.sun]
                    ForEach(0..<7, id: \.self) { i in
                        HStack {
                            Text(days[i])
                            Spacer()
                            if let h = hours[i] { Text("\(h.start)–\(h.end)").foregroundStyle(Color.brand) }
                            else { Text("Off").foregroundStyle(.secondary) }
                        }
                    }
                }
            }.listStyle(.insetGrouped)
        }.background(Color.screenBG)
    }
}

struct LocationsManageView: View {
    @EnvironmentObject var data: MockDataService
    @State private var showAdd = false
    @State private var name = ""; @State private var address = ""; @State private var phone = ""
    var body: some View {
        NavigationStack {
            List(data.locations) { loc in
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc.name).font(.subheadline.weight(.semibold))
                    Text(loc.address).font(.caption).foregroundStyle(.secondary)
                    Text(loc.phone).font(.caption2).foregroundStyle(Color.brand)
                }
            }
            .listStyle(.insetGrouped)
            .toolbar { Button { showAdd = true } label: { Label("Add", systemImage: "plus") } }
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $name)
                        TextField("Address", text: $address)
                        TextField("Phone", text: $phone)
                    }
                    .navigationTitle("Add Location")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAdd = false } }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                data.addLocation(name: name, address: address, phone: phone)
                                showAdd = false; name = ""; address = ""; phone = ""
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SpecialtiesManageView: View {
    @EnvironmentObject var data: MockDataService
    @State private var showAdd = false
    @State private var name = ""
    var body: some View {
        NavigationStack {
            List(data.specialties) { s in
                Text(s.name)
            }
            .listStyle(.insetGrouped)
            .toolbar { Button { showAdd = true } label: { Label("Add", systemImage: "plus") } }
            .alert("New Specialty", isPresented: $showAdd) {
                TextField("Name", text: $name)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if !name.isEmpty { data.addSpecialty(name: name); name = "" }
                }
            }
        }
    }
}

struct WaitingListView: View {
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.waitingList) { w in
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.patient(by: w.patientId)?.name ?? "Patient").font(.subheadline.weight(.semibold))
                    Text("Prefers \(w.preferredDate) · \(data.doctor(by: w.doctorId)?.name ?? "")")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(w.status).font(.caption2).foregroundStyle(Color.brand)
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct BillingView: View {
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.appointments.filter { $0.status == .completed }) { a in
                HStack {
                    VStack(alignment: .leading) {
                        Text(data.patient(by: a.patientId)?.name ?? "").font(.subheadline.weight(.medium))
                        Text(data.service(by: a.serviceId)?.name ?? "").font(.caption).foregroundStyle(.secondary)
                        Text(a.date).font(.caption2)
                    }
                    Spacer()
                    Text("$\(Int(data.service(by: a.serviceId)?.price ?? 0))")
                        .font(.headline).foregroundStyle(Color.brand)
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct ReportsView: View {
    @EnvironmentObject var data: MockDataService
    private var stats: (total: Int, completed: Int, revenue: Double, avgRating: String, waiting: Int) { data.reportStats() }
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StatTile(title: "Appointments", value: "\(stats.total)", subtitle: "All time", icon: "calendar", color: .brand)
                StatTile(title: "Completed", value: "\(stats.completed)", subtitle: "Visits", icon: "checkmark.circle", color: .green)
                StatTile(title: "Revenue", value: String(format: "$%.0f", stats.revenue), subtitle: "From completed", icon: "dollarsign.circle", color: .purple)
                StatTile(title: "Avg Rating", value: stats.avgRating, subtitle: "Patient feedback", icon: "star.fill", color: .orange)
                StatTile(title: "Waiting", value: "\(stats.waiting)", subtitle: "On list", icon: "hourglass", color: .teal)
            }.padding()
        }.background(Color.screenBG)
    }
}

struct NotificationsView: View {
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            ForEach(data.notifications) { n in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(n.type).font(.caption.weight(.bold)).foregroundStyle(Color.brand)
                        Text(n.message).font(.subheadline)
                        Text(n.time).font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !n.read { Circle().fill(Color.red).frame(width: 8, height: 8) }
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Clinic") {
                LabeledContent("Name", value: "Harlay Clinic")
                LabeledContent("Phone", value: "(555) 234-5678")
            }
            Section("Booking rules") {
                LabeledContent("Max advance", value: "\(ClinicRules.maxAdvanceDays) days")
                LabeledContent("Min notice", value: "\(ClinicRules.minNoticeHours) hours")
                LabeledContent("Slot length", value: "\(ClinicRules.defaultSlotDurationMinutes) min")
            }
            Section {
                Text("Full configuration is also available on the web portal.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Reception queue
struct QueueView: View {
    @EnvironmentObject var data: MockDataService
    var body: some View {
        List {
            Section("Today's queue") {
                let q = data.todayQueue()
                if q.isEmpty {
                    Text("No appointments today").foregroundStyle(.secondary)
                }
                ForEach(q) { a in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(a.time).font(.headline).foregroundStyle(Color.brand)
                            Text(data.patient(by: a.patientId)?.name ?? "")
                            Spacer()
                            Text(a.checkInStatus).font(.caption).padding(6)
                                .background(Color.brandLight).clipShape(Capsule())
                        }
                        Text(data.doctor(by: a.doctorId)?.name ?? "").font(.caption).foregroundStyle(.secondary)
                        HStack {
                            Button("Arrived") { data.setCheckIn(appointmentId: a.id, status: "Arrived") }.buttonStyle(.bordered).controlSize(.small)
                            Button("In Cons.") { data.setCheckIn(appointmentId: a.id, status: "In Consultation") }.buttonStyle(.bordered).controlSize(.small)
                            Button("Done") { data.setCheckIn(appointmentId: a.id, status: "Completed") }.buttonStyle(.borderedProminent).controlSize(.small)
                        }
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }
}
