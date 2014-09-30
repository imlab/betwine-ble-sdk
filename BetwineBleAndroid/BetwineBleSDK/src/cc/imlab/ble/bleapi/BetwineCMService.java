package cc.imlab.ble.bleapi;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

/* You also need to add this service in your app project */
public class BetwineCMService extends Service {

	private static final String TAG = BetwineCMService.class.getSimpleName();
	
	private BetwineCMBinder mBinder = null;

	@Override
	public void onCreate() {
		Log.i(TAG, "onCreate");
		super.onCreate();		

		mBinder = new BetwineCMBinder(this);
	}

	@Override
	public void onDestroy() {
		Log.i(TAG, "onDestroy");
		mBinder.close(); // release resource
		
		super.onDestroy();
	}

	@Override
	public boolean onUnbind(Intent intent) {
		Log.i(TAG, "onUnBind");
		return super.onUnbind(intent);
	}

	@Override
	public IBinder onBind(Intent intent) {
		Log.i(TAG, "onBind: " + intent + " binder: " + mBinder);
		return mBinder;
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		Log.i(TAG, "onStartCommand");
		return super.onStartCommand(intent, flags, startId);
	}
}
