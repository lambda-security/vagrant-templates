#!/usr/bin/env python3

import os
import glob
import json
from textwrap import dedent

json_files = sorted(glob.glob(os.path.join(os.curdir, '*.json')))

readme = dedent('''# packer-templates

## NOTE:
- packer opens random ports for preseed files, ensure firewall is disabled

## useful commands
- list virtualbox os types: `VBoxManage list ostypes`
- remove virtualbox old uuids: `vboxmanage list hdds; vboxmanage closemedium disk <uuid> --delete`

## templates
''')

for j in json_files:
    with open(j) as fh:
        data = json.loads(fh.read())

        variables = data.get('variables', {})
        variables = {
            'iso_path': '/'.join(variables.get('iso_path').split('/')[1:]),
            'iso_sha256': variables.get('iso_sha256').split(':')[1],
            'name': variables.get('name'),
            'communicator_username': variables.get('communicator_username'),
            'communicator_password': variables.get('communicator_password'),
            'lowpriv_user': variables.get('lowpriv_user', ''),
            'cpu': variables.get('cpu'),
            'ram': int(variables.get('ram'))/1024,
            'disk_size': int(variables.get('disk_size'))/1024,
        }

        builder_types = [builder.get('type') for builder in data.get("builders", [])]

        has_sysprep = any('sysprep' in builder.get('shutdown_command', '') for builder in data.get("builders", []))
        default_creds_info = '`N/A, VM is sysprepped`' if has_sysprep else f'`{variables["communicator_username"]}`:`{variables["communicator_password"]}`, `{variables["lowpriv_user"]}`:`{variables["lowpriv_user"]}`'

        scripts = [
            provisioner.get('script') for provisioner in data.get('provisioners', [])
                if provisioner.get('type') in ['powershell', 'shell']
        ]

        files = [
            (provisioner.get('source'), provisioner.get('destination')) for provisioner in data.get('provisioners', [])
                if provisioner.get('type') == 'file'
        ]

        output_type = 'box' if any(postprocessor.get('type') == 'vagrant' \
            for postprocessor in data.get('post-processors', [])) else 'ova'

        readme += dedent(f'''
            ## {j.split('/')[1]}

            | Configuration         | Value |
            | --------------------- | ----- |
            | Builder types         | {'`' + '`, `'.join(builder_types) + '`' if len(builder_types) > 1 else '`' + builder_types[0] + '`' if builder_types else 'None'} |
            | ISO                   | `{variables['iso_path']}` |
            | ISO sha256 checksum   | `{variables['iso_sha256']}` |
            | VM Name               | `{variables['name']}` |
            | Output directory      | `{output_type}` |
            | Default resources     | {variables['cpu']} CPUs, {variables['ram']} GB, {variables['disk_size']} GB |
            | Provisioners          | {'`' + '`, `'.join(filter(None, scripts)) + '`' if len(scripts) > 1 else '`' + scripts[0] + '`' if scripts else 'None'} |
            | Files                 | {', '.join([f'`{src}` -> `{dest}`' for src, dest in files]) or 'N/A'} |
            | Default credentials   | {default_creds_info} |
        ''')

with open('README.md', 'w') as fh:
    fh.write(readme)
