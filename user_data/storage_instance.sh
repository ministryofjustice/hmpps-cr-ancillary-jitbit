#!/usr/bin/env bash

# yum install -y python-pip git wget unzip

# cat << EOF >> /etc/environment
# HMPPS_ROLE=samba
# HMPPS_FQDN=samba.cr-jitbit-dev.internal
# HMPPS_STACKNAME=tf-cr-jitbit-dev
# HMPPS_STACK="cr-jitbit-dev"
# HMPPS_ENVIRONMENT=cr-jitbit-dev
# HMPPS_ACCOUNT_ID="563502482979"
# HMPPS_DOMAIN="cr-jitbit-dev.internal"
# EOF
# ## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
# ## just configured, so lets export them
# export HMPPS_ROLE="samba"
# export HMPPS_FQDN="samba.cr-jitbit-dev.internal"
# export HMPPS_STACKNAME="tf-cr-jitbit-dev"
# export HMPPS_STACK="tf-alf-dev"
# export HMPPS_ENVIRONMENT=cr-jitbit-dev
# export HMPPS_ACCOUNT_ID="563502482979"
# export HMPPS_DOMAIN="cr-jitbit-dev.internal"

# cd ~
# pip install -U ansible

# cat << EOF > ~/requirements.yml
# - name: bootstrap
#   src: https://github.com/ministryofjustice/hmpps-bootstrap
#   version: centos
# - name: users
#   src: singleplatform-eng.users
# EOF

# cat << EOF > ~/bootstrap_vars.yml
# ---
# - remote_user_filename: "${bastion_inventory}"
# EOF

# wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/dev.yml -O users.yml

# cat << EOF > ~/bootstrap.yml
# ---
# - hosts: localhost
#   gather_facts: true
#   vars_files:
#      - "{{ playbook_dir }}/bootstrap_vars.yml"
#      - "{{ playbook_dir }}/users.yml"
#   roles:
#      - bootstrap
#      - users
# EOF

# ansible-galaxy install -f -r ~/requirements.yml
# ansible-playbook ~/bootstrap.yml
