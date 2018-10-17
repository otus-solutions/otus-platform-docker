db = db.getSiblingDB('admin');

passAdmin = "PASS_ADMIN";
passOtus = "PASS_OTUS";
passDomain = "PASS_DOMAIN";

db.createUser({
  user: "admin",
  pwd: passAdmin,
  roles: [{
    role: "root",
    db: "admin"
  }]
});
db.auth("admin", passAdmin);

db = db.getSiblingDB('otus');
db.createUser({
  user: "otus",
  pwd: passOtus,
  roles: [{
    role: "dbOwner",
    db: "otus"
  }]
});

db = db.getSiblingDB('otus-domain');
db.createUser({
  user: "otus",
  pwd: passDomain,
  roles: [{
    role: "dbOwner",
    db: "otus-domain"
  }]
});
