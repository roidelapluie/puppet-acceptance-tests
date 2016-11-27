*** Settings ***
Library             ../lib/DuffyLibrary.py
Library             OperatingSystem
Resource            ../lib/basic.robot

*** Test cases ***
Run if PATH is set
    Pass Execution if  'PATH' not in os.environ   PATH is not set

Run if PATH2 is set
    Pass Execution if  'PATH2' not in os.environ  PATH2 is not set
