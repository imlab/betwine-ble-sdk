package cc.imlab.ble.bleapi.framework;

import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.UUID;

import cc.imlab.ble.bleapi.BetwineCMDefines;
import android.R.integer;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.os.Handler;
import android.util.Log;


/**
 * This Gatt Queue is specific for Android, because it cann't handle 
 * multiple Read/Write operations at the same time
 * 
 * @author Terry Ouyang
 *
 */
public class CMBDGattQueue {
	
	private BluetoothGatt gatt;
	
	public Boolean isProcessing;
	public Queue<CMBDGattCommand> queue;
	
	public CMBDGattQueue() {
		queue = new LinkedList<CMBDGattQueue.CMBDGattCommand>();
		isProcessing = false;
	}
	
	public enum CMBDGattCommandType {
		Read,
		Write,
		Notify,
	}	
	
	public class CMBDGattCommand {
		BluetoothGattCharacteristic characteristic;
		CMBDGattCommandType operation;
		byte[] writeValue;
		Boolean notifyValue;
		
		public CMBDGattCommand(CMBDGattCommandType operation,
				BluetoothGattCharacteristic characteristic) {
			this.characteristic = characteristic;
			this.operation = operation;
		}
		
		int executeWithGatt(BluetoothGatt gatt) {
			int next_delay = 100;
			switch(operation) {
			case Read:
				gatt.readCharacteristic(characteristic);
//				next_delay = 1500;
				
				break;
				
			case Write:
		    	characteristic.setValue(writeValue);
		    	characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
		    	gatt.writeCharacteristic(characteristic);
//		    	next_delay = 1500;
		    	
				break;
				
			case Notify:
				gatt.setCharacteristicNotification(characteristic, notifyValue);
				
				BluetoothGattDescriptor keyDescriptor = characteristic.getDescriptor(UUID.fromString(BetwineCMDefines.CB_CHAR_UUID_KEY_DESCRIPTOR));
				if (keyDescriptor != null) {
					keyDescriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
					gatt.writeDescriptor(keyDescriptor);
				} else {
					Log.d("CMBDGattQueue", "key descriptor is null");
				}
//				next_delay = 2000;
				
				break;
			
			default:
				break;
			}
			
			return next_delay;
		}
		
	}
	
	void addReadCommand(BluetoothGattCharacteristic characteristic) {
		CMBDGattCommand command = new CMBDGattCommand(CMBDGattCommandType.Read, characteristic);
		this.queue.add(command);
	}
	
	void addWriteCommand(BluetoothGattCharacteristic characteristic, byte[] writeVaule) {
		CMBDGattCommand command = new CMBDGattCommand(CMBDGattCommandType.Write, characteristic);
		command.writeValue = writeVaule;
		this.queue.add(command);
	}
	
	void addNotifyCommand(BluetoothGattCharacteristic characteristic, Boolean boolValue) {
		CMBDGattCommand command = new CMBDGattCommand(CMBDGattCommandType.Notify, characteristic);
		command.notifyValue = boolValue;
		this.queue.add(command);
	}
	
	void setGatt(BluetoothGatt gatt) {
		this.gatt = gatt;
		
		if (gatt == null) {
			queue.clear();
		}
	}
	
	void checkProceedQueue() {
		
		if (isProcessing || gatt == null) {
			return;
		}
		
		// procceed queue
		if (queue.size() > 0) {
			this.isProcessing = true;
			this.executeNextQueueCommand();
		}
	}
	
	int executeNextQueueCommand() {
		
		int next_delay = 10;
		
		if (queue.size() > 0) {
			this.isProcessing = true;
			CMBDGattCommand command = queue.poll();
			next_delay = command.executeWithGatt(gatt);
	
			Log.i("CMBDGattQueue", "execute command: " + command.operation);
		
		}
		else {
			isProcessing = false;
		}
		
		return next_delay;
	}
	
	
}
