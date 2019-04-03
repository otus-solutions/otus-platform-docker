db = db.getSiblingDB('admin');

db.createUser({
  user: "admin",
  pwd: "PASS_ADMIN",
  roles: [{
    role: "root",
    db: "admin"
  }]
});
db.auth("admin", "PASS_ADMIN");
db.createRole( { role: "executeFunctions", privileges: [ { resource: { anyResource: true }, actions: [ "anyAction" ] } ], roles: [] } );

db = db.getSiblingDB('otus');
db.createUser({
  user: "otus",
  pwd: "PASS_OTUS",
  roles: [{
    role: "dbOwner",
    db: "otus"
  }]
});
db.grantRolesToUser("otus", [ { role: "executeFunctions", db: "admin" } ]);

db = db.getSiblingDB('otus-domain');
db.createUser({
  user: "otus",
  pwd: "PASS_DOMAIN",
  roles: [{
    role: "dbOwner",
    db: "otus-domain"
  }]
});

db = db.getSiblingDB('otus');

db.createCollection("activity");
db.createCollection("activity_configuration");
db.createCollection("activity_inapplicability");
db.createCollection("activity_permission");
db.createCollection("activity_revision");
db.createCollection("aliquot");
db.createCollection("auditor");
db.createCollection("datasource");
db.createCollection("datasource_temp");
db.createCollection("exam_lot");
db.createCollection("exam_result");
db.createCollection("exam_sending_lot");
db.createCollection("field_center");
db.createCollection("fs.files");
db.createCollection("laboratory_configuration");
db.createCollection("participant");
db.createCollection("participant_laboratory");
db.createCollection("participant_quality_control");
db.createCollection("password_reset_control");
db.createCollection("project_configuration");
db.createCollection("report");
db.createCollection("survey");
db.createCollection("survey_group");
db.createCollection("system_config");
db.createCollection("transportation_lot");
db.createCollection("unnecessary");
db.createCollection("user");
db.createCollection("user_permission");
db.createCollection("user_permission_profile");

db.getCollection("activity").createIndex({ "surveyForm.surveyTemplate.identity.acronym": 1 });
db.getCollection("activity").createIndex({ "participantData.recruitmentNumber": 1 });
db.getCollection("activity").createIndex({ "participantData.fieldCenter.acronym": 1 });
db.getCollection("activity").createIndex({ "isDiscarded": 1 });
db.getCollection("activity").createIndex({ "category": 1 });
db.getCollection("activity").createIndex({ "isDiscarded": 1, "participantData.fieldCenter.acronym": 1 });

db.getCollection("aliquot").createIndex({ "code": 1 });
db.getCollection("aliquot").createIndex({ "transportationLotId": 1 });
db.getCollection("aliquot").createIndex({ "examLotId": 1 });

db.getCollection("exam_result").createIndex({ "recruitmentNumber": 1 });
db.getCollection("exam_result").createIndex({ "examSendingLotId": 1 });
db.getCollection("exam_result").createIndex({ "objectType": 1 });
db.getCollection("exam_result").createIndex({ "examName": 1 });
db.getCollection("exam_result").createIndex({ "recruitmentNumber": 1 });
db.getCollection("exam_result").createIndex({ "aliquotCode": 1 });

db.getCollection("participant").createIndex({ "recruitmentNumber": 1 });

db.getCollection("participant_laboratory").createIndex({ "recruitmentNumber": 1 });

db.getCollection("filestore.files").createIndex({ "filename": 1, "uploadDate": 1 });

db.getCollection("fs.files").createIndex({ "filename": 1 });

db.getCollection("user_permission_profile").insert({
    "name" : "DEFAULT",
    "permissions" : [
        {
            "objectType" : "SurveyGroupPermission",
            "groups" : []
        }
    ]
});

db.system.js.save({_id: "syncResults", value: function () {
        var AliquotExamCorrelation = db.laboratory_configuration.findOne({objectType:"AliquotExamCorrelation"});

        var result = db.exam_result.aggregate([
            {
                $match:{
                    aliquotValid:false
                }
            },
            {
                $group:{
                    _id:'$aliquotCode'
                }
            },
            {
                $group:{
                    _id:{},
                    aliquotCodeList:{$push:'$_id'}
                }
            }
        ]).toArray();

        if(result[0]){
            db.aliquot.find({code:{$in:result[0].aliquotCodeList}}).forEach((aliquot) => {
                var aliquotExams = AliquotExamCorrelation.aliquots.filter((oneAliquotExams) => {
                    return oneAliquotExams.name === aliquot.name;
                });
                print(aliquotExams[0].exams);
                db.exam_result.updateMany(
                    {
                        aliquotCode: aliquot.code,
                        examName: { $in:aliquotExams[0].exams}
                    },
                    { $set:
                            {
                                recruitmentNumber: aliquot.recruitmentNumber,
                                sex: aliquot.sex,
                                birthdate: aliquot.birthdate,
                                aliquotValid:true
                            }
                    }
                )
            })
        }
  }
});
