![alt tag](https://raw.github.com/fightingwalrus/iGCS/master/iGCS/Icons/Icon-50.png) iGCS
====

iGCS is a UAV Ground Control Station for iPad. 

It is intended for use with UAVs conforming to the MAVLink protocol, such as the [ArduPilot Mega](http://dev.ardupilot.com), the Pixhawk as used in the 3DR Iris, and the AR.Drone 2.0 (with Flight Recorder).

At present, it requires the use of a RedPark Serial cable for connecting to serial device such as an XBee or XTend radio. Support for the Fighting Walrus Radio is under active development.

For further details, see:
- http://www.fightingwalrus.com
- http://diydrones.com/profiles/blogs/ipad-ground-control-station
- http://www.youtube.com/watch?v=S1YOwLGsUrs

Screenshots
========
![Main View](https://raw.github.com/fightingwalrus/iGCS/freshen-readme/screenshots/gcsview.png "Main View")
![Main View with sidebar](https://raw.github.com/fightingwalrus/iGCS/freshen-readme/screenshots/gcsview-sidebar.png "Main View with sidebar")
![Mission Editor](https://raw.github.com/fightingwalrus/iGCS/freshen-readme/screenshots/mission-edit.png "Mission Editor")

Building
========

Recent additions to the project include the kxvideo submodule. kxvideo in turn relies on ffmpeg and the gas preprocessor. Both are included as submodules to the kxvideo project so the build steps are a bit more involved now.

1. clone the project
2. cd iGCS
3. git submodule update --init --recursive
4. cd submodules/kxmovie
5. rake build_ffmpeg
(The first time you will be warned to install the gas preprocessor, follow the instructions provided)
8. Run the iCGS project in Xcode

*Note: building ffmpeg as outlined above no longer works with Xcode 5. Please use the main iGCS target 
for now as the kxmovie/ffmpeg dependencies have been temporarily moved to the iGCS-video-streaming target.*


Updating the MAVLink library
============================

The MAVLink header only C lib used in iGCS is generated from a fork of the master branch of the [MAVLink](https://github.com/mavlink/mavlink) project hosted on github.

Fighting Walrus maintains a [fork](https://github.com/fightingwalrus/mavlink) of the MAVLink repository that tracks upstream. Please use the following steps in order to update the MAVLink lib used in iGCS.

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
All iGCS code is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
For other code and assets, see ATTRIBUTION.md.

The MIT License (MIT)
Copyright (c) 2013 Claudio Natoli et al

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
