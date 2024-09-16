/*
  Optical Heart Rate Detection (PBA Algorithm) using the MAX30105 Breakout
  By: Nathan Seidle @ SparkFun Electronics
  Date: October 2nd, 2016
  https://github.com/sparkfun/MAX30105_Breakout

  This is a demo to show the reading of heart rate or beats per minute (BPM) using
  a Penpheral Beat Amplitude (PBA) algorithm.

  It is best to attach the sensor to your finger using a rubber band or other tightening
  device. Humans are generally bad at applying constant pressure to a thing. When you
  press your finger against the sensor it varies enough to cause the blood in your
  finger to flow differently which causes the sensor readings to go wonky.

  Hardware Connections (Breakoutboard to ESP32):
  -Vin = (3.3V is allowed)
  -GND = GND
  -SDA = 21
  -SCL = 22
  -INT = Not connected
*/

/*
   The following libraries are necessary
   for the asynchronous web server 
*/
#include <Arduino.h>
#include <WiFi.h>
#include <AsyncTCP.h>  // https://github.com/dvarrel/ESPAsyncTCP
#include <ESPAsyncWebSrv.h>
#include <Arduino_JSON.h>

// Necessary for MAX30105 sensor
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"

// Necessary for LCD 1602
#include <LCD_I2C.h>

#define pulse_sensor_sda_pin 17
#define pulse_sensor_scl_pin 16

#define lcd_sda_pin 21
#define lcd_scl_pin 22

// Initialize I2C communication with the defined pins
TwoWire lcdI2CPort = TwoWire(0);
TwoWire particleSensorI2CPort = TwoWire(1);

LCD_I2C lcd(0x27, 16, 2);  // set the LCD address for a 16 chars and 2 line display

MAX30105 particleSensor;

const byte RATE_SIZE = 4;  //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE];     //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0;  //Time at which the last beat occurred

float beatsPerMinute;
int beatAvg;

JSONVar pulseData;  // We use JSON to pass data from the Arduino sketch to the server

const int blinkLed = 33;
const int fingerDetectedLed = 26;

/*  Replace with your network credentials  */
const char *ssid = "PulseSensor";
const char *password = "11111111";

// Create AsyncWebServer object on port 80. Create an Event Source on /events
AsyncWebServer server(80);
AsyncEventSource events("/events");

/*
    The following code between the two "rawliteral" tags
    will be stored as text. It contains the html,
    css, and javascript that will be used to build
    the asynchronous server.
*/
const char index_html[] PROGMEM = R"rawliteral(
<!DOCTYPE HTML html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="data:,">
      <style>
      html {
        font-family: Arial; 
        display: inline-block; 
        margin: 0px auto;
        text-align: center;
      }
      h2 { font-size: 3.0rem; }
      p { font-size: 3.0rem; }
      .reading { 
        font-size: 2.0rem;
        color:black;
      }
      .dataType {
        font-size: 1.8rem;
      }
    </style>
  </head>
  <body>
      <h2>PulseSensor Server</h2>
      <p 
        <span class="reading"> Heart Rate</span>
        <span id="bpm"></span>
        <span class="dataType">bpm</span>
      </p> 
  </body>
<script>
window.addEventListener('load', getData);

function getData(){
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var Jobj = JSON.parse(this.responseText);
      console.log(Jobj);
      document.getElementById("bpm").innerHTML = Jobj.heartrate;
    }
  }; 
  xhr.open("GET", "/data", true);
  xhr.send();
}

if (!!window.EventSource) {
  var source = new EventSource('/events');

  source.addEventListener('open', function(e) {
    console.log("Events Connection");
  }, false);

  source.addEventListener('error', function(e) {
    if (e.target.readyState != EventSource.OPEN) {
      console.log("Events Disconnection");
    }
  }, false);

  source.addEventListener('new_data', function(e) {
    console.log("new_data", e.data);
    var Jobj = JSON.parse(e.data);
    document.getElementById("bpm").innerHTML = Jobj.heartrate;
  }, false);
}
</script>
</html>)rawliteral";

