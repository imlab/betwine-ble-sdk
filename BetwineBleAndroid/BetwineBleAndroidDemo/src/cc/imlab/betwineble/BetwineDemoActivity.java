package cc.imlab.betwineble;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothAdapter.LeScanCallback;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;
import cc.imlab.betwineble.R.id;
import cc.imlab.ble.betwine.app.BTAppDefines;
import cc.imlab.ble.betwine.app.BTBetwineAppInterface;
import cc.imlab.ble.bleapi.BetwineCMBinder;
import cc.imlab.ble.bleapi.BetwineCMDefines;
import cc.imlab.ble.bleapi.BetwineCMDefines.DeviceType;
import cc.imlab.ble.bleapi.BetwineCMService;

public class BetwineDemoActivity extends Activity {
	private static final String TAG = BetwineDemoActivity.class.getSimpleName();
	
	// Betwine CM Service
	Intent cmServiceIntent = null;
	BetwineCMBinder cmBinder = null;
	BTBetwineAppInterface btApp;
	
	/* widgets */
	private TextView textMacAddr;
	private TextView textBTStatus;
	private TextView textProdId;
	private TextView textHistorySteps;
	private TextView textActivity;
	private TextView textEnergy;
	private TextView textSteps;
	private TextView textBattery;
	private TextView textDeviceId;
	private CheckBox checkBoxLed1;
	private CheckBox checkBoxLed2;
	private CheckBox checkBoxLed3;
	private CheckBox checkBoxLed4;
	private CheckBox checkBoxLed5;
	
	private Button btnPoke;
	private Button btnConnect;
	private Button btnSetTime;
	private Button btnTest;
	
	private ImageView imageAvatar;
	
