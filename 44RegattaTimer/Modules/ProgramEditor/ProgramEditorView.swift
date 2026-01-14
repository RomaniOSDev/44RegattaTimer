//
//  ProgramEditorView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct ProgramEditorView: View {
    @StateObject private var viewModel: ProgramEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingIntervalEditor = false
    @State private var editingInterval: Interval?
    @State private var editingIndex: Int?
    @State private var showingSaveError = false
    
    init(program: Program? = nil) {
        _viewModel = StateObject(wrappedValue: ProgramEditorViewModel(program: program))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Program name editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Program Name")
                            .font(.caption)
                            .foregroundColor(ColorTheme.track)
                            .padding(.horizontal)
                        
                        TextField("Enter program name", text: $viewModel.program.name)
                            .textFieldStyle(.plain)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(ColorTheme.seaDeep.opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    // Program Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // Rest between intervals
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Rest Between Intervals")
                                    .foregroundColor(ColorTheme.track)
                                Spacer()
                                Text("\(Int(viewModel.program.restBetweenIntervals))s")
                                    .foregroundColor(ColorTheme.boat)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal)
                            
                            Slider(value: $viewModel.program.restBetweenIntervals, in: 0...60, step: 5)
                                .tint(ColorTheme.boat)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(ColorTheme.seaDeep.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Tabata Mode
                        Toggle(isOn: $viewModel.program.isTabataMode) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tabata Mode")
                                    .foregroundColor(.white)
                                Text("20s work, 10s rest intervals")
                                    .font(.caption)
                                    .foregroundColor(ColorTheme.track)
                            }
                        }
                        .tint(ColorTheme.boat)
                        .padding()
                        .background(ColorTheme.seaDeep.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Total duration preview
                    HStack {
                        Text("Total Duration:")
                            .foregroundColor(ColorTheme.track)
                        Text(viewModel.program.formattedTotalDuration)
                            .foregroundColor(ColorTheme.boat)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    
                    // Intervals list
                    List {
                        ForEach(Array(viewModel.program.intervals.enumerated()), id: \.element.id) { index, interval in
                            IntervalRowView(interval: interval)
                                .listRowBackground(ColorTheme.seaDeep)
                                .onTapGesture {
                                    editingInterval = interval
                                    editingIndex = index
                                    showingIntervalEditor = true
                                }
                        }
                        .onDelete(perform: viewModel.deleteInterval)
                        .onMove(perform: viewModel.moveInterval)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Program" : "New Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.track)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if viewModel.saveProgram() {
                            dismiss()
                        } else {
                            showingSaveError = true
                        }
                    }
                    .foregroundColor(ColorTheme.boat)
                    .fontWeight(.semibold)
                    .disabled(viewModel.program.intervals.isEmpty)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        if !viewModel.isEditing {
                            Button {
                                viewModel.createTabataProgram()
                            } label: {
                                HStack {
                                    Image(systemName: "bolt.fill")
                                    Text("Tabata")
                                }
                                .foregroundColor(ColorTheme.boat)
                                .fontWeight(.semibold)
                            }
                        }
                        
                        Button {
                            viewModel.addInterval()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Interval")
                            }
                            .foregroundColor(ColorTheme.boat)
                            .fontWeight(.semibold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingIntervalEditor) {
                if let interval = editingInterval, let index = editingIndex {
                    IntervalEditorView(
                        interval: interval,
                        onSave: { updatedInterval in
                            viewModel.program.intervals[index] = updatedInterval
                            showingIntervalEditor = false
                        }
                    )
                }
            }
            .alert("Cannot Save Program", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please add at least one interval with a duration greater than 0 seconds before saving.")
            }
        }
    }
}

struct IntervalRowView: View {
    let interval: Interval
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(interval.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(interval.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(interval.type.backgroundColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    
                    Text(interval.formattedDuration)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.track)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ColorTheme.track)
        }
        .padding(.vertical, 4)
    }
}

struct IntervalEditorView: View {
    @State private var interval: Interval
    @Environment(\.dismiss) private var dismiss
    let onSave: (Interval) -> Void
    
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    init(interval: Interval, onSave: @escaping (Interval) -> Void) {
        _interval = State(initialValue: interval)
        self.onSave = onSave
        
        let totalSeconds = Int(interval.duration)
        _minutes = State(initialValue: totalSeconds / 60)
        _seconds = State(initialValue: totalSeconds % 60)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                Form {
                    Section("Name") {
                        TextField("Interval name", text: $interval.name)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Type") {
                        Picker("Type", selection: $interval.type) {
                            ForEach(IntervalType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Duration") {
                        HStack {
                            Picker("Minutes", selection: $minutes) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text(":")
                                .foregroundColor(.white)
                            
                            Picker("Seconds", selection: $seconds) {
                                ForEach(0..<60) { second in
                                    Text("\(second)").tag(second)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Interval")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.track)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        interval.duration = Double(minutes * 60 + seconds)
                        onSave(interval)
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.boat)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProgramEditorView()
}

