import SwiftUI

struct DebugPanelView: View {
    // Must observe the same engine PersistenceService uses, otherwise history is always empty.
    @ObservedObject private var mergeEngine = PersistenceService.shared.mergeRulesEngine
    @State private var selectedTab = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View", selection: $selectedTab) {
                    Text("Merge Rules").tag(0)
                    Text("History").tag(1)
                    Text("Conflicts").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                Group {
                    if selectedTab == 0 {
                    // Merge Rules Explanation
                    VStack(alignment: .leading, spacing: 16) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                RuleCardView(
                                    title: "Rule 1: Prevent Backward Time",
                                    description: "If memory time < disk time, reject memory. This prevents crashes from showing less reading time.",
                                    icon: "arrow.down.to.line"
                                )
                                
                                RuleCardView(
                                    title: "Rule 2: Prevent Double Counting",
                                    description: "If time jumped unreasonably (>80% of expected max), use 80% of difference as conservative merge.",
                                    icon: "exclamationmark.circle"
                                )
                                
                                RuleCardView(
                                    title: "Rule 3: Accept Memory Time",
                                    description: "In normal cases, memory is source of truth as it's continuously updated during session.",
                                    icon: "checkmark.circle"
                                )
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Conflict Detection")
                                        .font(.headline)
                                    
                                    Text("Crashes detected when memory and disk times differ by >30 seconds")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                        }
                    }
                    } else if selectedTab == 1 {
                    // Merge History
                    VStack {
                        if mergeEngine.mergeHistory.isEmpty {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No merge history yet")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGray6))
                        } else {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(mergeEngine.mergeHistory.reversed()) { result in
                                        MergeHistoryItemView(result: result)
                                    }
                                }
                                .padding()
                            }
                            
                            Button(action: mergeEngine.clearHistory) {
                                Text("Clear History")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .padding()
                        }
                    }
                    } else {
                    // Conflicts
                    VStack {
                        if mergeEngine.conflicts.isEmpty {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                Text("No conflicts detected")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGray6))
                        } else {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(mergeEngine.conflicts) { conflict in
                                        ConflictItemView(conflict: conflict)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Debug Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RuleCardView: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct MergeHistoryItemView: View {
    let result: MergeResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.mergeRuleApplied)
                .font(.headline)
                .foregroundColor(.blue)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Before")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatTime(result.previousDiskTime))
                        .font(.caption2)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("After")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatTime(result.newDiskTime))
                        .font(.caption2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Delta")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("+ " + formatTime(result.timeDelta))
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            
            Text(result.timestamp.formatted(date: .abbreviated, time: .standard))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
}

struct ConflictItemView: View {
    let conflict: ReadingTimeConflict
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text(conflict.reason)
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memory")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatTime(conflict.memoryTime))
                        .font(.caption2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Disk")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatTime(conflict.diskTime))
                        .font(.caption2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Diff")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatTime(conflict.timeDifference))
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            
            Text(conflict.detectedAt.formatted(date: .abbreviated, time: .standard))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
}

struct DebugPanelView_Previews: PreviewProvider {
    static var previews: some View {
        DebugPanelView()
    }
}
