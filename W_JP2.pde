// JP2-EEG OpenBCI widget
// Written by: Joshua Tellez
// Faculty advisor: Dr. Charles D. Creusere
// New Mexico State University
// Published 5/23/23
// Version 0.1

class W_JP2 extends Widget {
    private float xF, yF, wF, hF;
    private float jp_pad = 10.0;
    private float pb_x, pb_y, pb_h, pb_w;
    private int   pb_xp, pb_yp, pb_sh, pb_sw;
    private float plotBottomWell = 45.0;
    private float playbackWidgetHeight = 50.0;
    private float tf_pad = 70; // Textfield padding
    private float tf_y;   // Textfield height
    String[] tfNames = {"tImm", "tIss", "tIms", "tOmm", "tOss", "tOms"};
    String[] tfDefault = {"00", "00", "00", "00", "00", "00"};
    int[] tf_poss;
    Textfield[] tfs; // Array for textfields

    // JPEG 2000 stuff
    Button selectJP2FileButton;
    Button convertToJP2FileButton;
    private int imgW; // Original width
    private int imgH; // Original height
    private int aW;   // Fit to window width
    private int aH;   // Fit to window height
    private float img_aspect; // Aspect ratio
    private int img_v_buffer = 100;

    // CP5 Objects
    private ControlP5 jpcp5;
    private ImgScrubBar scrollbar;

    // Flags
    private boolean isImgLoaded = false;
    private boolean allowSpillover = false;
    private boolean hasScrollbar = true;

    List<controlP5.Controller> cp5ElementsToCheck = new ArrayList<controlP5.Controller>();

    W_JP2(PApplet _parent) {
        // Calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
        super(_parent);
        jpcp5 = new ControlP5(_parent);
        jpcp5.setGraphics(_parent, 0,0);
        jpcp5.setAutoDraw(false);
        calculate_constants(); // Pixel spacing arguments for UI
        initialize_UI(); // Create interface elements
    }

// }

    void update() {
        super.update(); // Calls the parent update() method of Widget (DON'T REMOVE)
        scrollbar.update(); // Update Playback scrollbar
        lockElementsOnOverlapCheck(cp5ElementsToCheck);
    }

    void draw() {
        super.draw(); // Calls the parent draw() method of Widget (DON'T REMOVE)
        scrollbar.draw();
        jpcp5.draw();
    }

    void calculate_constants() {
        // Float-converted widget window values
        xF = float(x);
        yF = float(y);
        wF = float(w);
        hF = float(h);
        // Scrub bar position values
        pb_x = xF + jp_pad;
        pb_y = yF + hF - plotBottomWell + (jp_pad * 2);
        pb_w = wF - jp_pad*2;
        pb_h = playbackWidgetHeight/2;
        pb_xp = floor(xF) - 1;
        pb_yp = int(yF + hF - plotBottomWell - jp_pad + 5);
        pb_sw = int(wF) + 1;
        pb_sh = int(playbackWidgetHeight);
        // Textfield positions values
        tf_poss = new int[6];
        tf_poss[0] = int(x+jp_pad);
        tf_poss[1] = int(x+tf_pad+jp_pad);
        tf_poss[2] = int(x+tf_pad*2+jp_pad);
        tf_poss[3] = int(x+w-tf_pad*3);
        tf_poss[4] = int(x+w-tf_pad*2);
        tf_poss[5] = int(x+w-tf_pad);
        tf_y = pb_y - tf_pad;
    }

    void initialize_UI() {
        // Declare and initialize image loading button
        createSelectJP2FileButton("selectJP2File_Session", "Select JP2 File", int(x + w/2 - (jp_pad*2)), y - navHeight + 2, 100, navHeight - 6);
        createConvertToJP2FileButton("convertToJP2File_Session", "Convert TXT File", int(x + w/2 - (jp_pad*4)), y - navHeight + 2, 100, navHeight - 6);
        // Instantiate scrollbar if using playback mode and scrollbar feature in use
        initialize_scrubbar();
        tfs = new Textfield[tfNames.length];
        // Declare time input/output textfields
        for (int i = 0; i < tfNames.length; i++) {
            tfs[i] = jpcp5.addTextfield(tfNames[i]);
        }
        setupTextFields();
        // Declare initial positions
        for (int i = 0; i < tfs.length; i++) {
            tfs[i].setVisible(true)
                  .setPosition(tf_poss[i], tf_y)
                  .setText(tfDefault[i]);
        }
    }

    void initialize_scrubbar() {
        // Make a new scrollbar
        scrollbar = new ImgScrubBar(pb_xp, pb_yp, pb_sw, pb_sh, int(pb_x), int(pb_y), int(pb_w), int(pb_h));
    }

