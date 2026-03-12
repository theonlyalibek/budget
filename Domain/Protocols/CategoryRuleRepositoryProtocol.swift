import Foundation

/// Repository for persisting user-defined category rules.
@MainActor
protocol CategoryRuleRepositoryProtocol {
    func fetchAll() throws -> [CategoryRule]
    func add(_ rule: CategoryRule) throws
    func delete(_ rule: CategoryRule) throws
}
