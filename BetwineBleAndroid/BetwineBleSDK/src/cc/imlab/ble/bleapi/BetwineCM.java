package cc.imlab.ble.bleapi;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothAdapter.LeScanCallback;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;
import cc.imlab.ble.betwine.app.BTBetwineAppPC;
import cc.imlab.ble.bleapi.BetwineCMDefines.DeviceType;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralConnector;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralInterface;


public class BetwineCM {
	private static final String TAG = BetwineCM.class.getSimpleName();
    
    /* Betwine CM private variables */
    private BluetoothManager mBluetoothManager;
    private BluetoothAdapter mBluetoothAdapter;
    
    private BetwineCMService cmService;
    private Handler mHandler;
    private boolean mScanning = false;
    private Map<String, BluetoothDevice> discoverList; // address as key
    private Map<String, CMBDPeripheralConnector> connectList; // address as key
    
    private DeviceType scanDeviceType = DeviceType.None;
    
    public BetwineCM(BetwineCMService cmService) {
    	this.cmService = cmService;
    	
    	mHandler = new Handler();
    	discoverList = new Hashtable<String, BluetoothDevice>();
    	connectList = new Hashtable<String, CMBDPeripheralConnector>();
    	
    	this.initialize();
    }

    public void broadcastUpdate(final String action) {
        final Intent intent = new Intent(action);
        cmService.sendBroadcast(intent);
    }
    
    public void broadcastUpdate(final Intent intent) {
    	cmService.sendBroadcast(intent);
    }
    
    public BetwineCMService getServiceContext() {
    	return cmService;
    }
    
    private LeScanCallback onLeScanCallback = new BluetoothAdapter.LeScanCallback() {

        @Override
        public void onLeScan(final BluetoothDevice device, int rssi, byte[] scanRecord) {
//        	Log.i(TAG, "found device: " + device + " rssi: "+ rssi + " scanRecord: " + scanRecord);
        	
        	if (isScanTypeCorrect(device)) {
        		discoverList.put(device.getAddress(), device);
        	}
        	else {
        		Log.i(TAG, "ignore device: " + device);
        	}
        }
        
        /**
         * Used for manual filtering by device type (because 16bit UUID doesn't work for scan filtering)
         * 
         * @param device
         * @return true by default(no filtering); false if doesn't match the type 
         */
        @SuppressLint("DefaultLocale")
		public boolean isScanTypeCorrect(BluetoothDevice device) {
        	switch (scanDeviceType) {
			case BetwineApp:
				
				if (device.getName() != null && device.getName().toLowerCase().contains("betwine")) {
					return true;
				} else {
					return false;
				}

			default:
				/* default true */
				return true;
			}
        }
    };

    /**
     * Initializes a reference to the local Bluetooth adapter.
     *
     * @return Return true if the initialization is successful.
     */
    public boolean initialize() {
        // For API level 18 and above, get a reference to BluetoothAdapter through
        // BluetoothManager.
        if (mBluetoothManager == null) {
            mBluetoothManager = (BluetoothManager) cmService.getSystemService(Context.BLUETOOTH_SERVICE);
            if (mBluetoothManager == null) {
                Log.e(TAG, "Unable to initialize BluetoothManager.");
                return false;
            }
        }

        mBluetoothAdapter = mBluetoothManager.getAdapter();
        if (mBluetoothAdapter == null) {
            Log.e(TAG, "Unable to obtain a BluetoothAdapter.");
            return false;
        }

        return true;
    }
    
    
    public void close() {
    	for (CMBDPeripheralConnector pc: connectList.values()) {
    		pc.close();
    	}
    	
    	discoverList.clear();
    	connectList.clear();
    }
    
    public boolean hasPeripheralConnectedWithType(DeviceType type) {
    	return getConnectorWithType(type) != null;
    }
    
    public CMBDPeripheralConnector getConnectorWithType(DeviceType type) {

    	for (CMBDPeripheralConnector pc: connectList.values()) {
    		if (pc.getDeviceType() == type) {
    			return pc;
    		}
    	}
    	
    	return null;
    }
    
