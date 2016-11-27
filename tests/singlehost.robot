*** Settings ***
Suite Setup         Populate a Duffy node
Suite Teardown      Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/keywords.robot

*** Test cases ***
We are able to run /bin/true
    On the Duffy node
    I successfully run  /bin/true

We are able to run /bin/false
    On the Duffy node
    I run  /bin/false
    It returns  1