	private final ServiceConnection conn = new ServiceConnection() {
		
		@Override
		public void onServiceConnected(ComponentName name, IBinder service) {
			Log.i(TAG, "BetwineCMService connected: " + name + " binder: " + service);
			cmBinder = (BetwineCMBinder) service;
		} 
		
		@Override
		public void onServiceDisconnected(ComponentName name) {
			Log.i(TAG, "BetwineCMService disconnected: " + name);
			cmBinder = null;
		}
	};
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_betwine_demo);
		
		textMacAddr = (TextView) findViewById(R.id.textMacAddr);
		textBTStatus = (TextView) findViewById(R.id.textBTStatus);
		textProdId = (TextView) findViewById(R.id.textProdId);
		textHistorySteps = (TextView) findViewById(R.id.textHistorySteps);
		textActivity = (TextView) findViewById(R.id.textActivity);
		textEnergy = (TextView) findViewById(R.id.textEnergy);
		textSteps = (TextView) findViewById(R.id.textSteps);
		textBattery = (TextView) findViewById(R.id.textBattery);
		textDeviceId = (TextView) findViewById(R.id.textDeviceId);
		btnPoke = (Button) findViewById(R.id.btnPoke);
		btnConnect = (Button) findViewById(R.id.btnConnect);
		btnSetTime = (Button) findViewById(R.id.btnSetTime);
		btnTest = (Button) findViewById(R.id.btnTest);
		checkBoxLed1 = (CheckBox)findViewById(R.id.checkBox1);
		checkBoxLed2 = (CheckBox)findViewById(R.id.checkBox2);
		checkBoxLed3 = (CheckBox)findViewById(R.id.checkBox3);
		checkBoxLed4 = (CheckBox)findViewById(R.id.checkBox4);
		checkBoxLed5 = (CheckBox)findViewById(R.id.checkBox5); 
		imageAvatar = (ImageView) findViewById(R.id.imageAvatar);
		
		btnPoke.setOnClickListener(btnPokeClickListener);
		btnConnect.setOnClickListener(btnConnectClickListener);
		btnSetTime.setOnClickListener(btnSetTimeClickListener);
		btnTest.setOnClickListener(btnTestClickListener);
		
		btnPoke.setEnabled(false);
		btnSetTime.setEnabled(false);
		btnTest.setEnabled(false);
		
		// start BetwineCM service
		cmServiceIntent = new Intent(this, BetwineCMService.class);
		startService(cmServiceIntent);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		
		// stop BetwineCM service
		stopService(cmServiceIntent);
		
		// quit program
		android.os.Process.killProcess(android.os.Process.myPid());
	}
	
	@Override
	protected void onStart() {
		Log.i(TAG, "onStart");
		super.onStart();
		
		// bind BetwineCM service
		bindService(cmServiceIntent, conn, BIND_AUTO_CREATE);
		
		IntentFilter filter = makeBetwineCMIntentFilter();
		registerReceiver(cmBroadcastReceiver, filter);
		
		IntentFilter btAppFilter = makeBetwineAppIntentFilter();
		registerReceiver(cmBetwineAppReceiver, btAppFilter);
	}

	@Override
	protected void onStop() {
		super.onStop();
		
		// unbind BetwineCM service
		if (cmBinder != null) {
			unbindService(conn);
		}
		unregisterReceiver(cmBroadcastReceiver);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
//		Log.i(TAG, "cmBinder: " + cmBinder);
		
		// check bluetooth availability
		if (cmBinder == null || !cmBinder.hasPeripheralConnectedWithType(BetwineCMDefines.DeviceType.BetwineApp)) {
			btnConnect.setText("Scan");
		}
		else {
			btnConnect.setText("Disconnect");
		}
	}
	
	public void scanForBetwineApp() {
		cmBinder.scanForPeripheralsWithType(BetwineCMDefines.DeviceType.BetwineApp);
//		cmBinder.scanForPeripheralsWithType(BetwineCMDefines.DeviceType.None);
	}
	
	private OnClickListener btnPokeClickListener = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			if (btApp != null) {
				
				btApp.leds[1] = checkBoxLed1.isChecked();
				btApp.leds[2] = checkBoxLed2.isChecked();
				btApp.leds[3] = checkBoxLed3.isChecked();
				btApp.leds[4] = checkBoxLed4.isChecked();
				btApp.leds[5] = checkBoxLed5.isChecked();
				
				btApp.sendVibrateAndLED();
			}
			else {
				Log.w(TAG, "device is not conencted. cannot poke!");
			}
		}
	};
	
	private OnClickListener btnConnectClickListener = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			
			if (cmBinder.hasPeripheralConnectedWithType(BetwineCMDefines.DeviceType.BetwineApp)) {
				
				// disconnect device
				cmBinder.disconnectPeriphearlWithType(BetwineCMDefines.DeviceType.BetwineApp);
			}
			else {
				// scan for device
				scanForBetwineApp();
				
				btnConnect.setText("Scanning...");
				btnConnect.setEnabled(false);
			}
		}
	};
	
	private OnClickListener btnSetTimeClickListener = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			Log.i(TAG, "Btn Set Time not implemented yet");
		}
	};
	
	private OnClickListener btnTestClickListener = new OnClickListener() {
		
		@Override
		public void onClick(View v) {
			if (btApp != null) {
				btApp.sendReadBattery();
			}
		}
	};
	
	/* Intent Filter for BetwineCM connection events */
	private IntentFilter makeBetwineCMIntentFilter() {
		IntentFilter intentFilter = new IntentFilter();
		intentFilter.addAction(BetwineCMDefines.ACTION_CM_START_SCAN);
		intentFilter.addAction(BetwineCMDefines.ACTION_CM_STOP_SCAN);
		intentFilter.addAction(BetwineCMDefines.ACTION_CM_CONNECTING);
		intentFilter.addAction(BetwineCMDefines.ACTION_CM_CONNECTED);
		intentFilter.addAction(BetwineCMDefines.ACTION_CM_DISCONNECTED);
		
		return intentFilter;
	}
	
	private BroadcastReceiver cmBroadcastReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			
			if (BetwineCMDefines.ACTION_CM_START_SCAN.equals(action)) {
				
			}
			else if (BetwineCMDefines.ACTION_CM_STOP_SCAN.equals(action)) {
				btnConnect.setText("Scan");
				btnConnect.setEnabled(true);
			}
			else if (BetwineCMDefines.ACTION_CM_CONNECTING.equals(action)) {
				btnConnect.setText("Connecting...");
				btnConnect.setEnabled(false);
			}
			else if (BetwineCMDefines.ACTION_CM_CONNECTED.equals(action)) {
				btnConnect.setText("Disconnect");
				btnConnect.setEnabled(true);
				btnPoke.setEnabled(true);
				btnSetTime.setEnabled(true);
				btnTest.setEnabled(true);
				
				btApp = (BTBetwineAppInterface) cmBinder.getInterfaceWithType(BetwineCMDefines.DeviceType.BetwineApp);
				btApp.sendBindingVibrate(); // binding vibrate
			}
			else if (BetwineCMDefines.ACTION_CM_DISCONNECTED.equals(action)) {
				boolean keepConnection = intent.getBooleanExtra("keepConnection", true);
				btApp = null; // to disable btApp interaction
				
				if (keepConnection) {
					btnConnect.setText("Connecting...");
					btnConnect.setEnabled(false);
				}
				else {
					btnConnect.setText("Scan");
					btnConnect.setEnabled(true);
					
					btnPoke.setEnabled(false);
					btnSetTime.setEnabled(false);
					btnTest.setEnabled(true);
				}
			}
		}
		
	};
	

	/* Intent Filter for BetwineApp data events */
	private IntentFilter makeBetwineAppIntentFilter() {
		IntentFilter intentFilter = new IntentFilter();
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_ACT);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_ACTIVE_MOVE);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_ALL_STATUS);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_BATTERY);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_DEVICE_INFO);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_ENERGY);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_HISTORY_STEPS);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_LAST_VIBRATE);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_STEPS);
		intentFilter.addAction(BTAppDefines.ACTION_RECEIVE_TIME);
		
		return intentFilter;
	}
	
	private BroadcastReceiver cmBetwineAppReceiver = new BroadcastReceiver() {
		
		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			
			if (BTAppDefines.ACTION_RECEIVE_ACT.equals(action)) {
				receiveActivity(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_ACTIVE_MOVE.equals(action)) {
				receiveActiveMove(intent);
			}
//			else if (BTAppDefines.ACTION_RECEIVE_ALL_STATUS.equals(action)) {
//				// deprecated
//			}
			else if (BTAppDefines.ACTION_RECEIVE_BATTERY.equals(action)) {
				receiveBattery(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_DEVICE_INFO.equals(action)) {
				receiveDeviceInfo(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_ENERGY.equals(action)) {
				receiveEnergy(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_HISTORY_STEPS.equals(action)) {
				receiveHistorySteps(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_LAST_VIBRATE.equals(action)) {
				receiveLastVibrate(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_STEPS.equals(action)) { 
				receiveSteps(intent);
			}
			else if (BTAppDefines.ACTION_RECEIVE_TIME.equals(action)) {
				receiveTime(intent);
			}
			else {
				Log.w(TAG, "received unknown betwine app data intent action: " + action);
			}
		}
	};
	
	public void receiveActivity(Intent intent) {
		textActivity.setText("" + intent.getIntExtra("acitivity", 0));
	}
	
	public void receiveActiveMove(Intent intent) {
		Log.i(TAG, "Active move! ");
	}
	
//	public void receiveAllStatus(Intent intent) {
//		
//	}
	
	public void receiveBattery(Intent intent) {
		textBattery.setText("" + intent.getIntExtra("battery", 0) + 
				" charging: " + intent.getBooleanExtra("charging", false));
	}
	
	public void receiveDeviceInfo(Intent intent) {
		textProdId.setText(intent.getCharSequenceExtra("productId"));
		textMacAddr.setText(intent.getCharSequenceExtra("macAddr"));
	}
	
	public void receiveEnergy(Intent intent) {
		textEnergy.setText("" + intent.getIntExtra("energy", 0));
	}
	
	public void receiveHistorySteps(Intent intent) {
		int[] historySteps = intent.getIntArrayExtra("stepHistory");
		StringBuffer buffer = new StringBuffer();
		for (int i = 0; i < historySteps.length; i++) {
			buffer.append("Day " + i + ": " + historySteps[i] + "\n");
		}
		
		textHistorySteps.setText(buffer.toString());
	}
	
	public void receiveLastVibrate(Intent intent) {
		int time = intent.getIntExtra("lastVibTime", 0);
		Log.i(TAG, "Last vibrate time: " + (time / 100) + ":" + (time%100));
		Log.i(TAG, "system test: " + intent.getIntExtra("systemTest", 0));
	}
	
	public void receiveSteps(Intent intent) {
		textSteps.setText("" + intent.getIntExtra("steps", 0));
	}
	
	public void receiveTime(Intent intent) {
		int time = intent.getIntExtra("systemTime", 0);
		Log.i(TAG, "receive system time: " + (time/100) + ":" + (time%100));
	}
}
