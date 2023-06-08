#!/bin/bash
set -e
# set -x

# 系统提供参数，从流水线上下文获取
echo [INFO] PIPELINE_ID=$PIPELINE_ID     # 流水线ID
echo [INFO] PIPELINE_NAME=$PIPELINE_NAME # 流水线名称
echo [INFO] BUILD_NUMBER=$BUILD_NUMBER   # 流水线运行实例编号
echo [INFO] EMPLOYEE_ID=$EMPLOYEE_ID     # 触发流水线用户ID
echo [INFO] WORK_SPACE=$WORK_SPACE       # /root/workspace容器中目录
echo [INFO] PROJECT_DIR=$PROJECT_DIR     # 代码库根路径，默认为/root/workspace/code
echo [INFO] PLUGIN_DIR=$PLUGIN_DIR       # 插件路径，默认为/root/workspace/plugins
echo [INFO] BUILD_JOB_ID=$BUILD_JOB_ID   # build-service 任务ID
echo [INFO] TESTCOMMAND=$TESTCOMMAND     # 测试命令

# custom variable
OUTPUT_DIR="$PROJECT_DIR/robot_logs"
OUTPUT_XML="$OUTPUT_DIR/output.xml"
echo [INFO] OUTPUT_XML=$OUTPUT_XML

cd $PROJECT_DIR

# sh -ex $WORK_SPACE/user_command.sh
# bash -c "$STEP_COMMAND"
FAILED=0
if [ $(echo "$TESTCOMMAND" | wc -l) -gt 1 ]; then
    echo "$TESTCOMMAND" >$WORK_SPACE/test_command.sh
    cat $WORK_SPACE/test_command.sh
    /root/entry_point.sh bash -ex $WORK_SPACE/test_command.sh || FAILED=1
else
    /root/entry_point.sh $TESTCOMMAND || FAILED=1
fi
if [ -e $OUTPUT_XML ]; then
    # # 上传报告
    # # walk through robot_logs to upload
    # output=`python3 /root/upload_report.py $OUTPUT_DIR`
    # printf $output
    # # 获取报告链接
    # STEP_REPORT_URL=`echo $output | grep "STAT_URL__REPORT" | awk -F, '{print $2}'`
    STEP_REPORT_URL=https://flow.aliyun.com/assets/$SYSTEM_REGION_ID/$PIPELINE_ID/$BUILD_NUMBER/robot_logs/log.html
    printf "STEP_REPORT_URL: $STEP_REPORT_URL"

    output=$(python3 /root/parse_output.py $OUTPUT_XML)

    STEP_ROBOT_PASS=$(echo $output | awk -F, '{print $1}')
    STEP_ROBOT_FAILED=$(echo $output | awk -F, '{print $2}')
    STEP_ROBOT_PASSRATE=$(echo $output | awk -F, '{print $3}')

    redline Passed:成功:$STEP_ROBOT_PASS:Success Failed:失败:$STEP_ROBOT_FAILED:Error PassRate:成功率:$STEP_ROBOT_PASSRATE:Default Report:$STEP_REPORT_URL
elif [ -e $PROJECT_DIR/playwright-report/output.json ]; then
    STEP_REPORT_URL=https://flow.aliyun.com/assets/$SYSTEM_REGION_ID/$PIPELINE_ID/$BUILD_NUMBER/playwright-report/index.html
    printf "STEP_REPORT_URL: $STEP_REPORT_URL"
    STEP_ROBOT_PASS=$(jq '.suites[].specs[].tests[].results | last .status | select(. == "passed")' $PROJECT_DIR/playwright-report/output.json | wc -l)
    STEP_ROBOT_SKIPPED=$(jq '.suites[].specs[].tests[].results | last .status | select(. == "interrupted" or . == "skipped")' $PROJECT_DIR/playwright-report/output.json | wc -l)
    STEP_ROBOT_FAILED=$(jq '.suites[].specs[].tests[].results | last .status | select(. == "failed" or . == "unexpected")' $PROJECT_DIR/playwright-report/output.json | wc -l)
    STEP_ROBOT_FLAKY=$(jq '.suites[].specs[].tests[].results | last .status | select(. == "flaky")' $PROJECT_DIR/playwright-report/output.json | wc -l)
    STEP_ROBOT_PASSRATE=$((100 * (STEP_ROBOT_PASS + STEP_ROBOT_FLAKY) / (STEP_ROBOT_PASS + STEP_ROBOT_FLAKY + STEP_ROBOT_SKIPPED + STEP_ROBOT_FAILED)))
    STEP_ROBOT_WRANING=$((STEP_ROBOT_FLAKY + STEP_ROBOT_SKIPPED))
    if [ "$STEP_ROBOT_WRANING" -eq 0 ]; then
        redline Passed:成功:$STEP_ROBOT_PASS:Success Failed:失败:$STEP_ROBOT_FAILED:Error PassRate:成功率:$STEP_ROBOT_PASSRATE:Default Report:$STEP_REPORT_URL
    else
        redline Passed:成功:$STEP_ROBOT_PASS:Success Failed:失败:$STEP_ROBOT_FAILED:Error Skipped:忽略:$STEP_ROBOT_SKIPPED:Warning PassRate:成功率:$STEP_ROBOT_PASSRATE:Default Report:$STEP_REPORT_URL
    fi
    if [ -e $PROJECT_DIR/playwright-report/index.html -a -e $PROJECT_DIR/playwright-report/autotest.mp4 ]; then
        sed -i 's/re(St,{className:"subnav-item",href:"#?",children:\["/re(St,{className:"subnav-item",href:"autotest.mp4",download:"autotest.mp4",children:\["录屏（请右键另存为.mp4文件）"\]}),re(St,{className:"subnav-item",href:"#?",children:\["/g' playwright-report/index.html
    fi
else
    STEP_REPORT_URL=https://flow.aliyun.com/assets/$SYSTEM_REGION_ID/$PIPELINE_ID/$BUILD_NUMBER/logs/index.html
    STEP_ROBOT_FAILED=$FAILED
    STEP_ROBOT_PASS=$((1 - STEP_ROBOT_FAILED))
    STEP_ROBOT_PASSRATE=$((100 * STEP_ROBOT_PASS / (STEP_ROBOT_PASS + STEP_ROBOT_FAILED)))
    redline Passed:成功:$STEP_ROBOT_PASS:Success Failed:失败:$STEP_ROBOT_FAILED:Error PassRate:成功率:$STEP_ROBOT_PASSRATE:Default Report:$STEP_REPORT_URL
fi
