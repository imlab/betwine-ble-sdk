package cc.imlab.ble.betwine.app;

import java.util.Calendar;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import android.content.Intent;
import android.os.Handler;
import android.util.Log;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralConnector;
import cc.imlab.ble.bleapi.framework.CMBDPeripheralInterface;

public class BTBetwineAppInterface extends CMBDPeripheralInterface {
	private static final String TAG = BTBetwineAppInterface.class.getSimpleName();
	
	private BTBetwineAppPC pc;
	
	private boolean appReady = false;
	private int activeMoveSteps = 0;
	private Date activeMoveDate = new Date();
	
	public int steps;
	public int energy;
	public int activity;
	public int battery = 0xFF;
	public boolean[] leds = new boolean[6];
	public int[] stepHistory = new int[7];
	public boolean batteryCharging;
	public int lastVibTime;
	public int systemTest;
	public int systemTime;
	public String productId;
	public String macAddr;
	
	public Handler mHandler;
	
	public BTBetwineAppInterface(BTBetwineAppPC pc) {
		this.pc = pc;
		this.appReady = false;
		
		this.mHandler = new Handler();
	}

	public void onPCReady() {
		Log.i(TAG, "BetwineApp discover is ready!");
		this.appReady = true;
		
		
		mHandler.postDelayed(new Runnable() {
			
			@Override
			public void run() {

				// register notify characteristics
				pc.enablePedometer();
				pc.enableHp();
				pc.enableTime();
				pc.enableDeviceInfo();
				pc.enableVibrateTest();
				
				// read data
				pc.readHp();
				pc.readPedometer();
				pc.readBatt();
				pc.readOldSteps();
				pc.readDeviceInfo();
				pc.readVibrateTest();
				
				// proceed Async Queue
				proceedAsyncQueue();
			}
		}, 200);
	}
	
	public void onConnected() {
		// do nothing
	}
	
	public void onDisconnected() {
		this.appReady = false;
	}
	
	protected CMBDPeripheralConnector getConnector() {
		return this.pc;
	}

	public Boolean sendSetSystemTime(Date time, Integer beginTime, Integer endTime) {
		if (!this.appReady) {
			return false;
		}
		
		byte[] timeBytes = new byte[6];
		
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(time);
		
		timeBytes[0] = (byte) calendar.get(Calendar.HOUR_OF_DAY); // system time's minute
		timeBytes[1] = (byte) calendar.get(Calendar.MINUTE); // system time's hours
		timeBytes[2] = (byte) ((byte) (beginTime / 100) % 24);
		timeBytes[3] = (byte) ((byte) (beginTime % 100) % 60);
		timeBytes[4] = (byte) ((byte) (endTime / 100) % 24);
		timeBytes[5] = (byte) ((byte) (endTime % 100) % 60);
		
		Log.i(TAG, String.format("send set system time: %d:%02d wakeTime: %d:%02d sleepTime: %d:02d", 
			timeBytes[0], timeBytes[1], timeBytes[2], timeBytes[3], timeBytes[4], timeBytes[5]));
		
		pc.setTime(timeBytes);
		
		return true;
	}
	
	public Boolean sendVibrateAndLED() {
		
		byte sendValue = 0;
		
		if (leds[0]) {
			sendValue |= 0x20;
		} else {
			sendValue &= ~0x20;
		}
		
		if (leds[1]) {
			sendValue |= 0x10;
		} else {
			sendValue &= ~0x10;
		}
		
		if (leds[2]) {
			sendValue |= 0x08;
		} else {
			sendValue &= ~0x08;
		}
		
		if (leds[3]) {
			sendValue |= 0x04;
		} else {
			sendValue &= ~0x04;
		}
		
		if (leds[4]) {
			sendValue |= 0x02;
		} else {
			sendValue &= ~0x02;
		}
		
		if (leds[5]) {
			sendValue |= 0x01;
		} else {
			sendValue &= ~0x01;
		}

		if (!this.appReady) {
			
			BTAsyncRequest request = new BTAsyncRequest(BTAsyncRequestType.VibrateAndLED, sendValue);
			asyncQueueSaveRequest(request);
			return false;
		}
		else {
			pc.setMotor(sendValue);
			return true;
		}
	}
	
	public Boolean sendEnterOAD() {
		if (!appReady) {
			return false;
		}
		byte sendValue = BTAppDefines.CB_DEVICE_TEST_RESET;
		pc.setMotor(sendValue);
		
		return true;
	}
	
