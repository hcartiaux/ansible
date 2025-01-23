# Home lab - Ansible repository

# Useful ansible commands

* Verify the local configuration

```
ansible -i inventory/hosts all -m ping
ansible-inventory -i inventory/hosts --host dn42
ansible-inventory -i inventory/hosts --list
```

* Apply the `site.yaml` playbook on the server `srv.flap` in noop mode

```
ansible-playbook -i ./inventory/hosts site.yaml --check --diff --limit srv.flap
```

* Apply the `site.yaml` playbook on the server `srv.flap`

```
ansible-playbook -i ./inventory/hosts site.yaml --diff --limit srv.flap
```

* Apply the `site.yaml` playbook on the server `srv.flap`, restrict to a specific tag

```
ansible-playbook -i ./inventory/hosts site.yaml --diff --limit srv.flap --tags dns
```
