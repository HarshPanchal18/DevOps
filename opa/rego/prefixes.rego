package prefix

import future.keywords.if
import future.keywords.in

default allow = false

firstNames:= input.names

prefixes := { "HA", "YA", "SA", "PA" }

validPrefix(name) if {
    some prefix in prefixes
    startswith(name, prefix)
}

allow if {
    every name in firstNames {
        validPrefix(name)
    }
}