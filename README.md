# Cloud Computing and Virtualization - W2 - Ansible

This repository contains a set of examples used in class to illustrate what is Ansible and how to use it.

Still having issues with W10+Vagrant:
* Search "Windows Features" / "Funcionalidades do Windows" and deactivate Hyper-V.
https://stackoverflow.com/a/68788355/5145402
* Open VirtualBox when running vagrant and select the running vms when provisioning

## Scenario

We will use a set of VMs to simulate real machines, these are provisioned with Vagrant (see `Vagrantfile`) and can be launched with `vagrant up`, or individually, with `vagrant up <vm-name>`. The machines are:

* Ansible node - `ansible [192.168.33.10]`
  * The control node, used to run Ansible and provision other nodes in our network
  * Ansible is installed on `up` or with `vagrant provision ansible` - check `./provision/install_ansible.sh`
  * On provision an ssh key is also generated to `~/.ssh/id_rsa` using `ssh-keygen` (see `Vagrantfile` for details)
  * *Why CentOS 7?* Just to make it different than Ubuntu, make students used to different distros and package managers (in this case `yum`, instead of `apt` or `snap`).
* Server nodes (aka nodes to be provivioned)
  * `node1 [192.168.33.15]` - CentOS 7 - A random server where things will be installed.
  * `node2 [192.168.33.20]` - Ubuntu 16.04 - Similar to the last one, this time with Ubuntu 16.04
  * `node3 [192.168.33.30]` - Ubuntu 18.04 - Similar to the last one, this time with Ubuntu 18.04
  * `node4 [192.168.33.40]` - Ubuntu 20.04 - Similar to the last one, this time with Ubuntu 20.04
  * These nodes have no shared/sync vagrant folders (to illustrate that files are not available there)

Ansible is installed on the first node on the first start or by running vagrant ansible provision, check the install script:

## What is Ansible?
Ansible is a popular configuration management and automation tool. It can be used to provision different OSes and hardware devices from a central node. Thus, the tool is agentless - no agent needs to be installed on targets, and the configuration instructions are written in YAML (markup language), typically versioned as code.

Ansible uses a set of different mechanisms to connect to targets, namely:
* SSH to Linux-based systems, then issuing Linux-based commands or modules
* WinRM protocol to interact with Windows-based systems, then using Windows-specific modules such as win_command and so on. There are also other modules such as `choco`.
* For specific hardware, Ansible uses modules specifically designed for these (e.g., ESXi hosts, CISCO, Extreme networks, cloud providers and so on). These modules typically interact with APIs or CLIs of those devices.

### Ansible Basic Blocks
The basic building blocs that form Ansible are:
* Inventory - defines the target hosts
  * Can be a static file or dynamic source (db, or data from a service). Provides hosts info such as IPs, hostnames, access credentials, ports or similar data.
* Modules - used to perform tasks on the hosts
  * Pieces of code taht perform specific tasks, provide ways to interact with remote systems. There are built-in modules for basic tasks, e.g., installing packages, actions with files, services or users, and also 3rd party modules.
  * Modules are designed to be **idempotent**, can be executed multiple times without changing the outcome after the first run - they achieve a **desired state** (defined in a *playbook*)
* Tasks - individual actions defined in a playbook
  * Each task in a playbook specifies a module to use, along with required parameters and hosts
* Variables - store and manage values in *playbooks*
  * Allow for dynamic configurations at any level (inventory, task, playbook) so behavior can change based on different conditions (e.g., the Linux distro of the target host)
* Playbooks - define the desired state of the target systems and the actions to achieve that
  * Used to automate tasks and configurations, can include tasks, variables, templates and roles
* Templates - generate dynamic files
  * Use predefined templates and variables to generate files to be placed on target hosts, e.g., ocnfiguration files, scripts, etc.
* Roles - provides structure to organize playbooks and tasks
  * Allow to make the previous blocks more reusable and maintainable, organized in folders with predefined structures (e.g., tasks, templates, variables, files and so on)

 uses different mechanisms and modules to provision different operating systems (OSes) and hardware devices.

## Using Ansible

In our demos, we will use only Linux-based boxes, so the first step is to make sure your targets all have the SSH key of our control node (no pwd login).

In this project, ansible data is located under `ansible` folder, thus enter the control node and go to that folder:
```bash
vagrant ssh ansible
cd /vagrant/ansible
```
All the next examples are run from that vm/folder.