    public CMBDPeripheralInterface getInterfaceWithType(DeviceType type) {
    	CMBDPeripheralConnector pc = getConnectorWithType(type);
    	if (pc != null) {
    		return pc.getInterface();
    	}
    	
    	return null;
    }
    
    public void scanBleDeviceWithType(DeviceType type) {

		scanDeviceType = type;
		
    	switch(type) {
		case BetwineApp:
//			UUID svc = BTAppDefines.uuidForAndroid(BTAppDefines.CB_BROADCAST_SVC_UUID_APP);
//			UUID[] bcUuids = {svc};
//			scanBleDeviceWithUUID(bcUuids);
			scanBleDeviceWithUUID(null);
			
			break;
			
		default:
			scanBleDeviceWithUUID(null);
			break;
		}
    }
    
    private void scanBleDeviceWithUUID(UUID[] serviceUUids) {

        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                
                // show scan result
            	BetwineCM.this.stopScan();
            }
        }, BetwineCMDefines.SCAN_PERIOD);

        discoverList.clear();
    	
    	// if scan with UUIDs
    	if (serviceUUids != null && serviceUUids.length > 0) {
    		StringBuffer buffer = new StringBuffer();
    		for (UUID uuid: serviceUUids) {
    			buffer.append("\n" + uuid.toString());
    		}
    		
    		Log.d(TAG, "scan with UUIDs: " + buffer.toString());
	        mScanning = mBluetoothAdapter.startLeScan(serviceUUids, onLeScanCallback);
    	}
    	// if scan without UUIDs
    	else {
    		Log.d(TAG, "scan without UUIDs");
    		mScanning = mBluetoothAdapter.startLeScan(onLeScanCallback);
    	}
    	
    	if (!mScanning) {
    		Log.e(TAG, "Le scan cannot be done. Check app perimissions?");
    	}
    	else {
            broadcastUpdate(BetwineCMDefines.ACTION_CM_START_SCAN);
    	}
    }
    
    public void stopScan() {
        mScanning = false;
        mBluetoothAdapter.stopLeScan(onLeScanCallback);
        
        // show scanning result
        List<String> choiceList = new ArrayList<String>();
        List<String> addressList = new ArrayList<String>();
        final BluetoothDevice[] deviceList = discoverList.values().toArray(new BluetoothDevice[]{});
        for (BluetoothDevice device: deviceList) {
        	Log.i(TAG, "found device: (" + device.getAddress() + ") " + device.getName()
        			+ ", type:" + device.getType() + ", bond: " + device.getBondState());
        	
        	choiceList.add(device.getName() + "("+ device.getAddress().replace(":", "") + ")");
        	addressList.add(device.getAddress());
        }
        // let user choose the device to connect
        Intent intent = new Intent(BetwineCMDefines.ACTION_CM_STOP_SCAN);
        intent.putExtra(BetwineCMDefines.ACTION_CM_EXTRA_DEVICE_NAME_LIST, choiceList.toArray(new String[]{}));
        intent.putExtra(BetwineCMDefines.ACTION_CM_EXTRA_DEVICE_ADDR_LIST, addressList.toArray(new String[]{}));
        broadcastUpdate(intent);
        
    }
    
    public void connectDeviceWithAddress(String address) {
    	
    	BluetoothDevice device = discoverList.get(address); 
    			
    	if (device != null) {
			BTBetwineAppPC appPC = new BTBetwineAppPC(device, this);
			connectList.put(address, appPC);
	    	appPC.connect();
    	}
    	else {
    		Log.e(TAG, "trying to connect a non-exist device (failed): " + address);
    	}
    }
    
    public void disconnectDeviceWithAddress(String address) {
    	CMBDPeripheralConnector pc = connectList.get(address);
    	
    	if (pc != null) {
    		pc.disconnect();
    		pc.close();

    		connectList.remove(address);
    	}
    }

}
