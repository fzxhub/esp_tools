#!/bin/bash

DIR="/sys/class/gpio"
LEDR=12
LEDG=16
LEDB=20
KEY=27


if [ ! -d "$DIR/gpio$LEDR" ]
then echo $LEDR > "$DIR/export"
fi

if [ ! -d "$DIR/gpio$LEDG" ]
then echo $LEDG > "$DIR/export"
fi

if [ ! -d "$DIR/gpio$LEDB" ]
then echo $LEDB > "$DIR/export"
fi

if [ ! -d "$DIR/gpio$KEY" ]
then echo $KEY > "$DIR/export"
fi

sleep 2

sudo echo out > $DIR/gpio$LEDR/direction
sudo echo out > $DIR/gpio$LEDG/direction
sudo echo out > $DIR/gpio$LEDB/direction
sudo echo in > $DIR/gpio$KEY/direction

while true
do
    VALUE=$(sudo cat $DIR/gpio$KEY/value)
    if [ "$VALUE" -eq "0" ]
    then
        sudo echo 0 > $DIR/gpio$LEDR/value
        sudo echo 1 > $DIR/gpio$LEDG/value
        sudo echo 0 > $DIR/gpio$LEDB/value
        sleep 0.1
        sudo echo 0 > $DIR/gpio$LEDR/value
        sudo echo 0 > $DIR/gpio$LEDG/value
        sudo echo 0 > $DIR/gpio$LEDB/value
        sleep 0.1
    else
        sudo echo 0 > $DIR/gpio$LEDR/value
        sudo echo 1 > $DIR/gpio$LEDG/value
        sudo echo 1 > $DIR/gpio$LEDB/value
        esptool.py --chip esp32 -b 460800 --port /dev/ttyUSB0 write_flash -z 0x1000 /home/pi/rice/bootloader_esp32.bin 0x8000 /home/pi/rice/partitions.bin 0xe000 /home/pi/rice/boot_app0.bin 0x10000 /home/pi/rice/firmware.bin
        if [ $? -ne 0 ]
        then
            echo "failed"
            sudo echo 1 > $DIR/gpio$LEDR/value
            sudo echo 0 > $DIR/gpio$LEDG/value
            sudo echo 0 > $DIR/gpio$LEDB/value
        else
            echo "succeed"
            sudo echo 0 > $DIR/gpio$LEDR/value
            sudo echo 1 > $DIR/gpio$LEDG/value
            sudo echo 0 > $DIR/gpio$LEDB/value
        fi
        sleep 4
    fi
done
