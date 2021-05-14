#!/usr/bin/env bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
yum install -y python-pip git wget unzip

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${private_domain}
HMPPS_STACKNAME=${environment_name}
HMPPS_STACK="${environment_name}"
HMPPS_ENVIRONMENT=${environment_name}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
EOF

## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${private_domain}"
export HMPPS_STACKNAME="${environment_name}"
export HMPPS_STACK="${environment_name}"
export HMPPS_ENVIRONMENT=${environment_name}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"

cd ~
pip install -U ansible

cat << EOF > ~/requirements.yml
- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: ${bootstrap_version}
- name: users
  src: singleplatform-eng.users
- name: samba
  src: https://github.com/ministryofjustice/hmpps-ansible-samba-role
  version: ${samba_version}
- name: samba_bootstrap
  src: https://github.com/ministryofjustice/hmpps-jitbit-samba-bootstrap
  version: ${samba_bootstrap_version}
EOF

cat << EOF > ~/bootstrap_vars.yml
---
- remote_user_filename: "${bastion_inventory}"
- log_group: ${log_group}
- samba_ssm_user: ${samba_ssm_user}
- samba_ssm_password: ${samba_ssm_password}
- samba_gid: ${samba_gid}
- samba_uid: ${samba_uid}
- nfs_host: ${efs_dns_name}
- data_dir: ${data_dir}
- awslogs_loglevel: info
- logs:
  - file: /var/log/messages
    group_name: "{{ log_group }}"
    stream_name: messages
    format: "%b %d %H:%M:%S"
  - file: /var/log/audit/audit.log
    group_name: "{{ log_group }}"
    stream_name: audit
    format: "%b %d %H:%M:%S"
  - file: /var/log/secure
    group_name: "{{ log_group }}"
    stream_name: secure
    format: "%b %d %H:%M:%S"
  - file: /var/log/samba/log.smbd
    group_name: "{{ log_group }}"
    stream_name: log_smbd
    format: "%b %d %H:%M:%S"
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml

cat << EOF > ~/bootstrap.yml
---
- hosts: localhost
  gather_facts: true
  vars_files:
     - "{{ playbook_dir }}/bootstrap_vars.yml"
     - "{{ playbook_dir }}/users.yml"
  roles:
     - bootstrap
     - samba
     - samba_bootstrap
     - users
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml
