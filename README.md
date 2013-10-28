iGCS
====
iGCS is a UAV Ground Control Station for iPad. 

It is intended for use with UAVs conforming to the MAVLink protocol, such as the [ArduPilot Mega](http://code.google.com/p/ardupilot-mega/).

Currently, it requires the use of a RedPark Serial cable for connecting to serial device such as an XBee or XTend radio.

For further details, see:
- http://diydrones.com/profiles/blogs/ipad-ground-control-station
- http://www.youtube.com/watch?v=S1YOwLGsUrs

=======
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

License
=======
All iGCS code is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
For other code and assets, see ATTRIBUTION.md.

The MIT License (MIT)
Copyright (c) 2013 Claudio Natoli et al

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