	public Boolean sendReadCurrentStatus() {
		if (!appReady){
			return false;
		}
		
		pc.readHp();
		pc.readPedometer();
		
		return true;
	}
	
	public Boolean sendReadStepHistory() {
		if (!appReady) {
			return false;
		}
		
		pc.readOldSteps();
		
		return true;
	}
	
	public Boolean sendReadBattery() {
		if (!appReady) {
			return false;
		}
		
		pc.readBatt();
		
		return true;
	}

	public Boolean sendReadDeviceInfo() {
		if (!appReady) {
			return false;
		}

		pc.readDeviceInfo();
		
		return true;
	}
	
	public Boolean sendReadVibTest() {
		if (!appReady) {
			return false;
		}
		
		pc.readVibrateTest();
		
		return true;
	}
	
	public Boolean sendDeviceTestCode(Byte testCode) {
		if (!appReady) {
			return false;
		}
		
		pc.setMotor(testCode);
		
		return true;
	}
	
	/* BTBetwineAppPC data update methods */
	private int stepFromBytes(byte[] b) {
		int step_int = b[0] & 0xFF |
				(b[1] & 0xFF) << 8 |
				(b[2] & 0xFF) << 16;
		
		return step_int;
	}
	
	public void hpUpdate(byte hpValue) {
		energy = hpValue;
		
		Log.i(TAG, "receive energy(hp): " + hpValue);
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_ENERGY);
		intent.putExtra("energy", energy);
		pc.broadcast(intent);
	}
	
	public void stateUpdate(byte stepState) {
		activity = stepState;
		
		Log.i(TAG, "receive state: " + stepState);
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_ACT);
		intent.putExtra("activity", activity);
		pc.broadcast(intent);
	}
	
	public void stepUpdate(byte[] stepValue) {
		int oldSteps = steps;
		steps = stepFromBytes(stepValue);
		
		Log.i(TAG, "receive steps: " + steps);
		
		if (steps != oldSteps) {
			Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_STEPS);
			intent.putExtra("steps", steps);
			pc.broadcast(intent);
		}
		
		// active move check
		Date now = new Date();
		final float ACTIVE_MOVE_TIME_THRESHOLD = 3.5f;
		final int ACTIVE_MOVE_STEPS_THRESHOLD = 5;
		if (steps < activeMoveSteps || activeMoveSteps == 0||
				(now.getTime() - activeMoveDate.getTime()) / 1000 > ACTIVE_MOVE_TIME_THRESHOLD * 3) {
			activeMoveSteps = steps;
			activeMoveDate = now;
			
			Log.d(TAG, "initiate active steps: " + activeMoveSteps);
		}
		else if (steps - activeMoveSteps >= ACTIVE_MOVE_STEPS_THRESHOLD) {
			Date oldTime = activeMoveDate;
			activeMoveSteps = steps;
			activeMoveDate = now;
			
			if ((now.getTime() - oldTime.getTime()) / 1000 <= ACTIVE_MOVE_TIME_THRESHOLD) {
				Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_ACTIVE_MOVE);
				pc.broadcast(intent);
			}
			
			Log.d(TAG, "set active steps:" + activeMoveSteps);
		}
	}
	
	public void timeUpdate(byte[] tsValue) {
		int minute = tsValue[0] % 60;
		int hour = tsValue[1] % 24;
		systemTime = hour * 100 + minute;
		
		Log.i(TAG, "receive time: " + hour + ":" + minute);
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_TIME);
		intent.putExtra("systemTime", systemTime);
		pc.broadcast(intent);
	}
	
	public void battUpdate(byte battValue) {
		battery = battValue & 0x7F;
		batteryCharging = (battValue & 0x80) > 0;
		
		Log.i(TAG, "receive battery level: " + battery + " charging: " + batteryCharging);
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_BATTERY);
		intent.putExtra("battery", battery);
		intent.putExtra("charging", batteryCharging);
		pc.broadcast(intent);
	}
	
	public void oldStepsUpdate(byte[] oldSteps) {
		StringBuffer buffer = new StringBuffer();
		
		final int CMBD_HISTORY_STEPS_DAYS = 7; 
		for (int i = 0; i < CMBD_HISTORY_STEPS_DAYS; i++) {
			int step_int = oldSteps[3*i] & 0xFF |
					(oldSteps[3*i + 1] & 0xFF) << 8 |
					(oldSteps[3*i + 2] & 0xFF) << 16;
			
			stepHistory[i] = step_int;
			
			if (stepHistory[i] == 0xFFFFFF) {
				stepHistory[i] = 0;
			} else {
				stepHistory[i] = Math.min(stepHistory[i], 199999);
			}
			
			buffer.append(" " + stepHistory[i]);
			if (i != CMBD_HISTORY_STEPS_DAYS - 1) {
				buffer.append(",");
			}
		}
		
		Log.i(TAG, "receive history steps: " + buffer.toString());
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_HISTORY_STEPS);
		intent.putExtra("stepHistory", stepHistory);
		pc.broadcast(intent);
	}
	
	public void deviceInfoUpdate(byte[] bytes) {
		productId = String.format("%02x%02x", bytes[0], bytes[1]);
		macAddr = String.format("%02x%02x%02x%02x%02x%02x", 
				bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]);
		
		Log.i(TAG, "receive product id: " + productId + " mac addr: " + macAddr);
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_DEVICE_INFO);
		intent.putExtra("productId", productId);
		intent.putExtra("macAddr", macAddr);
		pc.broadcast(intent);
	}
	
	public void vibrateTestUpdate(byte[] testValue) {
		int minute = testValue[0];
		int hour = testValue[1];
		
		lastVibTime = hour * 100 + minute;
		systemTest = testValue[2] << 8 | testValue[3];
		
		Log.i(TAG, "receive last vib time: " + lastVibTime + " test result: " + systemTest);
		
		Intent intent = new Intent(BTAppDefines.ACTION_RECEIVE_LAST_VIBRATE);
		intent.putExtra("lastVibTime", lastVibTime);
		intent.putExtra("systemTest", systemTest);
		pc.broadcast(intent);
	}
	 
	/* Async Request */
	private static final Integer ASYNC_QUEUE_LENGTH = 10;
	private static final Integer ASYNC_QUEUE_EFFECTIVE_INTERVAL = 180; // 3 minutes
	enum BTAsyncRequestType {
		VibrateAndLED,
		BindingVibrate,
	};
	
	class BTAsyncRequest {
		public Date time;
		public BTAsyncRequestType reqType;
		public Byte command;
		
		public BTAsyncRequest(BTAsyncRequestType reqType, Byte cmd) {
			this.time = new Date();
			this.reqType = reqType;
			this.command = cmd;
		}
	}
	
	List<BTAsyncRequest> asyncQueue = new LinkedList<BTAsyncRequest>();
	
	private void asyncQueueSaveRequest(BTAsyncRequest req) {
		if (asyncQueue.size() < ASYNC_QUEUE_LENGTH) {
			asyncQueue.add(req);
		}
		else {
			Log.d(TAG, "async queue is full. discard the oldest one and insert...");
			
			asyncQueue.remove(0);
			asyncQueue.add(req);
		}
		Log.i(TAG, "saved async command in queue");
	}
	
	private void proceedAsyncQueue() {
		Date now = new Date();
		
		int pokeCnt = 0;
		int bindCnt = 0;
		int otherCnt = 0;
		
		for (BTAsyncRequest req: asyncQueue) {
			
			switch (req.reqType) {
			case VibrateAndLED: 

				if ( (now.getTime() - req.time.getTime()) / 1000 < ASYNC_QUEUE_EFFECTIVE_INTERVAL) {
					pokeCnt++;
				}
				break;
				
			case BindingVibrate:
				
				bindCnt++;
				break;
				
			default:
				
				otherCnt++;
				break;
			}
		}
		
		if (otherCnt > 0) {
			Log.w(TAG, "there's unknown request type in the async queue");
		}
		
		pokeCnt = (pokeCnt > 5) ? 5 : pokeCnt;
		for (int i = 0; i <= 5; i++) {
			leds[i] = true;
		}

		for (int i = 0; i< pokeCnt; i++) {
			sendVibrateAndLED();
		}
		
		if (bindCnt > 0) {
			for (int i = 0; i <= 5; i++) {
				leds[i] = true;
			}
			sendVibrateAndLED();
		}
		// clear queue
		asyncQueue.clear();
	}
	
	public void sendBindingVibrate() {
		BTAsyncRequest req = new BTAsyncRequest(BTAsyncRequestType.BindingVibrate, (byte)0xFF);
		asyncQueueSaveRequest(req);
	}
	
}
