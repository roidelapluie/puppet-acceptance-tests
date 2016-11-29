*** Settings ***
Test Setup          Populate a Duffy node
Test Teardown       Release the Duffy nodes
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot
Resource            ../rpm/lib.robot

*** Test cases ***
Admin can call the facter cli
    On the Duffy node
    I install the package
    I successfully run  facter

Admin can call facter --version
    On the Duffy node
    I install the package
    I successfully run  facter   --version

