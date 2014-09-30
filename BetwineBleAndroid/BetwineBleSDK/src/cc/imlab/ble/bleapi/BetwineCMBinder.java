package cc.imlab.ble.bleapi;

import cc.imlab.ble.betwine.app.BTBetwineAppInterface;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralConnector;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralInterface;
import android.os.Binder;

public class BetwineCMBinder extends Binder {

	private BetwineCM cm; 
	
	public BetwineCMBinder(BetwineCMService service) {
		this.cm = new BetwineCM(service);
	}
	
	public void scanForPeripheralsWithType(BetwineCMDefines.DeviceType type) {
		
		cm.scanBleDeviceWithType(type);
	}
	
	public void stopScanningForPeripheral() {
		cm.stopScan();
	}
	
	public boolean hasPeripheralConnectedWithType(BetwineCMDefines.DeviceType type) {
		return cm.hasPeripheralConnectedWithType(type);
	}
	
	public void disconnectPeriphearlWithType(BetwineCMDefines.DeviceType type) {
		CMBDPeripheralConnector pc =  cm.getConnectorWithType(type);
		pc.disconnect();
	}
	
	public CMBDPeripheralInterface getInterfaceWithType(BetwineCMDefines.DeviceType type) {
		return cm.getInterfaceWithType(type);
	}
	
	/**
	 * Release Gatt resources. It should not be called by anyone else except BetwineCMService.
	 */
	public void close() {
		cm.close();
	}
}
