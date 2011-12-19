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

#ifndef Config_h
#define Config_h

#include "WProgram.h"


// Set this to the arduino pin that control overall slave power
#define pinStatus 5

// Set this to the IR sensor min detect level
#define IRSensorThreshold 120

// Set this to the number of IRSensor (2 max)
#define IRSensorCount 2


////////////////////////////////
// END OF CONFIGURABLE VALUES //
///////////////////////////////
//const byte pinNumber = ledCount * 3;

#endif
