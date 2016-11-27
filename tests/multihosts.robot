*** Settings ***
Test Setup          Populate 3 Duffy nodes
Test Teardown       Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot

*** Test cases ***
We are able to run /bin/true
    On the Duffy nodes
    I successfully run  /bin/true

We are able to run /bin/false
    On the Duffy nodes
    I run  /bin/false
    It returns  1

