*** Settings ***
Library           Browser    auto_closing_level=SUITE

*** Keywords ***
Search Robotframework
    New Page  https://www.baidu.com/
    Type Text    //input[@name="wd"]    robotframework
    Keyboard Key    press    Enter
    Click    //input[@id="su"]
    Wait For Elements State    (//a[em[text()='Robot Framework']])[1]
    Click    (//a[em[text()='Robot Framework']])[1]
