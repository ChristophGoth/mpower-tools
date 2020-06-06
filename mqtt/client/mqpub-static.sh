#!/bin/sh
# homie spec (incomplete)
#$PUBBIN -h $mqtthost $auth -t $topic/\$homie -m "2.1.0" -r
$PUBBIN -h $mqtthost $auth -t $topic/inf/name -m "$devicename" -r
$PUBBIN -h $mqtthost $auth -t $topic/inf/fw/version -m "$version" -r

$PUBBIN -h $mqtthost $auth -t $topic/inf/fw/name -m "mPower MQTT" -r

IPADDR=`ifconfig ath0 | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }'`
MACADDR=`cat /sys/class/net/ath0/address`
$PUBBIN -h $mqtthost $auth -t $topic/inf/net/ip -m "$IPADDR" -r
$PUBBIN -h $mqtthost $auth -t $topic/inf/net/mac -m "$MACADDR" -r

NODES=`seq $PORTS | sed 's/\([0-9]\)/port\1/' |  tr '\n' , | sed 's/.$//'`
$PUBBIN -h $mqtthost $auth -t $topic/inf/nodes -m "$NODES" -r

#UPTIME=`awk '{print $1}' /proc/uptime`
#$PUBBIN -h $mqtthost $auth -t $topic/stat/uptime -m "$UPTIME" -r

properties=relay

if [ $energy -eq 1 ]
then
    properties=$properties,energy
fi

if [ $power -eq 1 ]
then
    properties=$properties,power
fi

if [ $voltage -eq 1 ]
then
    properties=$properties,voltage
fi

if [ $lock -eq 1 ]
then
    properties=$properties,lock
fi

if [ $current -eq 1 ]
then
    properties=$properties,current
fi

if [ $pf -eq 1 ]
then
    properties=$properties,pf
fi

# node infos
for i in $(seq $PORTS)
do
    $PUBBIN -h $mqtthost $auth -t $topic/port$i/inf/name -m "Port $i" -r
    $PUBBIN -h $mqtthost $auth -t $topic/port$i/inf/type -m "power switch" -r
    $PUBBIN -h $mqtthost $auth -t $topic/port$i/inf/properties -m "$properties" -r
    $PUBBIN -h $mqtthost $auth -t $topic/port$i/relay/settable -m "true" -r
    if [ $discovery -eq 1 ]
    then
        config="{\"name\":\"$devicename port$i\",\"cmd_t\":\"$topic/port$i/relay/set\",\"stat_t\":\"$topic/port$i/relay\",\"state_off\":\"0\",\"state_on\":\"1\",\"pl_off\":\"0\",\"pl_on\":\"1\",\"avty_t\":\"$topic/online\",\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port$i\",\"device\":{\"identifiers\":[\"$devicename\"],\"name\":\"$devicename\",\"connections\":[[\"mac\",\"$MACADDR\"]]}}"
        $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/switch/mfi-$devicename/port$i/config -m "$config" -r

        if [ $energy -eq 1 ]
        then
            config="{\"name\":\"$devicename port$i Energy\",\"stat_t\":\"$topic/port$i/energy\",\"avty_t\":\"$topic/online\",\"frc_upd\":true,\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port${i}_energy\",\"device\":{\"identifiers\":[\"$devicename\"],\"name\":\"$devicename\",\"connections\":[[\"mac\",\"$MACADDR\"]]},\"unit_of_meas\":\"kWh\",\"dev_cla\": \"power\"}"
            $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/sensor/mfi-$devicename/port$i-energy/config -m "$config" -r
        fi

        if [ $power -eq 1 ]
        then
            config="{\"name\":\"$devicename port$i Power\",\"stat_t\":\"$topic/port$i/power\",\"avty_t\":\"$topic/online\",\"frc_upd\":true,\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port${i}_power\",\"device\":{\"identifiers\":[\"$devicename\"],\"name\":\"$devicename\",\"connections\":[[\"mac\",\"$MACADDR\"]]},\"unit_of_meas\":\"W\",\"dev_cla\": \"power\"}"
            $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/sensor/mfi-$devicename/port$i-power/config -m "$config" -r
        fi

        if [ $voltage -eq 1 ]
        then
            config="{\"name\":\"$devicename port$i Voltage\",\"stat_t\":\"$topic/port$i/voltage\",\"avty_t\":\"$topic/online\",\"frc_upd\":true,\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port${i}_voltage\",\"device\":{\"identifiers\":[\"$devicename\"],\"name\":\"$devicename\",\"connections\":[[\"mac\",\"$MACADDR\"]]},\"unit_of_meas\":\"V\",\"dev_cla\": \"power\"}"
            $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/sensor/mfi-$devicename/port$i-voltage/config -m "$config" -r
        fi

        #if [ $lock -eq 1 ]
        #then
        #    config="{\"name\":\"$devicename port$i Lock\",\"cmd_t\":\"$topic/port$i/lock/set\",\"stat_t\":\"$topic/port$i/lock\",\"state_off\":\"0\",\"state_on\":\"1\",\"pl_off\":\"0\",\"pl_on\":\"1\",\"avty_t\":\"$topic/online\",\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port${i}_lock\",\"device\":{\"identifiers\":[\"$devicename\"],\"connections\":[[\"mac\",\"$MACADDR\"]]}}"
        #    $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/switch/mfi-$devicename/port$i-lock/config -m "$config" -r
        #fi

        if [ $current -eq 1 ]
        then
            config="{\"name\":\"$devicename port$i Current\",\"stat_t\":\"$topic/port$i/current\",\"avty_t\":\"$topic/online\",\"frc_upd\":true,\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port${i}_current\",\"device\":{\"identifiers\":[\"$devicename\"],\"name\":\"$devicename\",\"connections\":[[\"mac\",\"$MACADDR\"]]},\"unit_of_meas\":\"A\",\"dev_cla\": \"power\"}"
            $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/sensor/mfi-$devicename/port$i-current/config -m "$config" -r
        fi

        if [ $pf -eq 1 ]
        then
            config="{\"name\":\"$devicename port$i PF\",\"stat_t\":\"$topic/port$i/pf\",\"avty_t\":\"$topic/online\",\"frc_upd\":true,\"pl_avail\":\"true\",\"pl_not_avail\":\"false\",\"uniq_id\":\"mfi_${devicename}_port${i}_pf\",\"device\":{\"identifiers\":[\"$devicename\"],\"name\":\"$devicename\",\"connections\":[[\"mac\",\"$MACADDR\"]]},\"unit_of_meas\":\" \"}"
            $PUBBIN -h $mqtthost $auth -r -t ${discovery_prefix}/sensor/mfi-$devicename/port$i-pf/config -m "$config" -r
        fi
    fi
done

if [ $lock -eq 1 ]
then
    for i in $(seq $PORTS)
    do
        $PUBBIN -h $mqtthost $auth -t $topic/port$i/lock/settable -m "true" -r
    done
fi

$PUBBIN -h $mqtthost $auth -t $topic/online -m "true" -r
