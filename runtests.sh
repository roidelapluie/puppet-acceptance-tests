#!/bin/bash

export PATH=$PATH:bats/bin

bats -t "${1?Specify a target}"/*.bats