/*  Package the BPM in a JSON object  */
String updatePulseDataJson(long irValue) {
  bool isFingerDetected = irValue > 50000;

  long delta = millis() - lastBeat;
  lastBeat = millis();

  beatsPerMinute = 60 / (delta / 1000.0);

  if (beatsPerMinute < 255 && beatsPerMinute > 20) {
    rates[rateSpot++] = (byte)beatsPerMinute;  //Store this reading in the array
    rateSpot %= RATE_SIZE;                     //Wrap variable

    //Take average of readings
    beatAvg = 0;
    for (byte x = 0; x < RATE_SIZE; x++)
      beatAvg += rates[x];
    beatAvg /= RATE_SIZE;

    lcd.clear();
    if (isFingerDetected) {
      lcd.setCursor(2, 0);
      lcd.print("Pulse Rate:  ");
      lcd.setCursor(2, 1);
      lcd.print(beatAvg);
      lcd.print(" BPM     ");
    } else {
      lcd.setCursor(1, 0);
      lcd.print("IP Address:  ");
      lcd.setCursor(0, 1);
      lcd.print(WiFi.localIP());
    }
  }

  pulseData["isFingerDetected"] = isFingerDetected;
  pulseData["IR-value"] = irValue;
  pulseData["bpm"] = (int)beatsPerMinute;
  pulseData["avgBPM"] = beatAvg;

  String jsonString = JSON.stringify(pulseData);
  return jsonString;
}

// Begin the WiFi and print the server url to the serial port on connection
void beginWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Attempting to connect to ");
  Serial.print(ssid);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(" ~");
    delay(1000);
  }
  Serial.println("\nConnected");
}

void setup() {
  pinMode(blinkLed, OUTPUT);
  pinMode(fingerDetectedLed, OUTPUT);

  /*
   115200 baud provides about 11 bytes per millisecond.
   The delay allows the port to settle so that 
   we don't miss out on info about the server url
   in the Serial Monitor so we can connect a browser.
*/
  Serial.begin(115200);
  Serial.println("Initializing...");
  digitalWrite(blinkLed, HIGH);
  delay(1500);

  // Initialize LCD
  lcd.begin();
  lcd.backlight();

  beginWiFi();

  lcd.setCursor(1, 0);
  lcd.print("IP Address:  ");
  lcd.setCursor(0, 1);
  lcd.print(WiFi.localIP());

  // Initialize the I2C ports
  // lcdI2CPort.begin(lcd_sda_pin, lcd_scl_pin, 100000);
  particleSensorI2CPort.begin(pulse_sensor_sda_pin, pulse_sensor_scl_pin, 400000);

  // Initialize sensor
  if (!particleSensor.begin(particleSensorI2CPort, 400000))  //Use default I2C port, 400kHz speed
  {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1)
      ;
  }
  Serial.println("Place your index finger on the sensor with steady pressure.");
  particleSensor.setup();                     //Configure sensor with default settings
  particleSensor.setPulseAmplitudeRed(0x0A);  //Turn Red LED to low to indicate sensor is running
  particleSensor.setPulseAmplitudeGreen(0);   //Turn off Green LED

  // When the server gets a request for the root url serve the html
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(200, "text/html", index_html);
  });

  // Request for the latest PulseSensor data
  server.on("/data", HTTP_GET, [](AsyncWebServerRequest *request) {
    String json = updatePulseDataJson(particleSensor.getIR());
    request->send(200, "application/json", json);
    json = String();
  });

  /*  
    Handler for when a client connects to the server  
    Only send serial feedback when NOT sending PulseSensor Signal data
    Send event with short message and set reconnect timer to 2 seconds
*/
  events.onConnect([](AsyncEventSourceClient *client) {
    if (client->lastId()) {
      Serial.println("Client Reconnected");
    } else {
      Serial.println("New Client Connected");
    }
    client->send("hello", NULL, millis(), 20000);
  });

  /*  Create a handler for events  */
  server.addHandler(&events);

  /*  Start the server  */
  server.begin();
}

void loop() {
  long irValue = particleSensor.getIR();
  bool fingerIsDetected = irValue >= 50000;

  if (fingerIsDetected) {
    digitalWrite(fingerDetectedLed, HIGH);
  } else {
    digitalWrite(fingerDetectedLed, LOW);
  }

  if (checkForBeat(irValue) == true) {
    //We sensed a beat!
    if (fingerIsDetected) {
      digitalWrite(blinkLed, HIGH);
    }
    String jsonString = updatePulseDataJson(irValue);
    Serial.println("Sending JSON: " + jsonString);  // Debugging line

    events.send(jsonString.c_str(), "new_data", millis());
  } else {
    digitalWrite(blinkLed, LOW);
  }
}