### Example 0 - keyscan
The first example is a simple playbook that will add the fingerprints of our target hosts to the `~/.ssh/known_hosts` of our control node. Just run:
```bash
ansible-playbook -i hosts example_0/ssh_key_scan.yml -v
```

Check the result with `cat ~/.ssh/known_hosts`.

Note: in production you probably should be more careful. Also, running this twice will duplicate entries. How could it be fixed?

### Example 1 - copy ssh key
Next, we need to copy our public key to each of the nodes so we can login without a pwd. Check `add_ssh_key.yml` and try to run it with:

```bash
ansible-playbook -i hosts example_1/add_ssh_key.yml
```
This will fail, why?

We haven't added the keys, so we must use password by adding `--ask-pass`. The default password for our vagrant boxes is always `vagrant`.
```bash
ansible-playbook -i hosts example_1/add_ssh_key.yml --ask-pass
```

In a real life scenario you would probably want to use a different mechanism, or at least run it on specific new hosts when created, e.g., `ansible-playbook -i hosts example_1/add_ssh_key.yml --limit node3 --ask-pass`

#### Idempotent Actions

Run it multiple times, what happens? Also test editing the playbook and change state to `absent`.

### Example 2 - ad-hoc modules
Ansible can also be used to run modules ad-hoc, as needed without a playbook. Some examples follow:
```bash
ansible all -m ping -i hosts # PING is not what you think, but the ansible ping module, that just connects to host, checks for python and returns - see https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html

ansible web_servers -i hosts -m command -a "ls -l /var/log"

ansible node4 -i hosts -m apt -a "upgrade=yes update_cache=yes cache_valid_time=86400" --become

```

### Example 3 - install apache
Installing apache in one of the hosts with `pkg` module and starting the server with `notify`. Run with:
```bash
ansible-playbook example_3/install_apache.yml -i hosts
``` 
Check http://192.168.33.15

You can again re-run it or alter the playbook to learn more.

### Example 4 - vars
What if we want to install apache into several machines? Try running the previous playbook against `test_servers` group. What happens?

We can use `variables` to make configurations and tasks more dynamic. Under the `vars` directory you will see two files named <DistroName-MajorVersion>.yml, for instance CentOS-7.yml. Inside, a variable named `apache_package` is defined (`apache2` for Ubuntu, and `httpd` for CentOS).

Based on this, the playbook `example_4/install_apache_v2.yml` will gather the right name for the system and install it correctly be using `include_vars: "../vars/{{ ansible_distribution }}-{{ ansible_distribution_major_version }}.yml"`

Try it by running:
```bash
ansible-playbook example_4/install_apache_v2.yml -i hosts
```
Then check http://192.168.33.15 and http://192.168.33.20

### Example 5 - templates
To improve the last example, we can use Jinja2 templates to setup a custom default homepage. This uses the Ansible `template` module (check templates/index.html.j2) and the templates documentation.

Run it with:
```bash
ansible-playbook example_5/install_apache_v3.yml -i hosts
```

Note that it uses computed values but also variables from the `vars` folder. This can be used to generate custom configs for services based on playlists.

### Example 6 - register (WIP)
To be continued...

## Ansible Roles
Roles are normally used to better organize configurations and make them reusable. As explained during the class, you can generate the folders for a role with `ansible-galaxy init <role_name>`. In addition, several roles from the community are available via ansible-galaxy.

### Create an Apache and MySQL roles
Create two distinct roles, apache and mysql and combine both in a single playbook.

Some hints:
- Create a roles folder and apache and mysql subfolders, delete the uneeded folders to simplify. You will probably want something similar to:
```bash
roles/
  apache/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
      apache.conf.j2
  mysql/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
      my.cnf.j2
```

Then, in each role define your tasks, handlers and templates, for instance regarding apache:
```yaml
# roles/apache/tasks/main.yml

- name: Install Apache
  #...

- name: Start Apache
  #...

- name: Copy Apache configuration files or default page
  #...
  notify:
    - Restart Apache
```

Do the same for MySQL. If you want a challenge, create a third role for PHP and add a script to do something with the DB (e.g. increment a number in a column per visit).

Finally, create a playbook to use the created roles:
```yml
- name: Install Apache and MySQL
  hosts: node4
  roles:
    - apache
    - mysql
```
