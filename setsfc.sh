#!/usr/bin/env bash

rootdir="/home/shague/git/ovsdb/openstack/net-virt-sfc/karaf/target/assembly"
#l2switchversion="0.3.0-SNAPSHOT"
ovsdbversion="1.2.1-SNAPSHOT"

# Attempt to keep l2switch from monkeying with the flows
#sed -i 's/<is-proactive-flood-mode>true<\/is-proactive-flood-mode>/<is-proactive-flood-mode>false<\/is-proactive-flood-mode>/' $rootdir/system/org/opendaylight/l2switch/arphandler/arphandler-config/$l2switchversion/arphandler-config-$l2switchversion-config.xml

#sed -i 's/<is-install-lldp-flow>true<\/is-install-lldp-flow>/<is-install-lldp-flow>false<\/is-install-lldp-flow>/' $rootdir/system/org/opendaylight/l2switch/loopremover/loopremover-config/$l2switchversion/loopremover-config-$l2switchversion-config.xml

# enable NetvirtSfc for standalone mode
sed -i -e 's/<of13provider>[a-z]\{1,\}<\/of13provider>/<of13provider>standalone<\/of13provider>/g' $rootdir/system/org/opendaylight/ovsdb/openstack.net-virt-sfc-impl/$ovsdbversion/openstack.net-virt-sfc-impl-$ovsdbversion-config.xml

# Set the logging levels for troubleshooting
logcfg=$rootdir/etc/org.ops4j.pax.logging.cfg
echo "log4j.logger.org.opendaylight.ovsdb.openstack.netvirt.sfc = TRACE" >> $logcfg
#echo "log4j.logger.org.opendaylight.ovsdb.lib = INFO" >> $logcfg
echo "log4j.logger.org.opendaylight.sfc = TRACE" >> $logcfg
echo "org.opendaylight.openflowplugin.applications.statistics.manager.impl.StatListenCommitFlow" ERROR >> $logcfg