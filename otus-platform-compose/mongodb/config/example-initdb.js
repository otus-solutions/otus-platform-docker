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
db.getCollection("activity").createIndex({ "surveyForm.surveyTemplate.identity.acronym": 1 })
db.getCollection("activity").createIndex({ "participantData.recruitmentNumber": 1 })
db.getCollection("activity").createIndex({ "participantData.fieldCenter.acronym": 1 })
db.getCollection("activity").createIndex({ "isDiscarded": 1 })
db.getCollection("activity").createIndex({ "category": 1 })
db.getCollection("activity").createIndex({ "isDiscarded": 1, "participantData.fieldCenter.acronym": 1 })

db.getCollection("aliquot").createIndex({ "code": 1 })
db.getCollection("aliquot").createIndex({ "transportationLotId": 1 })
db.getCollection("aliquot").createIndex({ "examLotId": 1 })

db.getCollection("exam_result").createIndex({ "recruitmentNumber": 1 });
db.getCollection("exam_result").createIndex({ "examSendingLotId": 1 })
db.getCollection("exam_result").createIndex({ "objectType": 1 })
db.getCollection("exam_result").createIndex({ "examName": 1 })
db.getCollection("exam_result").createIndex({ "recruitmentNumber": 1 })
db.getCollection("exam_result").createIndex({ "aliquotCode": 1 })

db.getCollection("participant").createIndex({ "recruitmentNumber": 1 });

db.getCollection("participant_laboratory").createIndex({ "recruitmentNumber": 1 });

db.getCollection("filestore.files").createIndex({ "filename": 1, "uploadDate": 1 });

db.getCollection("fs.files").createIndex({ "filename": 1 });

db.system.js.save({_id: "syncResults", value: function () {
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
    ]).toArray()

    if(result[0]){
      db.aliquot.find({code:{$in:result[0].aliquotCodeList}}).forEach((aliquot) => {
        db.exam_result.updateMany(
            { aliquotCode: aliquot.code },
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
