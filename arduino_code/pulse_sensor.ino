
/*
   The following libraries are necessary
   for the asynchronous web server 
*/
#include <Arduino.h>
#include <WiFi.h>
#include <AsyncTCP.h>           // https://github.com/dvarrel/ESPAsyncTCP
#include <ESPAsyncWebSrv.h>  // https://github.com/dvarrel/ESPAsyncWebSrv
#include <Arduino_JSON.h>
#include <ESPmDNS.h>

#include <PulseSensorPlayground.h>

JSONVar pulseData;  // We use JSON to pass data from the Arduino sketch to the Javascript

const int PULSE_INPUT = 34;
const int PULSE_BLINK = 32;
const int PULSE_FADE = 5;
const int THRESHOLD = 580;  // Determine which Signal to "count as a beat", and which to ingore.

PulseSensorPlayground pulseSensor;

/*  Replace with your network credentials  */
const char *ssid = "LordOlumide's benevolence";
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
String updatePulseDataJson() {
  pulseData["heartrate"] = String(pulseSensor.getBeatsPerMinute());
  String jsonString = JSON.stringify(pulseData);
  return jsonString;
}

// Static IP configuration
IPAddress local_ip(192, 168, 118, 213); // Replace with your desired static IP address
IPAddress gateway(192, 168, 1, 1);    // Replace with your network's gateway IP address
IPAddress subnet(255, 255, 255, 0);   // Replace with your network's subnet mask

// Begin the WiFi and print the server url to the serial port on connection
void beginWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.config(local_ip, gateway, subnet); // Set the static IP configuration

  WiFi.begin(ssid, password);
  Serial.print("Attempting to connect to ");
  Serial.print(ssid);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(" ~");
    delay(1000);
  }
  Serial.println("\nConnected");
  
  // Start mDNS service
  if (!MDNS.begin("pulse32")) {  // You can change connect to http://pulse32.local
    Serial.println("Error setting up MDNS responder!");
    return;
  }
  Serial.print("mDNS responder started with ");
  Serial.println("http://pulse32.local");
}

/* 
   When sendPulseSignal is true, PulseSensor Signal data
   is sent to the serial port for user monitoring.
   Modified by keys received on the Serial port.
   Use the Serial Plotter to view the PulseSensor Signal wave.
*/
bool sendPulseSignal = false;

void setup() {
  /*
   115200 baud provides about 11 bytes per millisecond.
   The delay allows the port to settle so that 
   we don't miss out on info about the server url
   in the Serial Monitor so we can connect a browser.
*/
  Serial.begin(115200);
  delay(1500);
  beginWiFi();

  // ESP32 analogRead defaults to 12 bit resolution PulseSensor Playground library works with 10 bit
  analogReadResolution(10);

  /*  Configure the PulseSensor manager  */
  pulseSensor.analogInput(PULSE_INPUT);
  pulseSensor.blinkOnPulse(PULSE_BLINK);
  pulseSensor.fadeOnPulse(PULSE_FADE);
  pulseSensor.setSerial(Serial);
  pulseSensor.setThreshold(THRESHOLD);

  /*  Now that everything is ready, start reading the PulseSensor signal. */
  if (!pulseSensor.begin()) {
    while (1) {
      /*  If the pulseSensor object fails, flash the led  */
      digitalWrite(PULSE_BLINK, LOW);
      delay(50);
      digitalWrite(PULSE_BLINK, HIGH);
      delay(50);
    }
  }


  // When the server gets a request for the root url serve the html
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(200, "text/html", index_html);
  });

  // Request for the latest PulseSensor data
  server.on("/data", HTTP_GET, [](AsyncWebServerRequest *request) {
    String json = updatePulseDataJson();
    request->send(200, "application/json", json);
    json = String();
  });

  /*  
    Handler for when a client connects to the server  
    Only send serial feedback when NOT sending PulseSensor Signal data
    Send event with short message and set reconnect timer to 2 seconds
*/
  events.onConnect([](AsyncEventSourceClient *client) {
    if (!sendPulseSignal) {
      if (client->lastId()) {
        Serial.println("Client Reconnected");
      } else {
        Serial.println("New Client Connected");
      }
    }
    client->send("hello", NULL, millis(), 20000);
  });

  /*  Create a handler for events  */
  server.addHandler(&events);

  /*  Start the server  */
  server.begin();

  /*  Print the control information to the serial monitor  */
  printControlInfo();
}

void loop() {
  /*
     Option to send the PulseSensor Signal data
     to serial port for verification
*/
  if (sendPulseSignal) {
    delay(20);
    Serial.println(pulseSensor.getLatestSample());
  }


  /*
     If a beat has happened since we last checked,
     update the json data file to the server.
     Also, send the new BPM value to the serial port
     if we are not monitoring the pulse signal.
*/
  if (pulseSensor.sawStartOfBeat()) {
    events.send(updatePulseDataJson().c_str(), "new_data", millis());
    if (!sendPulseSignal) {
      Serial.print(pulseSensor.getBeatsPerMinute());
      Serial.println(" bpm");
    }
  }
  /*  Check to see if there are any commands sent to us  */
  serialCheck();
}

/*
    This function checks to see if there are any commands available
    on the Serial port. When you send keyboard characters 'b' or 'x'
    you can turn on and off the signal data stream.
*/
void serialCheck() {
  if (Serial.available() > 0) {
    char inChar = Serial.read();
    switch (inChar) {
      case 'b':
        sendPulseSignal = true;
        break;
      case 'x':
        sendPulseSignal = false;
        break;
      case '?':
        if (!printControlInfo) {
          printControlInfo();
        }
        break;
      default:
        break;
    }
  }
}

// This function prints the control information to the serial monitor
void printControlInfo() {
  Serial.println("PulseSensor ESP32 Example");
  Serial.print("\nPulseSensor Server url: ");
  Serial.println(WiFi.localIP());
  Serial.println("Send 'b' to begin sending PulseSensor signal data");
  Serial.println("Send 'x' to stop sending PulseSensor signal data");
  Serial.println("Send '?' to print this message");
}
