package cc.imlab.ble.bleapi.framework;

import java.util.List;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.Intent;
import android.util.Log;
import cc.imlab.ble.bleapi.BetwineCM;
import cc.imlab.ble.bleapi.BetwineCMDefines;
import cc.imlab.ble.bleapi.BetwineCMDefines.DeviceType;

public abstract class CMBDPeripheralConnector extends BluetoothGattCallback {
	
	protected BetwineCM cm;
	
	protected BluetoothDevice device;
	protected BluetoothGatt gatt;
	
	protected int mConnectionState = BetwineCMDefines.STATE_DISCONNECTED;
	private boolean keepConnection = false;

	abstract protected String tag(); // logger tag

	public CMBDPeripheralConnector(BluetoothDevice device, BetwineCM cm) {
		super();
		
		this.device = device;
		this.cm = cm;
	}
	
	public void connect() {
		Intent intent = new Intent(BetwineCMDefines.ACTION_CM_CONNECTING);
		broadcast(intent);
		
		mConnectionState = BetwineCMDefines.STATE_CONNECTING;
		gatt = device.connectGatt(cm.getServiceContext(), true, this);
		keepConnection = true;
	}
	
	public void disconnect(){
		if (gatt != null) {
			gatt.disconnect();
			keepConnection = false;
		}
	}
	
	public void close() {
		if (gatt != null) {
			gatt.close();
		}
	}
	
	public void broadcast(Intent intent) {
		cm.broadcastUpdate(intent);
	}

	public BluetoothDevice getDevice() {
		return device;
	}
	
	abstract public DeviceType getDeviceType();
	abstract public CMBDPeripheralInterface getInterface();
	abstract public void onCharacteristicsDiscovered();
	abstract public void onConnected();
	abstract public void onDisconnected();
	abstract public void onDataUpdate(BluetoothGattCharacteristic characteristic);
	
	public void onServiceDiscoverReady() {
		// notify device status ready
		Intent intent = new Intent(BetwineCMDefines.ACTION_CM_CONNECTED);
		cm.broadcastUpdate(intent);
		
		onCharacteristicsDiscovered();
	}

	/* BluetoothGattCallback methods */
   @Override
    public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
    	
        if (newState == BetwineCMDefines.STATE_CONNECTED) {
            mConnectionState = BetwineCMDefines.STATE_CONNECTED;
            onConnected();
            
            Log.i(tag(), "Connected to GATT server.");
            // Attempts to discover services after successful connection.
            Log.i(tag(), "Attempting to start service discovery:" +
                    gatt.discoverServices());

        } else if (newState == BetwineCMDefines.STATE_DISCONNECTED) {
       
            mConnectionState = BetwineCMDefines.STATE_DISCONNECTED;
            onDisconnected();
            
            Log.i(tag(), "Disconnected from GATT server.");
            
            // reconnect ...
            if (keepConnection) {
            	Log.i(tag(), "Trying to reconnect device...");
//        		mConnectionState = BetwineCMDefines.STATE_CONNECTING;
//        		gatt = device.connectGatt(cm.getServiceContext(), true, this);
            	connect();
            }
            else {
            	// notify disconnect
            	Intent intent = new Intent(BetwineCMDefines.ACTION_CM_DISCONNECTED);
            	cm.broadcastUpdate(intent);
            }
        }
    }

    @Override
    public void onServicesDiscovered(BluetoothGatt gatt, int status) {
        if (status == BluetoothGatt.GATT_SUCCESS) {
            Log.w(tag(), "onServicesDiscovered received:\n" + gatt.getServices());
            
            onServiceDiscoverReady();
            
        } else {
            Log.w(tag(), "onServicesDiscovered status: " + status);
        }
    }

    @Override
    public void onCharacteristicRead(BluetoothGatt gatt,
                                     BluetoothGattCharacteristic characteristic,
                                     int status) {
    	Log.i(tag(), "--receive charecteristic read -- " + characteristic.getUuid());
        if (status == BluetoothGatt.GATT_SUCCESS) {
        	// data update
        	onDataUpdate(characteristic);
        }
    }

    @Override
    public void onCharacteristicChanged(BluetoothGatt gatt,
                                        BluetoothGattCharacteristic characteristic) {
    	Log.i(tag(), "--receive charecteristic notification -- " + characteristic.getUuid());
    	// data update
    	onDataUpdate(characteristic);
    }
    
    @Override
    public void onCharacteristicWrite(BluetoothGatt gatt,
    		BluetoothGattCharacteristic characteristic, int status) {
    	super.onCharacteristicWrite(gatt, characteristic, status);
    	Log.i(tag(), "--write characteristic: " + characteristic.getUuid() + " status: " + status);
    }
    
    /**
     * Request a read on a given {@code BluetoothGattCharacteristic}. The read result is reported
     * asynchronously through the {@code BluetoothGattCallback#onCharacteristicRead(android.bluetooth.BluetoothGatt, android.bluetooth.BluetoothGattCharacteristic, int)}
     * callback.
     *
     * @param characteristic The characteristic to read from.
     */
    public void readCharacteristic(BluetoothGattCharacteristic characteristic) {
        if (gatt != null) {
            gatt.readCharacteristic(characteristic);
        }
        else {
        	Log.w(tag(), "trying to read characteristic from null gatt(char: " + characteristic +")");
        }
    }
    
    public void writeCharacteristic(BluetoothGattCharacteristic characteristic, byte[] bytes) {
    	if (gatt != null) {
	    	characteristic.setValue(bytes);
	    	characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
	    	gatt.writeCharacteristic(characteristic);
    	}
    	else {
        	Log.w(tag(), "trying to write characteristic from null gatt(char: " + characteristic + ")");
    	}
    }

    /**
     * Enables or disables notification on a give characteristic.
     *
     * @param characteristic Characteristic to act on.
     * @param enabled If true, enable notification.  False otherwise.
     */
    public void setCharacteristicNotification(BluetoothGattCharacteristic characteristic,
                                              boolean enabled) {
        if (gatt == null) {
            Log.w(tag(), "trying to set notification characteristic from null gatt");
            return;
        }
        gatt.setCharacteristicNotification(characteristic, enabled);
    }

    /**
     * Retrieves a list of supported GATT services on the connected device. This should be
     * invoked only after {@code BluetoothGatt#discoverServices()} completes successfully.
     *
     * @return A {@code List} of supported services.
     */
    public List<BluetoothGattService> getSupportedGattServices() {
        if (gatt == null) return null;

        return gatt.getServices();
    }
    
}