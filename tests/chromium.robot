*** Settings ***
Library           Browser    auto_closing_level=SUITE
Resource          common.resource
*** Test Cases ***
chromium
    Set Browser Timeout    100
    New Browser  chromium  headless=false
    Search Robotframework
