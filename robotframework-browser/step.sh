#!/bin/bash
set -e
set -x

# 系统提供参数，从流水线上下文获取
echo [INFO] PIPELINE_ID=$PIPELINE_ID       # 流水线ID
echo [INFO] PIPELINE_NAME=$PIPELINE_NAME   # 流水线名称
echo [INFO] BUILD_NUMBER=$BUILD_NUMBER     # 流水线运行实例编号
echo [INFO] EMPLOYEE_ID=$EMPLOYEE_ID       # 触发流水线用户ID
echo [INFO] WORK_SPACE=$WORK_SPACE         # /root/workspace容器中目录
echo [INFO] PROJECT_DIR=$PROJECT_DIR       # 代码库根路径，默认为/root/workspace/code
echo [INFO] PLUGIN_DIR=$PLUGIN_DIR         # 插件路径，默认为/root/workspace/plugins
echo [INFO] BUILD_JOB_ID=$BUILD_JOB_ID     # build-service 任务ID
echo [INFO] TESTCOMMAND=$TESTCOMMAND       # 测试命令

# custom variable
OUTPUT_DIR="$PROJECT_DIR/robot_logs"
OUTPUT_XML="$OUTPUT_DIR/output.xml"
echo [INFO] OUTPUT_XML=$OUTPUT_XML

cd $PROJECT_DIR

# sh -ex $WORK_SPACE/user_command.sh
# bash -c "$STEP_COMMAND"
/root/entry_point.sh $TESTCOMMAND || echo [ERROR] 测试失败了

if [ -e $OUTPUT_XML ]; then
# # 上传报告
# # walk through robot_logs to upload
# output=`python3 /root/upload_report.py $OUTPUT_DIR`
# printf $output
# # 获取报告链接
# STEP_REPORT_URL=`echo $output | grep "STAT_URL__REPORT" | awk -F, '{print $2}'`
STEP_REPORT_URL=https://flow.aliyun.com/assets/$SYSTEM_REGION_ID/$PIPELINE_ID/$BUILD_NUMBER/robot_logs/log.html
printf "STEP_REPORT_URL: $STEP_REPORT_URL"

output=`python3 /root/parse_output.py $OUTPUT_XML`

STEP_ROBOT_PASS=`echo $output | awk -F, '{print $1}'`
STEP_ROBOT_FAILED=`echo $output | awk -F, '{print $2}'`
STEP_ROBOT_PASSRATE=`echo $output | awk -F, '{print $3}'`

redline Passed:成功:$STEP_ROBOT_PASS:Success Failed:失败:$STEP_ROBOT_FAILED:Error PassRate:成功率:$STEP_ROBOT_PASSRATE:Default Report:$STEP_REPORT_URL
else
    if [ -e $PROJECT_DIR/playwright-report/output.json ]; then
        STEP_REPORT_URL=https://flow.aliyun.com/assets/$SYSTEM_REGION_ID/$PIPELINE_ID/$BUILD_NUMBER/playwright-report/index.html
        printf "STEP_REPORT_URL: $STEP_REPORT_URL"
        STEP_ROBOT_PASS=`jq '.suites[].specs[].tests[].results[].status | select(. == "passed")' $PROJECT_DIR/playwright-report/output.json|wc -l`
        STEP_ROBOT_SKIPPED=`jq '.suites[].specs[].tests[].results[].status | select(. == "interrupted" or . == "skipped")' $PROJECT_DIR/playwright-report/output.json|wc -l`
        STEP_ROBOT_FAILED=`jq '.suites[].specs[].tests[].results[].status | select(. == "failed")' $PROJECT_DIR/playwright-report/output.json|wc -l`
        STEP_ROBOT_PASSRATE=$[100*STEP_ROBOT_PASS/(STEP_ROBOT_PASS+STEP_ROBOT_SKIPPED+STEP_ROBOT_FAILED)]
        redline Passed:成功:$STEP_ROBOT_PASS:Success Failed:失败:$STEP_ROBOT_FAILED:Error Skipped:忽略:$STEP_ROBOT_SKIPPED:Warning PassRate:成功率:$STEP_ROBOT_PASSRATE:Default Report:$STEP_REPORT_URL
    fi
fi