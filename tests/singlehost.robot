*** Settings ***
Suite Setup         Populate a Duffy node
Suite Teardown      Release the Duffy nodes
Library             ../lib/DuffyLibrary.py

*** Test cases ***
We are able to run /bin/true
    On the Duffy node
    When I run  /bin/true
    It returns  0

We are able to run /bin/false
    On the Duffy node
    When I run  /bin/false
    It returns  1

