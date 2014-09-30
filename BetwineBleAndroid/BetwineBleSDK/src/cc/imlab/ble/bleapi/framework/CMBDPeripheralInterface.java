package cc.imlab.ble.bleapi.framework;

public interface CMBDPeripheralInterface {

	public void onPCReady(); // recognize and register services needed
	public void onConnected();
	public void onDisconnected();
}