    void screenResized() {
        super.screenResized(); // Calls the parent screenResized() method of Widget (DON'T REMOVE)
        calculate_constants();
        // Image loading button in navBar
        selectJP2FileButton.setPosition(x + w - selectJP2FileButton.getWidth() - 2, y - navHeight + 2);
        // Image conversion button in navBar
        convertToJP2FileButton.setPosition(x + w - convertToJP2FileButton.getWidth() - 102, y - navHeight + 2);
        scrollbar.screenResized(pb_xp, pb_yp, pb_sw, pb_sh, int(pb_x), int(pb_y), int(pb_w), int(pb_h));
        for (int i = 0; i < tfs.length; i++) {
            tfs[i].setPosition(tf_poss[i], tf_y);
        }
    }

    void mousePressed() {
        super.mousePressed(); // Calls the parent mousePressed() method of Widget (DON'T REMOVE)
    }

    void mouseReleased() {
        super.mouseReleased(); // Calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }

    void checkTextLimit() {
        int activeIdx = 0;
        for (int i = 0; i < tfs.length; i++) {
            if (tfs[i].isFocus()) {
                activeIdx = i;
                break;
            }
        }
        String textString = tfs[activeIdx].getText();
        if (textString.length() >= 2) {
            tfs[activeIdx].setText(textString.substring(0, 2));
        }
    }

    void tabOver() {
        int activeIdx = 0;
        int newActiveIdx = 0;
        for (int i = 0; i < tfs.length; i++) {
            if (tfs[i].isFocus()) {
                activeIdx = i;
                newActiveIdx = i+1;
                break;
            }
        }
        if (newActiveIdx >= tfNames.length) {
            newActiveIdx = 0;
        }
        tfs[activeIdx].setFocus(false);
        tfs[newActiveIdx].setFocus(true);
    }

    private void createSelectJP2FileButton(String name, String text, int _x, int _y, int _w, int _h) {
        // Creates button in navBar that allows for JP2 image loading
        selectJP2FileButton = createButton(jpcp5, name, text, _x, _y, _w, _h);
        selectJP2FileButton.setBorderColor(OBJECT_BORDER_GREY);
        selectJP2FileButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Select a file for viewing");
                selectInput("Select an encoded JP2 file for viewing:", "loadJP2File");
            }
        });
        selectJP2FileButton.setDescription("Click to open a dialog box to select a JP2 file.");
        cp5ElementsToCheck.add(selectJP2FileButton);
    }

    private void createConvertToJP2FileButton(String name, String text, int _x, int _y, int _w, int _h) {
        // Creates button in navBar that allows for JP2 image conversion
        convertToJP2FileButton = createButton(jpcp5, name, text, _x, _y, _w, _h);
        convertToJP2FileButton.setBorderColor(OBJECT_BORDER_GREY);
        convertToJP2FileButton.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                output("Select a file for converting");
                selectInput("Select a TXT file for viewing:", "convertToJP2File");
            }
        });
        convertToJP2FileButton.setDescription("Click to open a dialog box to select a TXT file.");
        cp5ElementsToCheck.add(convertToJP2FileButton);
    }

    void setupTextFields() {
        for (int i = 0; i < tfs.length; i++) {
            tfs[i].align(10,100,10,100)                 // Alignment
                .setSize(60,20)                         // Size of textfield
                .setFont(f2)
                .setFocus(false)                        // Deselects textfield
                .setColor(OPENBCI_DARKBLUE)
                .setColorBackground(color(255,255,255)) // text field bg color
                .setColorValueLabel(OPENBCI_DARKBLUE)   // text color
                .setColorForeground(OPENBCI_DARKBLUE)   // border color when not selected
                .setColorActive(isSelected_color)       // border color when selected
                .setColorCursor(OPENBCI_DARKBLUE)
                .setCaptionLabel("")                    // Remove caption label
                .setVisible(false)                      // Initially hidden
                .setAutoClear(true)                     // Autoclear
                .setInputFilter(ControlP5.INTEGER)
                ;
        }
    }

    // Identifies channel count, sample rate, board type, etc., and returns array of values.
    private double[] parseHeader(String[] lines) {
        String underlyingClassName = "";
        double sampleCount = -1;
        double sampleRate = -1;
        double chanCount = -1;
        double min_val = -1;
        double max_val = -1;

        for (String line : lines) {
            if (!line.startsWith("%")) {
                break; // reached end of header
            }
            //only needed for synthetic board. can delete if we get rid of synthetic board.
            if (line.startsWith("%Number of channels")) {
                int startIndex = line.indexOf('=') + 2;
                String nchanStr = line.substring(startIndex);
                chanCount = (double) Integer.parseInt(nchanStr);
            }
            // some boards have configurable sample rate, so read it from header
            if (line.startsWith("%Sample Rate")) {
                int startIndex = line.indexOf('=') + 2;
                int endIndex = line.indexOf("Hz") - 1;
                String hzString = line.substring(startIndex, endIndex);
                sampleRate = (double) Integer.parseInt(hzString);
            }
            // used to figure out the underlying board type
            if (line.startsWith("%Board")) {
                int startIndex = line.indexOf('=') + 2;
                underlyingClassName = line.substring(startIndex);
            }
            // used to parse the minimum EXG value
            if (line.startsWith("%Min")) {
                int startIndex = line.indexOf('=') + 2;
                String minValStr = line.substring(startIndex);
                min_val = Double.parseDouble(minValStr);
            }
            // used to parse the maximum EXG value
            if (line.startsWith("%Max")) {
                int startIndex = line.indexOf('=') + 2;
                String maxValStr = line.substring(startIndex);
                max_val = Double.parseDouble(maxValStr);
            }
            if (line.startsWith("%# Samples")) {
                int startIndex = line.indexOf('=') + 2;
                String numSamplesStr = line.substring(startIndex);
                sampleCount = (double) Integer.parseInt(numSamplesStr);
            }
        }
        boolean success = sampleRate > 0 && underlyingClassName != "";
        if(!success) {
            outputError("Playback file does not contain the required header data.");
        }
        // Diagnostic printout
        // println("parseHeader: Board       =", underlyingClassName);
        // println("parseHeader: Sample rate =", sampleRate);
        // println("parseHeader: # Channels  =", chanCount);
        // println("parseHeader: # Samples   =", sampleCount);
        // println("parseHeader: Min value   =", min_val);
        // println("parseHeader: Max value   =", max_val);

        double[] header_data = new double[5];
        header_data[0] = chanCount;
        header_data[1] = sampleRate;
        header_data[2] = sampleCount;
        header_data[3] = min_val;
        header_data[4] = max_val;

        return header_data;
    }

    // Turns text data into array list of double arrays, and returns array list of double arrays.
    private ArrayList<double[]> parseData(String[] lines, int chanCount) {
        int dataStart;
        int numChannels = 0;
        ArrayList<double[]> rawData;
        // set data start to first line of data (skip header)
        for (dataStart = 0; dataStart < lines.length; dataStart++) {
            String line = lines[dataStart];
            if (!line.startsWith("%")) {
                dataStart++; // skip column names
                break;
            }
        }
        int dataLength = lines.length - dataStart;
        rawData = new ArrayList<double[]>(dataLength);
        for (int iData=0; iData<dataLength; iData++) {
            String line = lines[dataStart + iData];
            String[] valStrs = line.split(",");
            double[] row = new double[chanCount];
            for (int iCol = 0; iCol < chanCount; iCol++) {
                row[iCol] = Double.parseDouble(valStrs[iCol+1]);
            }
            rawData.add(row);
        }
        // Diagnostic printout
        // println("parseData: # Samples =", rawData.size());
        // println("rawData[0][0]       = " + rawData.get(0)[0]);
        return rawData;
    }

    // Read EEG image and text information, convert back to format...
    //  readable by OpenBCI, load text data, and extract header info.
    private void processImgData(String img_file_path) throws IOException {
        int img_file_ext_idx = img_file_path.lastIndexOf(".");
        String txt_file_path = img_file_path.substring(0, img_file_ext_idx).concat("_JP2.txt");
        String[] txt_lines = loadStrings(txt_file_path);
        double[] header_data = parseHeader(txt_lines);
        // Declare data blocking parameters
        int chan_count = (int) header_data[0];
        int num_blocks = (int) imgW / chan_count;
        int block_size = 1024;
        // Declare target file
        File f = new File(img_file_path);
        J2KImageReadParam param = new J2KImageReadParam();
        // Get the JPEG 2000 reader
        Iterator<ImageReader> readerIterator = ImageIO.getImageReadersByFormatName("JPEG 2000");
        J2KImageReader jp2kreader = null;
        jp2kreader = (J2KImageReader) readerIterator.next();
        // Read the jp2 file
        ImageInputStream iis = ImageIO.createImageInputStream(f);
        jp2kreader.setInput(iis);
        BufferedImage selectedImage = jp2kreader.read(0, param);
        // Pulls dimension sizes from image on load
        imgW = selectedImage.getWidth();
        imgH = selectedImage.getHeight();
        ImageTypeSpecifier imageType = jp2kreader.getRawImageType(0);
        // Diagnostic printout
        // println("processImgData: " + imageType.getColorModel());
        // Declare EEG data matrices
        int[][] int_img_data = new int[imgH][imgW];
        int[][] int_eeg_img = new int[imgH][imgW];
        for (int y=0; y < imgW; y++) {
            for (int x=0; x < imgH; x++) {
                int_img_data[x][y] = selectedImage.getRGB(y,x);
                int a = (int_img_data[x][y]>>24)&0xff;
                int b = (int_img_data[x][y]>>16)&0xff;
                int g = (int_img_data[x][y]>>8) &0xff;
                int r =  int_img_data[x][y]     &0xff;
                int_eeg_img[x][y] = (b << 24) | (g << 16) | (r << 8) | a;
                // Diagnostic printout
                // if (y==0 && x==0) {
                //     println("processImgData: A channel: " + a);
                //     println("processImgData: R channel: " + r);
                //     println("processImgData: G channel: " + g);
                //     println("processImgData: B channel: " + b);
                //     println("processImgData: int_img_data[0][0]: " + int_img_data[x][y]);
                //     println("processImgData: int_eeg_img[0][0]: " + int_eeg_img[x][y]);
                // }
            }
        }
        double[][] rc_eeg_img = new double[imgH][imgW];
        double min_val = header_data[3];
        double max_val = header_data[4];
        for (int y=0; y < imgW; y++) {
            for (int x=0; x < imgH; x++) {
                rc_eeg_img[x][y] = (int_eeg_img[x][y] / (Math.pow(2,31)-1)) * (max_val - min_val) + min_val;
                // Diagnostic printout
                // if (y==0 && x==0) {
                //     println("processImgData: rc_eeg_img[0][0]: " + rc_eeg_img[x][y]);
                // }
            }
        }
        // Pass data along to reconstruct txt file
        reconstructTextData(img_file_path, header_data, rc_eeg_img);
    }

    // Uses EEG image file and modified txt file data to reconstruct OpenBCI compatible txt file.
    private void reconstructTextData(String img_file_path, double[] header_data, double[][] rc_eeg_img) {
        int file_ext_idx = img_file_path.lastIndexOf(".");
        String txt_file_path = img_file_path.substring(0, file_ext_idx).concat("_JP2.txt");
        String new_txt_file_path = img_file_path.substring(0, file_ext_idx).concat("_rc.txt");
        String[] lines = loadStrings(txt_file_path);
        ArrayList<Integer> nullIdxs = new ArrayList<Integer>();
        int block_size = 1024;
        int chanCount = (int) header_data[0];
        int sampleRate = (int) header_data[1];
        int sampleCount = (int) header_data[2];
        int num_blocks = (int) Math.ceil(sampleCount / (float) block_size);
        // Diagnostic printout
        // println("reconstructTextData: chanCount   = " + chanCount);
        // println("reconstructTextData: sampleRate  = " + sampleRate);
        // println("reconstructTextData: sampleCount = " + sampleCount);
        // println("reconstructTextData: num_blocks  = " + num_blocks);
        // reconstruct time series matrix
        int sampleIdx = 0; // counter
        double[][] rc_eeg_data = new double[chanCount][sampleCount];
        for (int i=0; i<num_blocks; i++) {
            if (i%2 == 0) {
                for (int j=0; j<block_size; j++) {
                    if (sampleIdx < sampleCount) {
                        for (int k = 0; k < chanCount; k++) {
                            rc_eeg_data[k][sampleIdx] = rc_eeg_img[j][(i*chanCount)+k];
                        }
                    } sampleIdx++;
                }
            } else {
                for (int j=block_size-1; j>=0; j--) {
                    if (sampleIdx < sampleCount) {
                        for (int k = 0; k < chanCount; k++) {
                            rc_eeg_data[k][sampleIdx] = rc_eeg_img[j][(i*chanCount)+k];
                        }
                    } sampleIdx++;
                }
            }
        }
        try {
            PrintWriter out = new PrintWriter(new_txt_file_path);
            // set data start to first line of data (skip header)
            int dataStart;
            for (dataStart = 0; dataStart < lines.length; dataStart++) {
                String line = lines[dataStart];
                // Print column names after other header data
                if (!line.startsWith("%")) {
                    StringBuilder newLine = new StringBuilder();
                    String[] valStrs = line.split(",");
                    for (int col=0; col<valStrs.length + chanCount; col++) {
                        if (col==0) { newLine.append(valStrs[col] + ", "); } // Sample index
                        // EEG channel labels
                        else if (col<=chanCount)  { newLine.append("EXG Channel " + (col-1) + ", "); }
                        else { // Rest of column names
                            newLine.append(valStrs[col - chanCount]);
                            if (col<valStrs.length+chanCount-1) { newLine.append(","); }
                        }
                    }
                    out.println(newLine.toString());
                    dataStart++; // Skip column names
                    break;
                }
                else { // Print header data
                    out.println(line);
                }
            }
            int dataLength = lines.length - dataStart;
            for (int iData=0; iData<dataLength; iData++) {
                StringBuilder newLine = new StringBuilder();
                String line = lines[dataStart + iData];
                String[] valStrs = line.split(",");
                for (int col=0; col<valStrs.length + chanCount; col++) {
                    if (col==0) { newLine.append(valStrs[col] + ", "); } // Sample index
                    // EEG channel data
                    else if (col<=chanCount)  {
                        newLine.append(rc_eeg_data[col-1][iData] + ", ");
                    }
                    else { // Rest of column names
                        newLine.append(valStrs[col - chanCount]);
                        if (col<valStrs.length+chanCount-1) { newLine.append(","); }
                    }
                }
                out.println(newLine.toString());
            }
            out.flush();
            out.close();
        }
        catch(IOException ie) { ie.printStackTrace(); }
    }

    // Creates modified txt file that does not contain EEG data to...
    //  supplement the EEG image file with ancillary data.
    private void processTextData(String txt_file_path, int chanCount, int sampleCount, double[] min_max_vals) {
        int txt_file_ext_idx = txt_file_path.lastIndexOf(".");
        String txt_file_ext = txt_file_path.substring(txt_file_ext_idx + 1);
        String new_txt_file_path = txt_file_path.substring(0, txt_file_ext_idx).concat("_JP2.").concat(txt_file_ext);
        String[] lines = loadStrings(txt_file_path);
        ArrayList<Integer> nullIdxs = new ArrayList<Integer>();
        try {
            PrintWriter out = new PrintWriter(new_txt_file_path);
            // set data start to first line of data (skip header)
            int dataStart;
            for (dataStart = 0; dataStart < lines.length; dataStart++) {
                String line = lines[dataStart];
                // Print column names after other header data
                if (!line.startsWith("%")) {
                    out.println("%Min EXG Value (uV) = " + min_max_vals[0]);
                    out.println("%Max EXG Value (uV) = " + min_max_vals[1]);
                    out.println("%# Samples = " + sampleCount);
                    // dataStart += 2; // Offset starting index for 2 extra printed lines
                    StringBuilder newLine = new StringBuilder();
                    String[] valStrs = line.split(",");
                    for (int col=0; col<valStrs.length; col++) {
                        if (valStrs[col].contains("EXG")) {
                            // Don't print these
                            nullIdxs.add(col);
                        } else {
                            newLine.append(valStrs[col]);
                            if (col<valStrs.length-1) { newLine.append(","); }
                        }
                    }
                    out.println(newLine.toString());
                    dataStart++; // Skip column names
                    break;
                } else { out.println(line); } // Print header data
            }
            int dataLength = lines.length - dataStart;
            for (int iData=0; iData<dataLength; iData++) {
                StringBuilder newLine = new StringBuilder();
                String line = lines[dataStart + iData];
                String[] valStrs = line.split(",");
                for (int col=0; col<valStrs.length; col++) {
                    if (nullIdxs.contains(col)) { /* Don't print these */ }
                    else {
                        newLine.append(valStrs[col]);
                        if (col<valStrs.length-1) { newLine.append(","); }
                    }
                }
                out.println(newLine.toString());
            }
            out.flush();
            out.close();
        }
        catch(IOException ie) { ie.printStackTrace(); }
    }

    // Normalizes data to 0-1 range, then casts to 32-bit integer.
    private ArrayList<double[]> normalizeData(ArrayList<double[]> rawData, double[] min_max_vals) {
        double min_val = min_max_vals[0];
        double max_val = min_max_vals[1];
        ArrayList<double[]> normData = new ArrayList<double[]>(rawData.size());
        for (int iData=0; iData<rawData.size(); iData++) {
            double[] row = rawData.get(iData);
            for (int iCol = 0; iCol < row.length; iCol++) {
                row[iCol] = (row[iCol] - min_val) / (max_val - min_val);
            }
            normData.add(row);
        }
        // Diagnostic printout
        // println("Minimum value: " + min_val);
        // println("Maximum value: " + max_val);
        // println("normData[0][0]      = " + normData.get(0)[0]);
        return normData;
    }

    // Arranges EEG data from txt file into an array, then writes the array data to a JP2 image file.
    private void formatImage(ArrayList<double[]> normData, String txt_file_path) throws IOException {
        // Calculate dimensions for image
        int signal_length = normData.size();
        int chan_count = normData.get(0).length;
        int block_size = 1024;
        int num_blocks = (int)Math.ceil(signal_length / (float) block_size);
        int img_width = num_blocks * chan_count;
        // Declare image array
        double[][] blkAltData = new double[img_width][block_size];
        int sampleIdx = 0; // Declare sample counter
        for (int i=0; i<num_blocks; i++) {
            if (i%2 == 0) {
                for (int j=0; j<block_size; j++) {
                    if (sampleIdx < signal_length) {
                        double[] row = normData.get(sampleIdx);
                        for (int k = 0; k < chan_count; k++) {
                            blkAltData[(i*chan_count)+k][j] = row[k];
                        }
                    } sampleIdx++;
                }
            } else {
                for (int j=block_size-1; j>=0; j--) {
                    if (sampleIdx < signal_length) {
                        double[] row = normData.get(sampleIdx);
                        for (int k = 0; k < chan_count; k++) {
                            blkAltData[(i*chan_count)+k][j] = row[k];
                        }
                    } sampleIdx++;
                }
            }
        }
        int[][] blkAltIntData = new int[img_width][block_size];
        for (int i=0; i<img_width; i++) {
            for (int j=0; j<block_size; j++) {
                blkAltIntData[i][j] = Math.toIntExact(Math.round(blkAltData[i][j] * (Math.pow(2,31)-1)));
            }
        }
        // Diagnostic printout
        // println("blkAltData[0][0]    = " + blkAltData[0][0]);
        // println("blkAltIntData[0][0] = " + blkAltIntData[0][0]);
        // Declare file formats
        String ogFileType = "txt";
        String newFileType = "jp2";
        String outImgPath = txt_file_path.replace(ogFileType, newFileType);
        println("formatImage: Saving image to:");
        println(outImgPath);
        BufferedImage outputImage = new BufferedImage(img_width, block_size, BufferedImage.TYPE_4BYTE_ABGR);
        WritableRaster raster = outputImage.getRaster();
        for (int y=0; y < block_size; y++) {
            for (int x=0; x < img_width; x++) {
                // Convert integer value to 4-byte array
                byte[] bytes = ByteBuffer.allocate(4).putInt(blkAltIntData[x][y]).array();
                // Convert each byte to uint8 value
                int chanA = bytes[0] & 0xFF;
                int chanR = bytes[1] & 0xFF;
                int chanG = bytes[2] & 0xFF;
                int chanB = bytes[3] & 0xFF;
                // Diagnostic printout
                // if (y==0 && x==0) {
                //     String s1 = String.format("%8s", Integer.toBinaryString(bytes[0] & 0xFF)).replace(' ', '0');
                //     String s2 = String.format("%8s", Integer.toBinaryString(bytes[1] & 0xFF)).replace(' ', '0');
                //     String s3 = String.format("%8s", Integer.toBinaryString(bytes[2] & 0xFF)).replace(' ', '0');
                //     String s4 = String.format("%8s", Integer.toBinaryString(bytes[3] & 0xFF)).replace(' ', '0');
                //     println("Byte 1: " + s1);
                //     println("uint 1: " + chanA);
                //     println("Byte 2: " + s2);
                //     println("uint 2: " + chanR);
                //     println("Byte 3: " + s3);
                //     println("uint 3: " + chanG);
                //     println("Byte 4: " + s4);
                //     println("uint 4: " + chanB);
                // }
                // Allocate each uint8 value to respective image channel
                raster.setSample(x, y, 0, chanA); // A channel
                raster.setSample(x, y, 1, chanR); // R channel
                raster.setSample(x, y, 2, chanG); // G channel
                raster.setSample(x, y, 3, chanB); // B channel
            }
        }
        // Declare target file
        File f = new File(outImgPath);
        J2KImageWriteParam param = new J2KImageWriteParam();
        // Get the JPEG 2000 writer
        Iterator<ImageWriter> writerIterator = ImageIO.getImageWritersByFormatName("JPEG 2000");
        J2KImageWriter jp2kwriter = null;
        jp2kwriter = (J2KImageWriter) writerIterator.next();
        // Write the jp2 file
        ImageOutputStream ios = ImageIO.createImageOutputStream(f);
        jp2kwriter.setOutput(ios);
        jp2kwriter.write(null, new IIOImage(raster, null, null), param);
    }

    // Finds minimum and maximum values of array list.
    private double[] findMinMax(ArrayList<double[]> rawData) {
        double inf = Double.POSITIVE_INFINITY;
        double neg_inf = Double.NEGATIVE_INFINITY;
        double max_val = neg_inf;
        double min_val = inf;
        for (int iData=0; iData<rawData.size(); iData++) {
            double[] row = rawData.get(iData);
            for (int iCol = 0; iCol < row.length; iCol++) {
                if (row[iCol] > max_val) { max_val = row[iCol]; }
                if (row[iCol] < min_val) { min_val = row[iCol]; }
            }
        }
        return new double[] { min_val, max_val };
    }
};

