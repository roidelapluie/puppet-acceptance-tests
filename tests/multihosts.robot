*** Settings ***
Suite Setup         Populate Duffy nodes    count=3
Suite Teardown      Release the Duffy nodes
Library             ../lib/DuffyLibrary.py

*** Test cases ***
We are able to run /bin/true
    On the Duffy nodes
    When I run  /bin/true
    It returns  0

We are able to run /bin/false
    On the Duffy nodes
    When I run  /bin/false
    It returns  1

