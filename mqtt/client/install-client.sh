#!/bin/sh

LOCALDIR="/var/etc/persistent/mqtt"
LOCALSCRIPTDIR=$LOCALDIR/client
BASEURL="http://172.16.9.109/neu/mpower-tools/mqtt"

echo "Installing mPower MQTT v2 ..."
wget $BASEURL/libmosquitto.so.1 -O $LOCALDIR/libmosquitto.so.1
wget $BASEURL/mosquitto_pub -O $LOCALDIR/mosquitto_pub
wget $BASEURL/mosquitto_sub -O $LOCALDIR/mosquitto_sub
mkdir -p $LOCALSCRIPTDIR
# clean directory, but leave *.cfg files untouched
find $LOCALSCRIPTDIR ! -name '*.cfg' -type f -exec rm -f '{}' \;
wget $BASEURL/client/mqrun.sh -O $LOCALSCRIPTDIR/mqrun.sh
wget $BASEURL/client/mqpub-static.sh -O $LOCALSCRIPTDIR/mqpub-static.sh
wget $BASEURL/client/mqpub.sh -O $LOCALSCRIPTDIR/mqpub.sh
wget $BASEURL/client/mqsub.sh -O $LOCALSCRIPTDIR/mqsub.sh
wget $BASEURL/client/mqstop.sh -O $LOCALSCRIPTDIR/mqstop.sh

if [ ! -f $LOCALSCRIPTDIR/mpower-pub.cfg ]; then
    wget $BASEURL/client/mpower-pub.cfg -O $LOCALSCRIPTDIR/mpower-pub.cfg
fi

if [ ! -f $LOCALSCRIPTDIR/mqtt.cfg ]; then
    wget $BASEURL/client/mqtt.cfg -O $LOCALSCRIPTDIR/mqtt.cfg
fi

if [ ! -f $LOCALSCRIPTDIR/led.cfg ]; then
    wget $BASEURL/client/led.cfg -O $LOCALSCRIPTDIR/led.cfg
fi

chmod 755 $LOCALDIR/mosquitto_pub
chmod 755 $LOCALDIR/mosquitto_sub
chmod 755 $LOCALSCRIPTDIR/mqrun.sh
chmod 755 $LOCALSCRIPTDIR/mqpub-static.sh
chmod 755 $LOCALSCRIPTDIR/mqpub.sh
chmod 755 $LOCALSCRIPTDIR/mqsub.sh
chmod 755 $LOCALSCRIPTDIR/mqstop.sh

prestart=/etc/persistent/rc.prestart
prestartscript="echo 0 > /proc/led/freq"

if [ ! -f $prestart ]; then
    echo "$prestart not found, creating it ..."
    touch $prestart
    echo "#!/bin/sh" >> $prestart
    chmod 755 $prestart
fi

if grep -q "$prestartscript" "$prestart"; then
   echo "Found $prestart entry. File will not be changed"
else
   echo "Adding start command to $prestart"
   echo -e "$prestartscript" >> $prestart
fi

poststart=/etc/persistent/rc.poststart
startscript="$LOCALSCRIPTDIR/mqrun.sh"
 
if [ ! -f $poststart ]; then
    echo "$poststart not found, creating it ..."
    touch $poststart
    echo "#!/bin/sh" >> $poststart
    chmod 755 $poststart
fi
 
if grep -q "$startscript" "$poststart"; then
   echo "Found $poststart entry. File will not be changed"
else
   echo "Adding start command to $poststart"
   echo -e "$startscript" >> $poststart
fi

if grep -q "/etc/crontabs/ubnt" "$poststart"; then
   echo "Found $poststart entry. File will not be changed"
else
   echo "Adding start command to $poststart"
   echo -e 'echo "0 0 * * * /var/etc/persistent/mqtt/client/mqrun.sh > /dev/null" >> /etc/crontabs/ubnt' >> $poststart
fi

echo "Done!"
echo "Please configure mqtt.cfg"
echo "Please configure mpower-pub.cfg"
echo "Please configure led.cfg"
echo "run 'save' command if done."
