#SETUP

This is a demonstration/development environment for show-casing OpenDaylight OVSDB NETVIRT with ServiceFunctionChaining (SFC)

git clone https://github.com/flavio-fernandes/netvirtsfc-env.git

The initial instalation may take some time, with vagrant and docker image downloads. 

After the first time it is very quick.

1. Set up Vagrant. 
  * Edit env.sh for NUM_NODES. (Keep all other vars the same for this version)
  * Each VM takes approximately 1G RAM, 2GB used HDD (40GB)
  * demo-netvirt1: 3 VMs.
  * demo-symmetric-chain: 6 VMs. Note this is not fully working yet.
  * demo-asymmetric-chain: 6 VMs.
2. From the directory you cloned into:
```
source ./env.sh
vagrant up
```
  * This takes quite some time initially. 

3. Start controller.
  * Currently it is expected that that controller runs on the host hosting the VMs.
  * Tested using ovsdb netvirt beryllium.

  * Set config for your setup:
    * Modify the NetvirtSfc config.xml to start in standalone mode. set the value of of13provider to standalone
    * Modify the logging levels to help with troubleshooting
    * Use the script, setsfc.sh, to make the two above changes. Modify the rootdir variable to point to whereever the karaf distribution was unzipped.

  * Start controller by running bin/karaf and install following features in karaf:

```
 feature:install odl-ovsdb-sfc-ui
```

  * Run `log:tail | grep openstack.net-virt-sfc.xml` and wait until the following message appears in the log:
```
 Successfully pushed configuration snapshot openstack.net-virt-sfc.xml
```
  * Now you can ^C the log:tail if you wish

4. Continue with the steps for one of the demos below.

Demos:
TODO: should remove this along with any files for it, unless they are useful.
Include the rest of the text in here that goes with the demo-netvirt1
* demo-netvirt1: 
  * 8 docker containers in 2 x EPGs (web, client)
  * contract with ICMP and HTTP
* demo-symmetry:
  * Service Chain classifying HTTP traffic.
  * Traffic in the forward direction is chained and in the reverse direction is chained in reverse order
  * 2 docker containers in the same tenant space
* demo-asymmetry:
  * Service Chain classifying HTTP traffic.
  * Traffic in the forward direction is chained and in the reverse direction the traffic uses the normal VxLAN tunnel
  * 2 docker containers in the same tenant space

##demo-netvirt1

###Setup

VMs:
* netvirtsfc1: netvirt
* netvirtsfc2: netvirt
* netvirtsfc3: netvirt

Containers:
* h35_{x} are in EPG:client
* h36_{x} are in EPG:web

To run, from host folder where Vagrantfile located do:

` ./startdemo.sh demo-netvirt1`

After this, `infrastructure_config.py` will be copied from `/demo-netvirt1`, and you are ready to start testing.
 
###To test:

SSH to test VM (may take some seconds):
```bash
vagrant ssh netvirtsfc1
```

Get root rights:
```bash
sudo -E bash
```

Check docker containers running on your VM:
```bash
docker ps
```

Notice there are containers from two different endpoint groups, "h35" and "h36".
Enter into the shell on one of "h36" (web) container (on `netvirtsfc1` it will be `h36_4`, its IP is `10.0.36.4`, 
you will need it later).
*(You need double ENTER after `docker attach`)*
```bash
docker attach h36_4
```

Start a HTTP server:
```bash
python -m SimpleHTTPServer 80
```

Press `Ctrl-P-Q` to return to your root shell on `netvirtsfc1`

Enter into one of "h35" (client) container, 
ping the container where HTTP server runs, 
and connect to index page:

*We use eternal loop here to imitate web activity. 
After finishing your test, you might want to stop the loop with `Ctrl-C`*
```
docker attach h35_{x}
ping 10.0.36.4
while true; do curl 10.0.36.4; done
```

You may `ping` and `curl` to the web-server from any test VM.

`Ctrl-P-Q` to leave back to root shell on VM.

Now watch the packets flow:
```
ovs-dpctl dump-flows
```

Leave to main shell:
```bash
exit #leave root shell
exit #close ssh session
```
Repeat `vagrant ssh` etc. for each of netvirtsfc2, netvirtsfc3.

###After testing

When finished from host folder where Vagrantfile located do:

`./cleandemo.sh`

If you like `vagrant destroy` will remove all VMs.

##demo-symmetric-chain / demo-asymmetric-chain

VMs:
* netvirtsfc1: netvirt (client initiates transactions from here)
* netvirtsfc2: sff
* netvirtsfc3: "sf"
* netvirtsfc4: sff
* netvirtsfc5: "sf"
* netvirtsfc6: netvirt (run a server here)

Containers:
* h35_2 is on netvirtsfc1. This host serves as the client.
* h35_4 is netvirtsfc6. This host serves as the webserver.

To run, from host folder where Vagrantfile located do:

` ./startdemo.sh demo-symmetric-chain`
-OR-
` ./startdemo.sh demo-asymmetric-chain`

### To test by sending traffic:
Start a test HTTP server on h35_4 in VM 6.

*(don't) forget double ENTER after `docker attach`*
```bash
vagrant ssh netvirtsfc6
sudo -E docker ps
sudo -E docker attach h35_4
python -m SimpleHTTPServer 80
```

Ctrl-P-Q to detach from docker without stopping the SimpleHTTPServer, and logoff netvirtsfc6.

Now start client traffic, either ping or make HTTP requests to the server on h36_4.

```bash
vagrant ssh netvirtsfc1
sudo -E docker ps
sudo -E docker attach h35_2
ping 10.0.35.4
curl 10.0.35.4
while true; do curl 10.0.35.4; sleep 1; done
```

Ctrl-P-Q to detach from docker, leaving the client making HTTP requests, and logoff netvirtsfc1.


Look around: use "vagrant ssh" to the various machines 
 * take packet captures on eth1.
 * sudo ovs-dpctl dump-flows`

### When finished from host folder where Vagrantfile located do:

`./cleandemo.sh`

If you like `vagrant destroy` will remove all VMs

##Preparing to run another demo
1. In the vagrant directory, run cleandemo.sh
2. stop controller (logout of karaf)
3. Remove data, journal and snapshot directories from controller directory.
4. Restart tests starting with restarting the controller, install features, wait, as above.
