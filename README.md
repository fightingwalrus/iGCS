![alt tag](https://raw.github.com/fightingwalrus/iGCS/master/iGCS/Icons/Icon-50.png) iDroneCtrl
====

iDroneCtrl (formally iGCS) is a UAV Ground Control Station for iPad and iPhone. 

It is intended for use with UAVs conforming to the MAVLink protocol, such as the [ArduPilot Mega](http://dev.ardupilot.com), the Pixhawk as used in the 3DR IRIS, IRIS+ and the AR.Drone 2.0 (with Flight Recorder).

It requires the "Made for iPhone" and "Made for iPad" iDroneLink available for sale at www.fightingwalrus.com

You can download iDroneCtrl from the App Store here:

[iDroneCtrl - Fighting Walrus](https://itunes.apple.com/us/app/idronectrl/id948077202?mt=8&uo=4)

For further details, see:

- http://www.fightingwalrus.com
- http://diydrones.com/profiles/blogs/ipad-ground-control-station
- http://www.youtube.com/watch?v=S1YOwLGsUrs

Screenshots
========
![Main View](https://raw.github.com/fightingwalrus/iGCS/master/screenshots/gcsview.png "Main View")
![Main View with sidebar](https://raw.github.com/fightingwalrus/iGCS/master/screenshots/gcsview-sidebar.png "Main View with sidebar")
![Mission Editor](https://raw.github.com/fightingwalrus/iGCS/master/screenshots/mission-edit.png "Mission Editor")

Building
========

1. clone the project
2. cd iGCS
3. ./scripts/updatedepends.sh

Updating the MAVLink library
============================

The MAVLink header only C lib used in iDroneCtrl is generated from a fork of the master branch of the [MAVLink](https://github.com/mavlink/mavlink) project hosted on github.

Fighting Walrus maintains a [fork](https://github.com/fightingwalrus/mavlink) of the MAVLink repository that tracks upstream. Please use the following steps in order to update the MAVLink lib used in iDroneCtrl.

1. Ensure the master branch of https://github.com/fightingwalrus/mavlink has all upstream changes from master merged in to master our master branch.
2. Clone https://github.com/fightingwalrus/mavlink
3. Navigate to the pymavlink/generator directory
4. Run the gen_all.sh script like this: `./gen_all.sh`
5. Navigate to pymavlink/generator/C/include_v1.0 (we support MAVLink 1.0 but not v.9)
6. Create a branch of the iGCS project 
7. Copy the follow folders and files into the iGCS folder named `mavlink_include`

Folders and files to copy:

- arupilotmega
- autoquad
- common
- matrixpilot
- pixhawk
- sensesoar
- checksum.h
- mavlink_conversations.h
- mavlink_helpers.h
- mavlink\_protobuf\_manager.hpp
- mavlink_types.h
- protocal.h

Commit and push your changes and open a pull request for review and further HIL testing. In the pull request please note the commit from the MAVLink repository that was used to generate the new MAVLink header files.

License
=======
All iDroneLink (formally iGCS) code is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
For other code and assets, see ATTRIBUTION.md.

The MIT License (MIT)
Copyright (c) 2013 Claudio Natoli et al

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
