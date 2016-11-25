#!/usr/bin/env bats

@test "call facter" {
    facter
}

@test "call facter --version" {
    facter --version
}
