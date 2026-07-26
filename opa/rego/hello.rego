package hello

default allow = false
default deny = false

allow if {
    input.text == "hello_world"
}

allow if {
    input.text == "hello world"
}

deny if {
    allow == false
}