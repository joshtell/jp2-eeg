# OpenBCI Widget: JP2-EEG
JP2-EEG widget for OpenBCI: A compression codec and corresponding browser (in development) for EEG data recorded in OpenBCI GUI.

## Installation and Usage
1. Drag W_JP2.pde file into OpenBCI sketch folder. 
2. Unzip processing_libraries.zip and drag contents into Processing libraries folder. 
3. Edit OpenBCI_GUI.pde file and add the following lines in library imports:
```
import java.awt.image.*;
import java.awt.Color;
import javax.imageio.*;
import javax.imageio.spi.*;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;
import com.github.jaiimageio.jpeg2000.*;
import com.github.jaiimageio.jpeg2000.impl.*;
import com.github.jaiimageio.impl.common.*;
```
4. Edit Interactivity.pde and add the following lines in keyPressed():
```
w_JP2.checkTextLimit(); // Check if active textfield exceeds character limit
w_JP2.checkTextLimit(); // Call twice for some reason
if (keyCode == 9) { w_JP2.tabOver(); } // Tab to next textfield
```
5. Edit WidgetManager.pde and declare widget globally.
  - Add at the top to declare class instance:
```
W_JP2 w_JP2;
```
  - Add to setupWidgets():
```
w_JP2 = new W_JP2(_this);
w_JP2.setTitle("JP2-EEG");
addWidget(w_JP2, w);
```
6. Compile OpenBCI_GUI.pde and open the JP2-EEG widget in the desired window within OpenBCI GUI.

## Notes on Compatibility
I developed this widget using OpenBCI_GUI version 5.1.0 and Processing version 4.0b2 (which employs JDK version 11.0.12+7).
The Java libraries used for image processing are [JAI ImageIO Core version 1.4.0](https://github.com/jai-imageio/jai-imageio-core) and [JAI ImageIO JPEG2000 version 1.4.0](https://github.com/jai-imageio/jai-imageio-jpeg2000).
If any issues arise, they are likely due to differences in versions of any subset of software distributions.
