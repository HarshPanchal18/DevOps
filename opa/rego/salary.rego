package play

# opa eval --data salary.rego --input salary.json "data.play.allow"

import future.keywords.if
import future.keywords.in

default allow = false

readOnlyUsers := {
    "manager",
    "hr",
}

crudMethods := {
    "read",
    "create",
    "update",
    "delete",
}

crudUser := {
    "hr"
}

allow if {
    input.method in crudMethods
    input.user in crudUser
}

allow if {
    input.method == "read"
    input.user in readOnlyUsers
}