// Loads EEG image file and converts back to OpenBCI compatible txt data.
public void loadJP2File(File selection) {
    String img_file_path = selection.getAbsolutePath();
    if (selection == null) {
        println("loadJP2File: Window was closed or the user hit cancel.");
    } else {
        println("loadJP2File: User selected " + img_file_path);
        println("loadJP2File: Loading image...");
        // Get file extension to make sure we can load the file
        int img_file_ext_idx = img_file_path.lastIndexOf(".");
        String img_file_ext = img_file_path.substring(img_file_ext_idx + 1);
        if (!(img_file_ext.contains("jp2"))) {
            w_JP2.isImgLoaded = false;
            println("loadJP2File: Image not valid.");
        } else {
            try { w_JP2.processImgData(img_file_path); }
            catch(IOException ie) { ie.printStackTrace(); }
            w_JP2.isImgLoaded = true;
            println("loadJP2File: Loaded image successfully.");
        }
    }
}

// Reads in OpenBCI compatible txt file and converts EEG channel data to JP2 image.
public void convertToJP2File(File selection) {
    String txt_file_path = selection.getAbsolutePath();
    if (selection == null) {
        println("convertToJP2File: Window was closed or the user hit cancel.");
    } else {
        println("convertToJP2File: User selected " + selection.getName());
        // Get file extension to make sure we can load the file
        int txt_file_ext_idx = txt_file_path.lastIndexOf(".");
        String txt_file_ext = txt_file_path.substring(txt_file_ext_idx + 1);
        if (!(txt_file_ext.contains("txt"))) {
            println("convertToJP2File: File not valid.");
        } else {
            String[] txt_lines = loadStrings(txt_file_path);
            double[] header_data = w_JP2.parseHeader(txt_lines);
            int chanCount = (int) header_data[0];
            if (chanCount > 0) {
                println("convertToJP2File: Loaded file successfully. Processing...");
                ArrayList<double[]> rawData = w_JP2.parseData(txt_lines, chanCount);
                int sampleCount = rawData.size();
                double min_max_vals[] = w_JP2.findMinMax(rawData);
                ArrayList<double[]> normData = w_JP2.normalizeData(rawData, min_max_vals);
                try {
                    w_JP2.formatImage(normData, txt_file_path);
                    w_JP2.processTextData(txt_file_path, chanCount, sampleCount, min_max_vals);
                }
                catch(IOException ie) { ie.printStackTrace(); }
                println("convertToJP2File: Processing complete.");
            }
            else { println("convertToJP2File: Load failed."); }
        }
    }
}

