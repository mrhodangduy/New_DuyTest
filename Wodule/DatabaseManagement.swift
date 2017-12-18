//
//  DatabaseManagement.swift
//  Wodule
//
//  Created by QTS Coder on 12/15/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import SQLite


struct ExamDataStruct {
    
    let identifier: Int64
    let examinerId: Int64
    let examName: String
    var status: String
    let examQuestionaireOne: String?
    let examQuestionaireTwo: String?
    let examQuestionaireThree: String?
    let examQuestionaireFour: String?
    var comment_1: String?
    var comment_2: String?
    var comment_3: String?
    var comment_4: String?
    var score_1: String?
    var score_2: String?
    var score_3: String?
    var score_4: String?
    let audio_1: String?
    let audio_2: String?
    let audio_3: String?
    let audio_4: String?
    var lastChange: String
    var isDownloaded: Bool
    
    var description: String {
        return "id = \(self.examinerId), identifier = \(self.identifier), name = \(self.examName), status = \(self.status), isDownloaded = \(self.isDownloaded)"
    }
}


class DatabaseManagement {
    
    static let shared: DatabaseManagement = DatabaseManagement()
    private let db:Connection?
    
    
    private let tblExam = Table("ExamsSaved")
    private let id = Expression<Int64>("id")
    private let identifierF = Expression<Int64>("identifier")
    private let examinerIdF = Expression<Int64>("examinerId")
    private let examNameF = Expression<String>("exam")
    private let statusF = Expression<String>("status")
    private let examQuestionaireOneF = Expression<String?>("examQuestionaireOne")
    private let examQuestionaireTwoF = Expression<String?>("examQuestionaireTwo")
    private let examQuestionaireThreeF = Expression<String?>("examQuestionaireThree")
    private let examQuestionaireFourF = Expression<String?>("examQuestionaireFour")
    private let comment_1F = Expression<String?>("comment_1  ")
    private let comment_2F = Expression<String?>("comment_2")
    private let comment_3F = Expression<String?>("comment_3")
    private let comment_4F = Expression<String?>("comment_4")
    private let score_1F = Expression<String?>("score_1")
    private let score_2F = Expression<String?>("score_2")
    private let score_3F = Expression<String?>("score_3")
    private let score_4F = Expression<String?>("score_4")
    private let audio_1F = Expression<String?>("audio_1")
    private let audio_2F = Expression<String?>("audio_2")
    private let audio_3F = Expression<String?>("audio_3")
    private let audio_4F = Expression<String?>("audio_4")
    private let lastChangeF = Expression<String>("lastChange")
    private let isDownloadedF = Expression<Bool>("isDownloaded")
    
