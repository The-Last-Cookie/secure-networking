# Management script to run while the UPS is active
# run every minute via crontab or service?
# required for shutdown on low battery?
# also check that the batteries stay within a certain temperature limit (80 °C)!


if (aReceiveBuf[8] << 8 | aReceiveBuf[7]) > 4000:
    print('Currently charging via Type C Port.')

elif (aReceiveBuf[10] << 8 | aReceiveBuf[9])> 4000:
    print('Currently charging via Micro USB Port.')

else:
    print('Currently not charging.')

    # Consider shutting down to save data or send notifications
    if (str(batt_voltage)) == ("0.0"):
        print("Bad battery voltage value")
    if (str(batt_voltage)) != ("0.0"):
        if ((batt_voltage * 1000) < (PROTECT_VOLT + 200)):
            print('The battery is going to dead! Ready to shut down!')

            # It will cut off power when initialized shutdown sequence.
            bus.write_byte_data(DEVICE_ADDR, 24, 240)
            os.system("sudo sync && sudo shutdown")
            while True:
                time.sleep(10)

#bus.close()?
