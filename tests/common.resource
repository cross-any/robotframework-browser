*** Settings ***
Library           Browser    auto_closing_level=SUITE
Library           BuiltIn

*** Keywords ***
Search Robotframework
    New Page  https://www.baidu.com/
    Type Text    //input[@name="wd"]    robotframework
    Keyboard Key    press    Enter
    Click    //input[@id="su"]
    Wait For Elements State    (//a[em[text()='Robot Framework']])[1]
    Click    (//a[em[text()='Robot Framework']])[1]

Get Log Level
    ${level}=    Set Log Level    INFO
    Set Log Level    ${level}
    [Return]    ${level}

_Do Debugger Pause
    [Arguments]    ${message}    # debug消息
    Import library    Dialogs
    Pause execution    ${message}

Debugger
    [Arguments]    ${message}=测试暂停,可以从调试器里点pause，再关闭本窗口    # debug消息
    [Documentation]    如果使用DEBUG level执行，测试会暂停,可以从调试器里点pause，再关闭弹出窗口
    ${level}=    Get Log Level
    Run Keyword If    '${level}'=='DEBUG'    _Do Debugger Pause    ${message}
