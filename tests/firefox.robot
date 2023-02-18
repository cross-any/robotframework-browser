*** Settings ***
Library           Browser    auto_closing_level=SUITE
Resource          common.resource
*** Test Cases ***
firefox
    Set Browser Timeout    100
    New Browser  firefox  headless=false
    Search Robotframework
