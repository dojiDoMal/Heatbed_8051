# Heatbed with 8051 µC ![Build Status](https://camo.githubusercontent.com/cfcaf3a99103d61f387761e5fc445d9ba0203b01/68747470733a2f2f7472617669732d63692e6f72672f6477796c2f657374612e7376673f6272616e63683d6d6173746572)
This repository contains a university project that me and two more people developed using a 8051 microcontroller. The project consists of a heatbed with controled temperature for a 3D Printer. This was developed under orientation of Professor Reinaldo Imbiriba from University of Fortaleza (UNIFOR).
# Why ?
The motive behind this project is that for the 3D Printer to properly work with a material called [ABS](https://en.wikipedia.org/wiki/Acrylonitrile_butadiene_styrene) (wich is different from the more common [PLA](https://en.wikipedia.org/wiki/Polylactic_acid)), it needs to have a heatbed as a base, since ABS has a high melting point and has the tendency to warp if cooled while printing. Thus, ABS needs to be printed on a heated bed which unfortunately is not easily available in most at-home printers. 
The final project is not only suitable for ABS but other materials since it permits a considerable high range of temperature. Other important aspect of the project is that it allows more general applications (not only for 3D Printers) that involves temperature control.
# How it works ?
The following materials have been used:
* [AT89S52](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Datasheets/AT89S52.pdf) microcontroller
* [LCD](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Datasheets/LCD16X2.pdf) 16x2
* [DS18B20](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Datasheets/DS18B20.pdf) temperature sensor
* [IRF540N](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Datasheets/IRF540N.pdf) MOSFET
* [L7805](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Datasheets/L7805.pdf) voltage regulator
* [EL817](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Datasheets/EL817.pdf) optocoupler
* MK3 heatbed
* 12V power supply

### Power supply
![Power Supply](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Images/power_supply.png?raw=true)

If you follow the circuitry above, you need to make sure that the 12V power supply can source enough current. On this case a current of approximately 8A was necessary for the MK3 heatbed. *VI* pin of L7805 regulator is connected on the poisitive terminal of the power supply and the capacitors are optional (if you use them make sure they are placed very close to the terminals and that they are ceramic). Negative terminal of power supply is connected to *GND* pin of 7805. The *VB* label is equivalent to *VO* wich is the output of the regulator with 5V responsible for supplying the microcontroller, the LCD, the temperature sensor and the optocoupler.

### Microcontroller
![Microcontroller](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Images/89s52.png?raw=true)

A 11.0592MHz crystal is recommended. Resistor *R1* is not necessary and capacitor *C1* can be changed to 10µF. *EA'* pin is connected to 5V of regulator as well as the capacitor *C1* and the *VCC* pin of the microcontroller. *P2* port is used to send data to LCD (*P2.0* is the LSB). *P1.0*, *P1.1* and *P1.2* pins are connected to *RS*, *RW* and *E* pins of LCD, respectively. *P1.5* is connected to a button and decrements the target temperature value in Celsius degrees. Similarly *P1.7* is connected to a button that increments the target temperature. *P3.0* is connected to data pin (*DQ* pin) of the temperature sensor. Finally *P3.7* is connected to optocoupler cathode (*K* pin).

### LCD
![LCD](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Images/lcd.png?raw=true)

*VSS* pin is connected to *GND* of 7805 regulator, *VDD* is connected to 5V, but since *VEE* asjust the contrast you will need to use a resistor or a potentiometer instead of just connecting it to *GND* of 7805 regulator. As written before *RS*, *RW* and *E* pins of LCD are connected to *P1.0*, *P1.1* and *P1.2* respectively. And *D0* to *D7* are connected to P2 port with *D0* and *P2.0* being the LSB.

### DS18B20

![DS18B20](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Images/ds18b20.png?raw=true)

This one can be a bit tricky if overlooked becuase you need to place it very tight in the MK3 heatbed (some thermal paste and thermal tape adhesive will be very useful) and at the same time need to place it relatively close to the microcontroller and power supply. The connections are simple: *VCC* pin goes to 5V, *DQ* pin is connected to a 4.7KΩ resistor (the resistor is connected to 5V) and *P3.0* pin. *GND* pin is connected to *GND* of 7805 regulator.

### Buttons

![Buttons](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Images/buttons.png?raw=true)

One thing that I noticed after soldering it on the perfboard was that they were interfering with the LCD (some kind of indutance effect), to counter this you can try using resistors in series with them. As written above the button connected to *P1.5* pin decrements the target temperature value in Celsius degrees and the button connected to *P1.7* increments the target temperature.

### Heatbed

![Heatbed](https://github.com/dojiDoMal/Heatbed_8051/blob/master/Images/heatbed.png?raw=true)

The label *VA* represents the positive terminal of the power supply. The key components here are the optocoupler and the MOSFET. Together they control the current flow on the heatbed. If you don't have a IRF540N or want to use another MOSFET, make sure to see the *VGS* value required for the drain current on the component datasheet and change *R6* AND *R4* (they are a voltage divider) based on it, you will also need to look for the *RDS* value, because the MOSFET will dissipate heat. The lower the *RDS* value the less heat will be dissipated, wich means that you will be allowed to use a smaller heatsink for it.
[Here's a picture showing how I soldered this circuitry.](https://bit.ly/31QxkhY)

### Heads-up

After burning the firmware .HEX file on the AT89S52 the circuitry can be assembled using a [perfboard](https://en.wikipedia.org/wiki/Perfboard) or a [veroboard](https://en.wikipedia.org/wiki/Veroboard) (I don't recommend using a breadboard since the current passing through the heatbed is __very high__ and therefore might melt the breadboard connections). It is also recommended that you use a 40 pin DIP socket when building to avoid soldering the AT89S52 directly for two mainly reasons: 
1. Avoid overheating the microcontroller.
2. Facilitate the handling and exchange of the microcontroller and it's firmware.

# Extra stuff






