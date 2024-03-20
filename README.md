# Home lab - Ansible repository

# Useful ansible commands

* Verify the local configuration

```
ansible -i inventory/hosts all -m ping
ansible-inventory -i inventory/hosts --host dn42
ansible-inventory -i inventory/hosts --list
```

* Apply the site.yaml playbook on gateways host

```
ansible-playbook -i ./inventory/hosts site.yaml --diff --limit dedibox --tags shell
```

