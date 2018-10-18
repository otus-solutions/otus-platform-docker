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

db = db.getSiblingDB('otus');
db.createUser({
  user: "otus",
  pwd: "PASS_OTUS",
  roles: [{
    role: "dbOwner",
    db: "otus"
  }]
});

db = db.getSiblingDB('otus-domain');
db.createUser({
  user: "otus",
  pwd: "PASS_DOMAIN",
  roles: [{
    role: "dbOwner",
    db: "otus-domain"
  }]
});
