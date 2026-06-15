//
//  TaskListViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 6/15/26.
//

import Foundation
import Combine
import KarenShared

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [KTask] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    @Published var newTaskTitle = ""
    @Published var newTaskNotes = ""

    private let taskService = TaskService.shared

    var openTasks: [KTask] {
        tasks
            .filter { !$0.isCompleted }
            .sorted { lhs, rhs in
                switch (lhs.dueAt, rhs.dueAt) {
                case let (left?, right?):
                    return left < right
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
            }
    }

    var completedTasks: [KTask] {
        tasks
            .filter { $0.isCompleted }
            .sorted { lhs, rhs in
                (lhs.completedAt ?? .distantPast) > (rhs.completedAt ?? .distantPast)
            }
    }

    func loadTasks() async {
        isLoading = true
        errorMessage = nil

        do {
            tasks = try await taskService.getTasks()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createTask() async {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let notes = newTaskNotes.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else {
            errorMessage = "Enter a task title"
            return
        }

        let task = KTask(
            title: title,
            notes: notes,
            dueAt: nil,
            isCompleted: false,
            completedAt: nil,
            source: "manual"
        )

        do {
            let createdTask = try await taskService.createTask(task)
            tasks.append(createdTask)
            newTaskTitle = ""
            newTaskNotes = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeTask(_ task: KTask) async {
        guard let id = task.id else {
            return
        }

        let updatedTask = KTask(
            id: id,
            title: task.title,
            notes: task.notes,
            dueAt: task.dueAt,
            isCompleted: true,
            completedAt: Date(),
            source: task.source
        )

        do {
            let savedTask = try await taskService.updateTask(updatedTask)

            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index] = savedTask
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reopenTask(_ task: KTask) async {
        guard let id = task.id else {
            return
        }

        let updatedTask = KTask(
            id: id,
            title: task.title,
            notes: task.notes,
            dueAt: task.dueAt,
            isCompleted: false,
            completedAt: nil,
            source: task.source
        )

        do {
            let savedTask = try await taskService.updateTask(updatedTask)

            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index] = savedTask
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(id: UUID) async {
        do {
            try await taskService.deleteTask(id: id)
            tasks.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
