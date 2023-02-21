import os
import sys
from robot.result import ExecutionResult


def parse_output_xml(output_xml):
    result = ExecutionResult(output_xml)
    all_stat = result.statistics.total

    return all_stat.passed, all_stat.failed


if __name__ == '__main__':
    if len(sys.argv) < 2:
        output_xml = 'output.xml'
    else:
        output_xml = sys.argv[1]
    if not os.path.exists(output_xml):
        raise RuntimeError('%s does not exist!' % output_xml)
    pass_cnt, failed_cnt = parse_output_xml(output_xml)
    pass_rate = pass_cnt * 100 / (pass_cnt + failed_cnt)
    print('%d,%d,%d' % (pass_cnt, failed_cnt, pass_rate))
