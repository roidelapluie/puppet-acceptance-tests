*** Settings ***
Suite Setup         Populate Duffy nodes    count=3
Suite Teardown      Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/keywords.robot

*** Test cases ***
We are able to run /bin/true
    On the Duffy nodes
    I successfully run  /bin/true

We are able to run /bin/false
    On the Duffy nodes
    I run  /bin/false
    It returns  1

