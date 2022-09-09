//
//  CloudKitManager.swift
//  AWSL
//
//  Created by FlyKite on 2022/9/9.
//

import Foundation
import CloudKit

protocol CloudKitRecord {
    static var recordTypeName: String { get }
    var recordId: CKRecord.ID { get }
    
    init(cloudKitRecord: CKRecord)
    func updateValues(for record: CKRecord)
}

extension CloudKitRecord {
    func createRecord() -> CKRecord {
        return CKRecord(recordType: type(of: self).recordTypeName, recordID: recordId)
    }
}

protocol CloudKitManagerDelegate: AnyObject {
    func cloudKitManagerSubmitRecordSuccess(record: CloudKitRecord)
}

class CloudKitManager {
    
    weak var delegate: CloudKitManagerDelegate?
    
    private let container: CKContainer = CKContainer.default()
    
    private var taskQueue: [SubmitTask] = []
    private var retryQueue: [SubmitTask] = []
    
    private var fetchTasks: ThreadSafe<[String: FetchTask]> = ThreadSafe<[String: FetchTask]>([:])
    
    private let isSubmitting: ThreadSafe<Bool> = ThreadSafe<Bool>(false)
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.AWSL.CKM", attributes: .concurrent)
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    // MARK: - Submit
    func submit(record: CloudKitRecord) {
        submit(records: [record])
    }
    
    func submit(records: [CloudKitRecord]) {
        queue.async {
            let tasks = records.map { (record) -> SubmitTask in
                return SubmitTask(record: record, savePolicy: .allKeys) { (ckRecord) in
                    record.updateValues(for: ckRecord)
                }
            }
            self.semaphore.wait()
            self.taskQueue.append(contentsOf: tasks)
            self.semaphore.signal()
            self.beginSubmitting()
        }
    }
    
    func beginSubmitting() {
        queue.async {
            if self.isSubmitting.value {
                return
            } else {
                self.isSubmitting.value = true
            }
            if !self.retryQueue.isEmpty {
                self.taskQueue.append(contentsOf: self.retryQueue)
            }
            self.semaphore.signal()
            self.submitFirstRecord()
        }
    }
    
    // MARK: - Fetch
    func fetch<T: CloudKitRecord>(_ recordType: T.Type,
                                  recordId: CKRecord.ID,
                                  progress: ((Progress) -> Void)? = nil,
                                  completion: ((Result<CKRecord?, Error>) -> Void)?) {
        queue.async {
            let fetchTask: FetchTask
            if let task = self.fetchTasks.value[recordId.recordName] {
                fetchTask = task
            } else {
                fetchTask = FetchTask(recordTypeName: recordType.recordTypeName, recordId: recordId)
                self.fetchTasks.value[recordId.recordName] = fetchTask
            }
            fetchTask.execute(database: self.container.database(with: .public), progress: progress, completion: completion)
        }
    }
    
    // MARK: - Delete
    func delete(records: [CloudKitRecord]) {
        queue.async {
            let tasks = records.map { (record) -> SubmitTask in
                return SubmitTask(record: record, savePolicy: .changedKeys) { (ckRecord) in
                    ckRecord["deletedByUser"] = true
                }
            }
            self.semaphore.wait()
            self.taskQueue.append(contentsOf: tasks)
            self.semaphore.signal()
            self.beginSubmitting()
        }
    }
}

// MARK: - Private
extension CloudKitManager {
    private func dequeueTask() -> SubmitTask? {
        semaphore.wait()
        let task: SubmitTask? = {
            if taskQueue.isEmpty {
                return nil
            } else {
                return taskQueue.removeFirst()
            }
        }()
        semaphore.signal()
        return task
    }
    
    private func submitFirstRecord() {
        queue.async {
            guard let task = self.dequeueTask() else {
                self.isSubmitting.value = false
                return
            }
            let database = self.container.database(with: .public)
            task.submit(to: database) { (result) in
                switch result {
                case .success:
                    self.delegate?.cloudKitManagerSubmitRecordSuccess(record: task.record)
                case let .failure(error):
                    print(error)
                    self.retryLater(task)
                }
                self.submitFirstRecord()
            }
        }
    }
    
    private func retryLater(_ task: SubmitTask) {
        queue.async {
            self.semaphore.wait()
            self.retryQueue.append(task)
            self.semaphore.signal()
        }
    }
    
    private func fetchCurrentUserId(completion: ((Result<String, Error>) -> Void)?) {
        container.fetchUserRecordID { (id, error) in
            if let id = id {
                completion?(.success(id.recordName))
            } else if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.failure(NSError(domain: "Unknown Error", code: 109, userInfo: nil)))
            }
        }
    }
}

private class SubmitTask {
    let record: CloudKitRecord
    
    var savePolicy: CKModifyRecordsOperation.RecordSavePolicy
    
    typealias SubmitCompletion = (Result<CKRecord, Error>) -> Void
    
    private let updateAction: (CKRecord) -> Void
    
    init(record: CloudKitRecord, savePolicy: CKModifyRecordsOperation.RecordSavePolicy, updateAction: @escaping (CKRecord) -> Void) {
        self.record = record
        self.savePolicy = savePolicy
        self.updateAction = updateAction
    }
    
    func submit(to database: CKDatabase, completion: SubmitCompletion?) {
        let record = self.record.createRecord()
        updateAction(record)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = savePolicy
        operation.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(record))
            }
        }
        database.add(operation)
    }
}

private class DeleteTask {
    let recordIds: [CKRecord.ID]
    
    init(recordIds: [CKRecord.ID]) {
        self.recordIds = recordIds
    }
    
    func execute(to database: CKDatabase, completion: ((Error?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
        operation.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                completion?(error)
            } else {
                completion?(nil)
            }
        }
        operation.completionBlock = {
            
        }
        database.add(operation)
    }
}

private class FetchTask {
    
    let recordTypeName: String
    let recordId: CKRecord.ID
    
    typealias FetchCompletion = (Result<CKRecord?, Error>) -> Void
    
    private var result: Result<CKRecord?, Error>?
    private var progressCallback: ((Progress) -> Void)?
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.FlyKite.CKM.FT", attributes: .concurrent)
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    init(recordTypeName: String, recordId: CKRecord.ID) {
        self.recordTypeName = recordTypeName
        self.recordId = recordId
    }
    
    func execute(database: CKDatabase, progress: ((Progress) -> Void)?, completion: FetchCompletion?) {
        progressCallback = progress
        queue.async {
            self.semaphore.wait()
            if let result = self.result {
                completion?(result)
                self.semaphore.signal()
                return
            }
            let operation = CKFetchRecordsOperation(recordIDs: [self.recordId])
            operation.perRecordProgressBlock = { (recordId, progress) in
                print("progress=\(progress)")
            }
            operation.fetchRecordsCompletionBlock = { (recordDict, error) in
                let result: Result<CKRecord?, Error>
                if let records = recordDict, let record = records[self.recordId] {
                    result = .success(record)
                } else if let error = error {
                    result = .failure(error)
                } else {
                    result = .failure(NSError(domain: "Unkonwn Error", code: 999, userInfo: nil))
                }
                self.result = result
                completion?(result)
                self.semaphore.signal()
            }
            database.add(operation)
        }
    }
    
}
