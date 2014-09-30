package cc.imlab.ble.bleapi;

public class BetwineCMDefines {

	public static enum DeviceType {
		None,
		BetwineApp,
	};
	
    public final static long SCAN_PERIOD = 6000; // 6 seconds

    /* Peripheral Connector State */
    public static final int STATE_DISCONNECTED = 0;
    public static final int STATE_CONNECTING = 1;
    public static final int STATE_CONNECTED = 2;
    
    
    /* Betwine CM Intent Filters */
    public final static String ACTION_CM_START_SCAN =
            "cc.imlab.ble.bleapi.ACTION_CM_START_SCAN";
    public final static String ACTION_CM_STOP_SCAN = 
    		"cc.imlab.ble.bleapi.ACTION_CM_STOP_SCAN";
    public final static String ACTION_CM_CONNECTING = 
    		"cc.imlab.ble.bleapi.ACTION_CM_CONNECTING";
    public final static String ACTION_CM_CONNECTED = 
    		"cc.imlab.ble.bleapi.ACTION_CM_CONNECTED";
    public final static String ACTION_CM_DISCONNECTED = 
    		"cc.imlab.ble.bleapi.ACTION_CM_DISCONENCTED";
}
