// Copyright (c) 2011 Mathieu Alorent
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "config.h"

#include <Tlc5940.h>
#include <RGBConverter.h>
#include <TrueRandom.h>
#include <Wire.h>
#include <EasyTransferI2C.h>

#include <EffectRideau.h>
#include <EffectRainbow.h>






struct RECEIVE_DATA_STRUCTURE{
  //put your variable definitions here for the data you want to send
  //THIS MUST BE EXACTLY THE SAME ON THE OTHER ARDUINO
  byte sensorId;
  int  sensorLight;
};

RECEIVE_DATA_STRUCTURE rx;
EasyTransferI2C ET;

Led leds[LED_COUNT];
EffectRainbow effect(leds);
EffectRideau effect2(leds);

// global state of system
boolean globalState = OFF;

int running = 0;
int on = 0;
int data = 0;
byte launchedWith = 0;
unsigned long lastTime;
unsigned long lightOnTime = 5 *1000000;
unsigned long veille = 10 *1000000;

void setup()
{
  Serial.begin(9600);
  Wire.begin(9);
  ET.begin(details(rx), &Wire);
  Wire.onReceive(fake);

  Serial.println("Hello world!");
  Serial.println("---== INIT RUNING ==---");

  randomSeed(analogRead(0));

  // Init pinsStatus
  pinMode(pinStatus, INPUT);

  // Init TLC & set to OFF
  Tlc.init(4096); // WHITE

  for (byte i = 0; i < LED_COUNT; ++i) {
    leds[i].init(i);
  }

  setPuissanceAll(leds, MAX_POWER);

  effect.init();

  setStatusOn();
  render(leds);
  delay(1000);
  setColorAll(leds, black);
  render(leds);
  setStatusOff();

  Serial.println("---== INIT END ==---");
}

void loop()
{
  if(data) {
    Serial.println("---== I2C DATA RECEIVED ==---");
    data = 0;
    printReceivedData();
    running = 1;
    if (!on) {
//      effect.init((byte) rx.sensorId);
      int powerLed = (rx.sensorLight / 1024.0) * MAX_POWER;
      Serial.print("PowerLed is: ");
      Serial.println(powerLed);
      //setPuissanceAll(leds, powerLed);
      on = 1;
      setStatusOn();
      launchedWith = rx.sensorId;
    }
  }

  if (running == 1) {
    effect.run();
    if(effect.isEnded()) {
      running = 0;
      lastTime = micros();
    }
  } 
  else if (on == 1 && micros() - lastTime >= lightOnTime && lastTime) {
//    effect.init(7 + launchedWith);
    running = 1;
    on = 0;
  }
  else if (getStatus() && micros() - lastTime >= veille && lastTime) {
    setStatusOff();
  }

  render(leds);
}


void printReceivedData() {
  Serial.println("Received DATAS: ");
  Serial.print("sensorId: ");
  Serial.println((int)rx.sensorId);
  Serial.print("sensorLight: ");
  Serial.println(rx.sensorLight);
}


void fake(int nb) {
  ET.receiveData();
  data=1;
}



boolean getStatus () {
  return globalState;
}

void setStatus (boolean ledStatus) {
  if (ledStatus) {
#ifdef DEBUG
    Serial.println("Set pinStatus to HIGH");
#endif
    analogWrite(pinStatus, 255);
    globalState = ON;
  }
  else {
#ifdef DEBUG
    Serial.println("Set pinStatus to LOW");
#endif
    analogWrite(pinStatus, 0);
    globalState = OFF;
  }
}

void setStatusOn () {
  Serial.println("Sortie de veille");
  setStatus(ON);
}

void setStatusOff () {
  Serial.println("Entree en veille");
  setStatus(OFF);
  Tlc.clear();
  Tlc.update();
}













