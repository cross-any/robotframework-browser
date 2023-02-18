import os
import sys
import requests
from datetime import datetime


def _env(env_key):
    return os.getenv(env_key, '')

_BASE_URL = _env("PACKAGES_BASE_URL")
_REMOTE_DIR = f'{_env("REGION_ID")}/{datetime.now().strftime("%Y%m%d")}/{_env("PIPELINE_ID")}/{_env("BUILD_NUMBER")}'
_AUTH_HEADER = {'Authorization': _env('PACKAGES_AUTHORIZATION')}
_REPORT_FILE = 'log.html'


def upload_out_dir(out_dir):
    print(f'BASE URL: {_BASE_URL}')
    print(f'SOURCE DIRECTORY: {out_dir}')
    print(f'REMOTE DIRECTORY: {_REMOTE_DIR}')
    session = requests.session()
    for dirpath, _, files in os.walk(os.path.relpath(out_dir)):
        for file_ in files:
            # upload
            filepath = os.path.join(dirpath, file_)
            resp = session.post(f'{_BASE_URL}/{_REMOTE_DIR}/{dirpath}?version=1&=', headers=_AUTH_HEADER, files={'file': open(filepath, 'rb')})
            if not resp.ok:
                print(f'failed to upload {filepath}, response: {resp.content}')
            try:
                remote_path = resp.json().get("object", {}).get("url")
                print(f'upload {filepath} to {remote_path}')
                if file_ == _REPORT_FILE:
                    print(f'STAT_URL__REPORT,{_REMOTE_DIR}/{filepath}')
            except Exception as err:
                print(f'unexpected response: {resp.content}, error: {err}')
                raise RuntimeError(err)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        out_dir = 'robot_logs'
    else:
        out_dir = sys.argv[1]
    if not os.path.exists(out_dir) or not os.path.isdir(out_dir):
        raise RuntimeError('directory %s does not exist!' % out_dir)
    upload_out_dir(out_dir)
