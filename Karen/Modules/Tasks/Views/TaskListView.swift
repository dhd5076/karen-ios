//
//  TaskListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/15/26.
//

import SwiftUI
import KarenShared

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showingCreateTask = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading Tasks...")
            } else if viewModel.tasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: KTask.icon,
                    description: Text("Create a task to get started")
                )
            } else {
                List {
                    if !viewModel.openTasks.isEmpty {
                        Section("Open") {
                            ForEach(viewModel.openTasks, id: \.id) { task in
                                taskRow(task)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            Task {
                                                await viewModel.completeTask(task)
                                            }
                                        } label: {
                                            Label("Complete", systemImage: "checkmark.circle")
                                        }
                                        .tint(.green)

                                        deleteButton(for: task)
                                    }
                            }
                        }
                    }

                    if !viewModel.completedTasks.isEmpty {
                        Section("Completed") {
                            ForEach(viewModel.completedTasks, id: \.id) { task in
                                taskRow(task)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            Task {
                                                await viewModel.reopenTask(task)
                                            }
                                        } label: {
                                            Label("Reopen", systemImage: "arrow.uturn.backward.circle")
                                        }

                                        deleteButton(for: task)
                                    }
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadTasks()
                }
            }
        }
        .navigationTitle("Tasks")
        .task {
            await viewModel.loadTasks()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateTask = true
                } label: {
                    Label("Create Task", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateTask) {
            createTaskSheet
        }
    }

    private func taskRow(_ task: KTask) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)

                Text(task.title)
                    .font(.headline)
            }

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let dueAt = task.dueAt {
                Text("Due \(dueAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func deleteButton(for task: KTask) -> some View {
        Button(role: .destructive) {
            Task {
                if let id = task.id {
                    await viewModel.deleteTask(id: id)
                }
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private var createTaskSheet: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $viewModel.newTaskTitle)

                    TextField("Notes", text: $viewModel.newTaskNotes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Create Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingCreateTask = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.createTask()
                            if viewModel.errorMessage == nil {
                                showingCreateTask = false
                            }
                        }
                    }
                    .disabled(viewModel.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskListView()
    }
}
