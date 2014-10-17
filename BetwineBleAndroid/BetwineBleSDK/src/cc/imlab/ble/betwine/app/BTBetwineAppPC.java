package cc.imlab.ble.betwine.app;

import java.util.Arrays;
import java.util.UUID;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.util.Log;
import cc.imlab.ble.bleapi.BetwineCM;
import cc.imlab.ble.bleapi.BetwineCMDefines.DeviceType;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralConnector;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralInterface;

public class BTBetwineAppPC extends CMBDPeripheralConnector {
	private static final String TAG = BTBetwineAppPC.class.getSimpleName();
	
	private BluetoothGattCharacteristic hpChar;
	private BluetoothGattCharacteristic stateChar;
	private BluetoothGattCharacteristic stepChar;
	private BluetoothGattCharacteristic motorChar;
	private BluetoothGattCharacteristic vibTestChar; // v1.1 feature
	private BluetoothGattCharacteristic timeChar;
	private BluetoothGattCharacteristic battChar;
	private BluetoothGattCharacteristic oldStepChar;
	private BluetoothGattCharacteristic deviceInfoChar; // v1.1 feature
	
	private BTBetwineAppInterface btApp;
	
	public BTBetwineAppPC(BluetoothDevice device, BetwineCM cm) {
		super(device, cm);

		hpChar = null;
		stateChar = null;
		stepChar = null;
		motorChar = null;
		vibTestChar = null;
		timeChar = null;
		battChar = null;
		oldStepChar = null;
		deviceInfoChar = null;
		
		btApp = new BTBetwineAppInterface(this);
	}
	
	@Override
	protected String tag() {
		return TAG;
	}

	public DeviceType getDeviceType() {
		return DeviceType.BetwineApp;
	}
	
	@Override
	public void onConnected() {
		btApp.onConnected();
	}
	
	@Override
	public void onDisconnected() {
		btApp.onDisconnected();
		
		hpChar = null;
		stateChar = null;
		stepChar = null;
		motorChar = null;
		vibTestChar = null;
		timeChar = null;
		battChar = null;
		oldStepChar = null;
		deviceInfoChar = null;
		
	}

