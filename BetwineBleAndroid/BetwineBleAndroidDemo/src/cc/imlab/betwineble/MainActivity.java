package cc.imlab.betwineble;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

public class MainActivity extends Activity {
	private static final String TAG = MainActivity.class.getSimpleName();

	private Button btnEnter;
	private TextView textBTStatus;
	private ProgressBar progressBT;
	
	// request codes
	private int REQUEST_ENABLE_BT = 1;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		btnEnter = (Button) findViewById(R.id.btnEnter);
		textBTStatus = (TextView)findViewById(R.id.textBTStatus);
		progressBT = (ProgressBar)findViewById(R.id.progressBT);
		progressBT.setVisibility(View.INVISIBLE);

		if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
			textBTStatus.setText("Sorry. Bluetooth 4.0 LE is not available\non your device.");
			btnEnter.setText("OK");
			
			btnEnter.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// exit application
					finish();
					
					// or harder kill
//					android.os.Process.killProcess(android.os.Process.myPid());
				}
			});
		}
		else {
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	protected void onStart() {
		Log.i(TAG, "onStart");
		super.onStart();
		
		checkBluetooth();
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		Log.i(TAG, "onResume");
	}

	private OnClickListener bluetoothCheckListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			checkBluetooth();
		}
	};

	public void checkBluetooth() {
		textBTStatus.setText("Initializing Bluetooth...");
		btnEnter.setVisibility(View.INVISIBLE);
		progressBT.setVisibility(View.VISIBLE);
		
		
		/* Bluetooth Adapter is required for any and all bluetooth activity */
		
		// Initializes Bluetooth adapter.
		final BluetoothManager bluetoothManager =
		        (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
		BluetoothAdapter mBluetoothAdapter = bluetoothManager.getAdapter();
		
		// If bluetooth is not enabled, request user to turn it on
		if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
		    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
		    startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
		}
		else {
			// enter demo app
			Intent intent = new Intent(MainActivity.this, BetwineDemoActivity.class);
			startActivity(intent);
			
			textBTStatus.setText("Bluetooth is ready.");
			btnEnter.setVisibility(View.VISIBLE);
			btnEnter.setText("OK");
			btnEnter.setOnClickListener(bluetoothCheckListener);
			progressBT.setVisibility(View.INVISIBLE);
		}
	}
	
	@Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // User chose not to enable Bluetooth.
		Log.i(MainActivity.class.getSimpleName(), "request code: " + requestCode + " resultCode: " + resultCode);
		progressBT.setVisibility(View.INVISIBLE);
		
        if (requestCode == REQUEST_ENABLE_BT) {
        	
        	if (resultCode == Activity.RESULT_OK) {
        		// retry prepare bluetooth
        		checkBluetooth();
        	}
        	else if (resultCode == Activity.RESULT_CANCELED) {
        		// prompt user to enable bluetooth again
        		textBTStatus.setText("You must enable Bluetooth to use this app.");
        		btnEnter.setText("OK");
        		btnEnter.setVisibility(View.VISIBLE);  
    			btnEnter.setOnClickListener(bluetoothCheckListener);
        	}
        }
    }
}