//========================== Image Scrub Bar ==========================
// This is copied from the time series widget with the class renamed.
// It doesn't provide unique functionality for this widget currently.
class ImgScrubBar {
    private int x, y, w, h;
    private int swidth, sheight;    // width and height of bar
    private float xpos, ypos;       // x and y position of bar
    private float spos;             // x position of slider
    private float sposMin, sposMax; // max and min values of slider
    private boolean over;           // is the mouse over the slider?
    private boolean locked;
    private ControlP5 pbsb_cp5;
    private String currentAbsoluteTimeToDisplay = "";
    private String currentTimeInSecondsToDisplay = "";
    private FileBoard fileBoard;

    private final DateFormat currentTimeFormatShort = new SimpleDateFormat("mm:ss");
    private final DateFormat currentTimeFormatLong = new SimpleDateFormat("HH:mm:ss");
    private final DateFormat timeStampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    ImgScrubBar (int _x, int _y, int _w, int _h, float xp, float yp, int sw, int sh) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        swidth = sw;
        sheight = sh;

        xpos = xp;
        ypos = yp-sheight/2;
        spos = xpos;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;

        pbsb_cp5 = new ControlP5(ourApplet);
        pbsb_cp5.setGraphics(ourApplet, 0,0);
        pbsb_cp5.setAutoDraw(false);

