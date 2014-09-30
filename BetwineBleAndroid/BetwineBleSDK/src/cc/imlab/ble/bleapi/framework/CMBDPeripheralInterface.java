package cc.imlab.ble.bleapi.framework;

import android.os.ParcelUuid;

public abstract class CMBDPeripheralInterface {

	abstract public void onPCReady(); // recognize and register services needed
	abstract public void onConnected();
	abstract public void onDisconnected();
	
	abstract protected CMBDPeripheralConnector getConnector();
	
	
	public String getDeviceName() {
		return getConnector().getDevice().getName();
	}
	
	public String getDeviceAddress() {
		return getConnector().getDevice().getAddress();
	}
	
	public ParcelUuid[] getDeviceUuids() {
		return getConnector().getDevice().getUuids();
	}
}
