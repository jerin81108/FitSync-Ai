package ai.fitsync.fitsync_ai

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), SensorEventListener {
    private val CHANNEL = "ai.fitsync.fitsync_ai/steps"
    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var lastHardwareSteps: Int = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        stepSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        if (stepSensor != null) {
            sensorManager?.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceSteps" -> {
                    val hasSensor = stepSensor != null
                    // If hardware steps were recorded, return them; otherwise return available sensor reading
                    val steps = if (lastHardwareSteps > 0) lastHardwareSteps else 0
                    result.success(
                        mapOf(
                            "hasHardwareSensor" to hasSensor,
                            "steps" to steps,
                            "sensorName" to (stepSensor?.name ?: "Hardware Pedometer")
                        )
                    )
                }
                "hasStepSensor" -> {
                    result.success(stepSensor != null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            val totalSteps = event.values[0].toInt()
            if (totalSteps > 0) {
                lastHardwareSteps = totalSteps
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // No-op
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager?.unregisterListener(this)
    }
}
