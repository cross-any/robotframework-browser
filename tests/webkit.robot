*** Settings ***
Library           Browser    auto_closing_level=SUITE
Resource          common.resource
*** Test Cases ***
webkit
    Set Browser Timeout    100
    New Browser  webkit  headless=false
    New Page  https://www.baidu.com/
    Type Text    //input[@name="wd"]    robotframework
    