        fileBoard = (FileBoard)currentBoard;
    }

    /////////////// Update loop for ImgScrubBar
    void update() {
        checkMouseOver(); // check if mouse is over

        if (mousePressed && over) {
            locked = true;
        }
        if (!mousePressed) {
            locked = false;
        }
        //if the slider is being used, update new position based on user mouseX
        if (locked) {
            spos = constrain(mouseX-sheight/2, sposMin, sposMax);
            scrubToPosition();
        }
        else {
            updateCursor();
        }

        // update timestamp
        currentAbsoluteTimeToDisplay = getAbsoluteTimeToDisplay();

        //update elapsed time to display
        currentTimeInSecondsToDisplay = getCurrentTimeToDisplaySeconds();

    } //end update loop for ImgScrubBar

    void updateCursor() {
        float currentSample = float(fileBoard.getCurrentSample());
        float totalSamples = float(fileBoard.getTotalSamples());
        float currentPlaybackPos = currentSample / totalSamples;

        spos =  lerp(sposMin, sposMax, currentPlaybackPos);
    }

    void scrubToPosition() {
        int totalSamples = fileBoard.getTotalSamples();
        int newSamplePos = floor(totalSamples * getCursorPercentage());

        fileBoard.goToIndex(newSamplePos);
    }

    float getCursorPercentage() {
        return (spos - sposMin) / (sposMax - sposMin);
    }

    String getAbsoluteTimeToDisplay() {
        List<double[]> currentData = currentBoard.getData(1);
        int timeStampChan = currentBoard.getTimestampChannel();
        long timestampMS = (long)(currentData.get(0)[timeStampChan] * 1000.0);
        if(timestampMS == 0) {
            return "";
        }

        return timeStampFormat.format(new Date(timestampMS));
    }

    String getCurrentTimeToDisplaySeconds() {
        double totalMillis = fileBoard.getTotalTimeSeconds() * 1000.0;
        double currentMillis = fileBoard.getCurrentTimeSeconds() * 1000.0;

        String totalTimeStr = formatCurrentTime(totalMillis);
        String currentTimeStr = formatCurrentTime(currentMillis);

        return currentTimeStr + " / " + totalTimeStr;
    }

    String formatCurrentTime(double millis) {
        DateFormat formatter = currentTimeFormatShort;
        if (millis >= 3600000.0) { // bigger than 60 minutes
            formatter = currentTimeFormatLong;
        }

        return formatter.format(new Date((long)millis));
    }

    //checks if mouse is over the playback scrollbar
    private void checkMouseOver() {
        if (mouseX > xpos && mouseX < xpos+swidth &&
            mouseY > ypos && mouseY < ypos+sheight) {
            if(!over) {
                onMouseEnter();
            }
        }
        else {
            if (over) {
                onMouseExit();
            }
        }
    }

    // called when the mouse enters the playback scrollbar
    private void onMouseEnter() {
        over = true;
        cursor(HAND); //changes cursor icon to a hand
    }

    private void onMouseExit() {
        over = false;
        cursor(ARROW);
    }

    void draw() {
        pushStyle();

        fill(GREY_235);
        stroke(OPENBCI_BLUE);
        rect(x, y, w, h);

        //draw the playback slider inside the playback sub-widget
        noStroke();
        fill(GREY_200);
        rect(xpos, ypos, swidth, sheight);

        //select color for playback indicator
        if (over || locked) {
            fill(OPENBCI_DARKBLUE);
        } else {
            fill(102, 102, 102);
        }
        //draws playback position indicator
        rect(spos, ypos, sheight/2, sheight);

        //draw current timestamp and X of Y Seconds above scrollbar
        int fontSize = 17;
        textFont(p2, fontSize);
        fill(OPENBCI_DARKBLUE);
        float tw = textWidth(currentAbsoluteTimeToDisplay);
        text(currentAbsoluteTimeToDisplay, xpos + swidth - tw - 20, ypos - fontSize - 4);
        text(currentTimeInSecondsToDisplay, xpos, ypos - fontSize - 4);

        popStyle();

        pbsb_cp5.draw();
    }

    void screenResized(int _x, int _y, int _w, int _h, float _pbx, float _pby, float _pbw, float _pbh) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        swidth = int(_pbw);
        sheight = int(_pbh);
        xpos = _pbx;
        ypos = _pby - sheight/2;
        sposMin = xpos;
        sposMax = xpos + swidth - sheight/2;

        pbsb_cp5.setGraphics(ourApplet, 0, 0);
    }

}; //end ImgScrubBar class