	@Override
	public void onCharacteristicsDiscovered() {
		// iterate characteristic features
		int matchCnt = 0;
		for (BluetoothGattService svc: gatt.getServices()) {
			for (BluetoothGattCharacteristic ch: svc.getCharacteristics()) {
				UUID chUuid = ch.getUuid();
				
				if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_HP_VALUE_UUID))) {
					Log.d(TAG, "found HP char " + chUuid);
					hpChar = ch;	
					matchCnt++;
				}
				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_PM_STATE_UUID))) {
					Log.d(TAG, "found state char " + chUuid);
					stateChar = ch;
					matchCnt++;
				}

				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_PM_VALUE_UUID))) {
					Log.d(TAG, "found steps char " + chUuid);
					stepChar = ch;
					matchCnt++;
				}

				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_MR_VALUE_UUID))) {
					Log.d(TAG, "found motor char " + chUuid);
					motorChar = ch;
					matchCnt++;
				}

				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_MR_TEST_VALUE_UUID))) {
					Log.d(TAG, "found vib test char " + chUuid);
					vibTestChar = ch;
					matchCnt++;
				}

				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_TS_VALUE_UUID))) {
					Log.d(TAG, "found time char " + chUuid);
					timeChar = ch;
					matchCnt++;
				}

				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_BS_VALUE_UUID))) {
					Log.d(TAG, "found batt char " + chUuid);
					battChar = ch;
					matchCnt++;
				}
				
				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_HS_STEPS_UUID))) {
					Log.d(TAG, "found old steps char " + chUuid);
					oldStepChar = ch;
					matchCnt++;
				}				

				else if (chUuid.equals(
						BTAppDefines.uuidForAndroid(BTAppDefines.CB_MAC_VALUE_UUID))) {
					Log.d(TAG, "found device info char " + chUuid);
					deviceInfoChar = ch;
					matchCnt++;
				}
				else {
					Log.d(TAG, "cannot match uuid: " + chUuid);
				}
			}
			Log.d(TAG, "characterstics match count: " + matchCnt);

		}
		
		getInterface().onPCReady();
	}
	
	public void enableHp() {
		Log.d(TAG, "enable Hp");
		if (gatt != null && hpChar != null) {
			setCharacteristicNotification(hpChar, true);
		}
	}
	
	public void enablePedometer() {
		Log.d(TAG, "enable pedometer");
		if (gatt != null && stateChar != null && stepChar != null) {
			setCharacteristicNotification(stateChar, true);
			setCharacteristicNotification(stepChar, true);
		}
	}
	
	public void enableTime() {
		Log.d(TAG, "enable time");
		if (gatt != null && timeChar != null) {
			setCharacteristicNotification(timeChar, true);
		}
	}
	
	public void enableDeviceInfo() {
		Log.d(TAG, "enable device info");
		if (gatt != null && deviceInfoChar != null) {
			setCharacteristicNotification(deviceInfoChar, true);
		}
	}
	
	public void enableVibrateTest() {
		Log.d(TAG, "enable vib test");
		if (gatt != null && vibTestChar != null) {
			setCharacteristicNotification(vibTestChar, true);
		}
	}
	
	public void disableHp() {
		if (gatt != null && hpChar != null) {
			setCharacteristicNotification(hpChar, false);
		}
	}
	
	public void disablePedometer() {
		if (gatt != null && stateChar != null && stepChar != null) {
			setCharacteristicNotification(stateChar, false);
			setCharacteristicNotification(stepChar, false);
		}
	}

	public void disableTime() {
		if (gatt != null && timeChar != null) {
			setCharacteristicNotification(timeChar, false);
		}
	}
	
	public void disableDeviceInfo() {
		if (gatt != null && deviceInfoChar != null) {
			setCharacteristicNotification(deviceInfoChar, false);
		}
	}

	public void disableVibrateTest() {
		if (gatt != null && vibTestChar != null) {
			setCharacteristicNotification(vibTestChar, false);
		}
	}
	
	public void readHp() {
		if (gatt != null && hpChar != null) {
			Log.d(tag(), "try to read hp");
			readCharacteristic(hpChar);
		}
	}
	
	public void readPedometer() {
		if (gatt != null && stateChar != null && stepChar != null) {
			Log.d(tag(), "try to read state and step");
			readCharacteristic(stateChar);
			readCharacteristic(stepChar);
		}
	}
	
	public void readTime() {
		if (gatt != null && timeChar != null) {
			Log.d(tag(), "try to read time");
			readCharacteristic(timeChar);
		}
	}
	
	public void readBatt() {
		if (gatt != null && battChar != null) {
			Log.d(tag(), "try to read battery");
			readCharacteristic(battChar);
		}
	}
	
	public void readOldSteps() {
		if (gatt != null && oldStepChar != null) {
			Log.d(tag(), "try to read history steps");
			readCharacteristic(oldStepChar);
		}
	}
	
	public void readDeviceInfo() {
		if (gatt != null && deviceInfoChar != null) {
			Log.d(tag(), "try to read device info");
			readCharacteristic(deviceInfoChar);
		}
	}
	
	public void readVibrateTest() {
		if (gatt != null && vibTestChar != null) {
			Log.d(tag(), "try to read vib test");
			readCharacteristic(vibTestChar);
		}
	}
	
	public void setMotor(byte motorValue) {
		if (gatt != null && motorChar != null) {
			Log.d(tag(), "try to send motor and led");
			writeCharacteristic(motorChar, new byte[]{motorValue});
		}
	}
	
	public void setTime(byte[] time) {
		 if (gatt != null && timeChar != null) {
				Log.d(tag(), "try to send time");
			 writeCharacteristic(timeChar, time);
		 }
	}

	@Override
	public CMBDPeripheralInterface getInterface() {
		return btApp;
	}

	@Override
	public void onDataUpdate(BluetoothGattCharacteristic characteristic) {
		UUID chUuid = characteristic.getUuid();
		
		if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_HP_VALUE_UUID))) {
			byte hpValue = characteristic.getValue()[0];
			btApp.hpUpdate(hpValue);
		}
		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_PM_STATE_UUID))) {
			byte pmState = characteristic.getValue()[0];
			btApp.stateUpdate(pmState);
		}
		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_PM_VALUE_UUID))) {
			byte[] pmValue = Arrays.copyOf(characteristic.getValue(), 
					BTAppDefines.CB_PM_VALUE_LEN);
			btApp.stepUpdate(pmValue);
		}
		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_MR_TEST_VALUE_UUID))) {
			byte[] vibTestValue = Arrays.copyOf(characteristic.getValue(), 
					BTAppDefines.CB_MR_TEST_VALUE_LEN);
			btApp.vibrateTestUpdate(vibTestValue);
		}

		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_TS_VALUE_UUID))) {
			byte[] tsValue = Arrays.copyOf(characteristic.getValue(), 
					BTAppDefines.CB_TS_VALUE_LEN);
			btApp.timeUpdate(tsValue);
		}

		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_BS_VALUE_UUID))) {
			byte btValue = characteristic.getValue()[0];
			btApp.battUpdate(btValue);
		}
		
		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_HS_STEPS_UUID))) {
			byte[] oldSteps = Arrays.copyOf(characteristic.getValue(), 
					BTAppDefines.CB_HS_VALUE_LEN);
			btApp.oldStepsUpdate(oldSteps);
		}				

		else if (chUuid.equals(
				BTAppDefines.uuidForAndroid(BTAppDefines.CB_MAC_VALUE_UUID))) {
			byte[] devInfo = Arrays.copyOf(characteristic.getValue(), 
					BTAppDefines.CB_MAC_VALUE_LEN);
			btApp.deviceInfoUpdate(devInfo);
		}
		else {
			Log.d(TAG, "cannot match data update uuid: " + chUuid);
		}
	}
	
}
