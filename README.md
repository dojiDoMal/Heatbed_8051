# Heatbed with 8051 µC ![Build Status](https://camo.githubusercontent.com/cfcaf3a99103d61f387761e5fc445d9ba0203b01/68747470733a2f2f7472617669732d63692e6f72672f6477796c2f657374612e7376673f6272616e63683d6d6173746572)
This repository contains a university project that me and two more people developed using a 8051 microcontroller. The project consists of a heatbed with controled temperature for a 3D Printer. This was developed under orientation of Professor Reinaldo Imbiriba from University of Fortaleza (UNIFOR).
# Why ?
The motive behind this project is that for the 3D Printer to properly work with a material called [ABS](https://en.wikipedia.org/wiki/Acrylonitrile_butadiene_styrene) (wich is different from the more common [PLA](https://en.wikipedia.org/wiki/Polylactic_acid)), it needs to have a heatbed as a base, since ABS has a high melting point and has the tendency to warp if cooled while printing. Thus, ABS needs to be printed on a heated bed which unfortunately is not easily available in most at-home printers. 
The final project is not only suitable for ABS but other materials since it permits a considerable high range of temperature. Other important aspect of the project is that it allows more general applications (not only for 3D Printers) that involves temperature control.
# How it works ?
The following materials have been used:
* AT89S52 microcontroller
* LCD 16x2
* DS18B20 temperature sensor
* IRF540N MOSFET
* L7805 voltage regulator
* EL817 optocoupler
* MK3 heatbed
* 12V power supply

After burning the firmware .HEX file on the AT89S52 the circuitry can be assembled using a [perfboard](https://en.wikipedia.org/wiki/Perfboard) or a [veroboard](https://en.wikipedia.org/wiki/Veroboard) (I don't recommend using a breadboard since the current passing through the heatbed is __very high__ and therefore might melt the breadboard connections). It is also recommended that you use a 40 pin DIP socket when building to avoid soldering the AT89S52 directly for two mainly reasons: 
1. Avoid overheating the microcontroller.
2. Facilitate the handling and exchange of the microcontroller and it's firmware.


