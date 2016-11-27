*** Settings ***
Test Setup          Populate a Duffy node
Test Teardown       Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot

*** Test cases ***
We are able to run /bin/true
    On the Duffy node
    I successfully run  /bin/true

We are able to run /bin/false
    On the Duffy node
    I run               /bin/false
    It returns          1

We are able to install a package
    On the Duffy node
    I install           man

