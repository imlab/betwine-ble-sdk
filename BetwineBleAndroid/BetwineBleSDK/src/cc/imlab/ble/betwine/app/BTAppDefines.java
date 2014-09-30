package cc.imlab.ble.betwine.app;

import java.util.UUID;

public class BTAppDefines {
//    private static HashMap<String, String> attributes = new HashMap();
    
    public static Integer CB_BROADCAST_SVC_UUID_APP = 0xaa20;
    public static Integer CB_HP_SERVICE_UUID = 0xaa10;
    public static Integer CB_HP_VALUE_UUID = 0xaa11;
    public static Integer CB_HP_VALUE_LEN = 1;

    public static Integer CB_PM_SERVICE_UUID = 0xaa20;
    public static Integer CB_PM_STATE_UUID = 0xaa21;
    public static Integer CB_PM_VALUE_UUID = 0xaa22;
    public static Integer CB_PM_STATE_LEN = 1;
    public static Integer CB_PM_VALUE_LEN = 3;

    public static Integer CB_MR_SERVICE_UUID = 0xaa30;
    public static Integer CB_MR_VALUE_UUID = 0xaa31;
    public static Integer CB_MR_VALUE_LEN = 1;
    public static Integer CB_MR_TEST_VALUE_UUID = 0xaa32;
    public static Integer CB_MR_TEST_VALUE_LEN = 4;

    public static Integer CB_TS_SERVICE_UUID = 0xaa50;
    public static Integer CB_TS_VALUE_UUID = 0xaa51;
    public static Integer CB_TS_VALUE_LEN = 6;

    public static Integer CB_BS_SERVICE_UUID = 0xaa60;
    public static Integer CB_BS_VALUE_UUID = 0xaa61;
    public static Integer CB_BS_VALUE_LEN = 1;

    public static Integer CB_HS_SERVICE_UUID = 0xaa70;
    public static Integer CB_HS_STEPS_UUID = 0xaa71;
    public static Integer CB_HS_VALUE_LEN = 21;

    public static Integer CB_MAC_SERVICE_UUID = 0x180a;
    public static Integer CB_MAC_VALUE_UUID = 0x2a23;
    public static Integer CB_MAC_VALUE_LEN = 8;
    
    
    public static String uuidStrForAndroid(String uuid) {
    	return "0000" + uuid + "-0000-1000-8000-00805f9b34fb";
    }
    
    public static String uuidStrForAndroid(int uuid16) {
    	return String.format("%08x-0000-1000-8000-00805f9b34fb", uuid16);
    }
    
    public static UUID uuidForAndroid(String uuid) {
    	
    	return UUID.fromString(uuidStrForAndroid(uuid));
    }
    
    public static UUID uuidForAndroid(int uuid16) {
    	return UUID.fromString(uuidStrForAndroid(uuid16));
    }
    
    public static final String ACTION_RECEIVE_STEPS = "cc.imlab.ble.betwine.app.StepsUpdate";
    public static final String ACTION_RECEIVE_ENERGY = "cc.imlab.ble.betwine.app.EnergyUpdate";
    public static final String ACTION_RECEIVE_TIME = "cc.imlab.ble.betwine.app.BadgeTimeUpdate";
    public static final String ACTION_RECEIVE_ACT = "cc.imlab.ble.betwine.app.ActivityUpdate";
    public static final String ACTION_RECEIVE_ALL_STATUS = "cc.imlab.ble.betwine.app.AllStatusUpdate";
    public static final String ACTION_RECEIVE_HISTORY_STEPS = "cc.imlab.ble.betwine.app.StepHistoryUpdate";
    public static final String ACTION_RECEIVE_BATTERY = "cc.imlab.ble.betwine.app.BatteryUpdate";
    public static final String ACTION_RECEIVE_DEVICE_INFO = "cc.imlab.ble.betwine.app.DeviceInfoUpdate";
    public static final String ACTION_RECEIVE_LAST_VIBRATE = "cc.imlab.ble.betwine.app.LastVibrateTime";
    public static final String ACTION_RECEIVE_ACTIVE_MOVE = "cc.imlab.ble.betwine.app.ActiveMove";
    
    public static final byte CB_DEVICE_TEST_RESET = (byte) 0xE0;
    public static final byte CB_DEVICE_TEST_HIBERNATE = (byte) 0xC0;
    public static final byte CB_DEVICE_TEST_SYS_1 = (byte) 0x80;
    public static final byte CB_DEVICE_TEST_SYS_2 = (byte) 0x40;
}