    private init()
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            db = try Connection("\(path)/wodule.sqlite3")
            createTableExamSaved()
        } catch {
            db = nil
            print("Unable open database")
        }
    }
    
    func createTableExamSaved()
    {
        do {
            try db!.run(tblExam.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(identifierF)
                table.column(examinerIdF)
                table.column(examNameF)
                table.column(statusF)
                table.column(examQuestionaireOneF)
                table.column(examQuestionaireTwoF)
                table.column(examQuestionaireThreeF)
                table.column(examQuestionaireFourF)
                table.column(comment_1F)
                table.column(comment_2F)
                table.column(comment_3F)
                table.column(comment_4F)
                table.column(score_1F)
                table.column(score_2F)
                table.column(score_3F)
                table.column(score_4F)
                table.column(audio_1F)
                table.column(audio_2F)
                table.column(audio_3F)
                table.column(audio_4F)
                table.column(lastChangeF)
                table.column(isDownloadedF)
                
            })
            print("create table successfully")
        } catch {
            print("Unable to create table")
        }
    }
    
    func addExam(identifier: Int64,
                 examinerId: Int64,
                 examName: String,
                 status: String,
                 examQuestionaireOne: String?,
                 examQuestionaireTwo: String?,
                 examQuestionaireThree: String?,
                 examQuestionaireFour: String?,
                 comment_1: String?,
                 comment_2: String?,
                 comment_3: String?,
                 comment_4: String?,
                 score_1: String?,
                 score_2: String?,
                 score_3: String?,
                 score_4: String?,
                 audio_1: String?,
                 audio_2: String?,
                 audio_3: String?,
                 audio_4: String?,
                 lastChange: String,
                 isDownload: Bool) -> Int64? {
        do {
            
            let insert = tblExam.insert(identifierF <- identifier,
                                        examinerIdF <- examinerId,
                                        examNameF <- examName,
                                        statusF <- status,
                                        examQuestionaireOneF <- examQuestionaireOne,
                                        examQuestionaireTwoF <- examQuestionaireTwo,
                                        examQuestionaireThreeF <- examQuestionaireThree,
                                        comment_1F <- comment_1,
                                        comment_2F <- comment_2,
                                        comment_3F <- comment_3,
                                        comment_4F <- comment_4,
                                        score_1F <- score_1,
                                        score_2F <- score_2,
                                        score_3F <- score_3,
                                        score_4F <- score_4,
                                        audio_1F <- audio_1,
                                        audio_2F <- audio_2,
                                        audio_3F <- audio_3,
                                        audio_4F <- audio_4,
                                        lastChangeF <- lastChange,
                                        isDownloadedF <- isDownload)
            
            let rowid = try db!.run(insert)
            print("Insert to tblProduct successfully")
            return rowid

        } catch {
            print("Cannot insert to database")
            return nil
        }
    }
    
    func queryAllExam() -> [ExamDataStruct] {
        var exams = [ExamDataStruct]()
        
        do {
            for exam in try db!.prepare(self.tblExam) {
                let newExam = ExamDataStruct(identifier: exam[identifierF], examinerId: exam[examinerIdF],
                                             examName: exam[examNameF], status: exam[statusF],
                                             examQuestionaireOne: exam[examQuestionaireOneF],
                                             examQuestionaireTwo: exam[examQuestionaireTwoF],
                                             examQuestionaireThree: exam[examQuestionaireThreeF],
                                             examQuestionaireFour: exam[examQuestionaireFourF], comment_1: exam[comment_1F],
                                             comment_2: exam[comment_2F], comment_3: exam[comment_3F],
                                             comment_4: exam[comment_4F], score_1: exam[score_1F],
                                             score_2: exam[score_2F],score_3: exam[score_3F], score_4: exam[score_4F],
                                             audio_1: exam[audio_1F], audio_2: exam[audio_2F], audio_3: exam[audio_3F],
                                             audio_4: exam[audio_4F], lastChange: exam[lastChangeF],
                                             isDownloaded: exam[isDownloadedF])
                
                exams.append(newExam)

            }
        } catch {
            print("Cannot get list of exam")
        }
        for exam in exams {
            print("###########")
            print("each exam = \(exam)")
        }
        return exams
    }
    
    func queryAllExam(withID examinerid : Int64, status: String) -> [ExamDataStruct] {
        var exams = [ExamDataStruct]()
        
        let query = tblExam.where(examinerIdF == examinerid && statusF == status)
        do {
            let items = try db!.prepare(query)
            for exam in items {
                let newExam = ExamDataStruct(identifier: exam[identifierF], examinerId: exam[examinerIdF],
                                             examName: exam[examNameF], status: exam[statusF],
                                             examQuestionaireOne: exam[examQuestionaireOneF],
                                             examQuestionaireTwo: exam[examQuestionaireTwoF],
                                             examQuestionaireThree: exam[examQuestionaireThreeF],
                                             examQuestionaireFour: exam[examQuestionaireFourF], comment_1: exam[comment_1F],
                                             comment_2: exam[comment_2F], comment_3: exam[comment_3F],
                                             comment_4: exam[comment_4F], score_1: exam[score_1F],
                                             score_2: exam[score_2F],score_3: exam[score_3F], score_4: exam[score_4F],
                                             audio_1: exam[audio_1F], audio_2: exam[audio_2F], audio_3: exam[audio_3F],
                                             audio_4: exam[audio_4F], lastChange: exam[lastChangeF], isDownloaded: exam[isDownloadedF])
                
                exams.append(newExam)
                
            }
        } catch {
            print("Cannot get list of exam")
        }
        for exam in exams {
            print("###########")
            print("each exam = \(exam.description)")
        }
        return exams
    }
    
    func queryIdentifierListAll() -> [Int64]
    {
        var idList = [Int64]()
        
        do {
            for id in try db!.prepare(tblExam)
            {
                idList.append(id[identifierF])
            }
            
        } catch {
        }
        return idList
    }

    
    func queryIdentifierList(of examinerId: Int64) -> [Int64]
    {
        var idList = [Int64]()
        
        let query = tblExam.where(examinerIdF == examinerId)
        do {
            for id in try db!.prepare(query)
            {
                idList.append(id[identifierF])
            }

        } catch {        
        }
        return idList
    }
    
    func queryIdentifiersNotDownloadAudio(of examinerId: Int64) -> [Int64]
    {
        var idList = [Int64]()
        
        let query = tblExam.where(examinerIdF == examinerId && isDownloadedF == false)
        do {
            
            for id in try db!.prepare(query)
            {
                idList.append(id[identifierF])
                print("@@@@@@@@@@@@")
                print(id[identifierF], id[examinerIdF], id[isDownloadedF])
            }
            
        } catch {
        }
        return idList
    }
    
    func deleteExam(id: Int64) -> Bool
    {
        do {
            let tblFilterExam = tblExam.filter(identifierF == id)
            try db!.run(tblFilterExam.delete())
            print("delete sucessfully")
            return true
        } catch {
            
            print("Delete failed")
        }
        return false
    }
    
    func updateExamDownload(id: Int64, isDownloaded: Bool) -> Bool
    {
        let tblFilterExam = tblExam.where(identifierF == id)
        do {
            let update = tblFilterExam.update(isDownloadedF <- isDownloaded)
            if try db!.run(update) > 0 {
                print("Update exam successfully")
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
        
    }
    
    
    func updateGradeExam(examinerid: Int64, identifier: Int64, grade1: String, comment1: String, grade2: String, comment2: String, grade3: String?, comment3: String?, grade4: String?, comment4: String?, status: String) -> Bool
    {
        let tblFilterGrade = tblExam.where(examinerIdF == examinerid && identifierF == identifier)
        do
        {
            let update = tblFilterGrade.update([score_1F <- grade1, comment_1F <- comment1,
                                                score_2F <- grade2, comment_2F <- comment2,
                                                score_3F <- grade3, comment_3F <- comment3,
                                                score_4F <- grade4, comment_4F <- comment4,
                                                statusF <- status])
            if try db!.run(update) > 0 {
                print("Update exam successfully")
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
        
    }    
    
}


















