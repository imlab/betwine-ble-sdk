package cc.imlab.ble.bleapi;

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
	
	/**
	 * Release Gatt resources. It should not be called by anyone else except BetwineCMService.
	 */
	public void close() {
		cm.close();
	}
}
