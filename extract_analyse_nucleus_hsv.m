%%  Description of the funtion
%    
%    [im_output, numNucleus] = extract_analyse_nucleus_hsv(imgName)
%    performs a series of image processing methods that extracts and
%    analyses the input argument in the form of image.
%
%    Input agrument
%    imgName - Representing the image name along with the file extension
%    that contains nucleus to be extracted and analysed.
%    
%    Output variables
%    im_output - Representing the generated result of the extraction
%    algorithm in black and white
%    numNucleus - Representing the number of nuclei being detected within
%    the input image after undergoing a series of image precessing methods
%
% Liew Yih Seng, University of Nottingham Malaysia Campus, April 2021.
% hfyyl2@nottingham.edu.my
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [im_output, numNucleus] = extract_analyse_nucleus_hsv(imgName)
    %% Reading and initialization of the variable im
    im = imread(imgName);
    % Display of Original Image
    figure('Name', 'Display of Original Image'),
    imshow(im);
    title("Original Image");
    
    %% Implementation of HSV colour space
    % Conversion from RGB to HSV colour space
    im_hsv = rgb2hsv(im);
    
    % Extraction of Hue Channel
    % Enhancing the white intensity of the image
    im_h = im_hsv(:, :, 1) .* 3;
    figure('Name', 'Display of Hue Channel in Grayscale'), 
    imshow(im_h);
    title("Extraction of Hue channel from HSV Colour space");
    
    %% Using Hue Channel as it is the best among comparisons
    % Applying Median Filter for Noise Reduction
    im_median = medfilt2(im_h, [4 4]);
    figure('Name', 'Display of Image after Median Filtering'),
    imshow(im_median);
    title("Image after Applying Median Filtering with Neighborhood of 4x4");
    
    %% Processing of im_median
    % Remove pixels that may be of red pixels
    % As red pixels tend to be very small within the scale from 0 to 1 in
    % the Hue Channel of Matlab representation
    [w h] = size(im_median);
    for i = 1 : w
        for j = 1 : h
            if(im_median(i, j) < 0.1)
                im_median(i, j) = 0;
            end
        end
    end
    
    %% Converting im_median into black and white
    % adaptthresh is a local adaptive thresholding that computes the
    % threshold based on the local mean intensity of the neighborhood of
    % each pixels
    adapt_thresh = adaptthresh(im_median, 0.4, "ForegroundPolarity", "bright");
    im_bw = imbinarize(im_median, adapt_thresh);
    figure('Name', 'Display of Binarized Image with Adaptive Threshold'),
    imshow(im_bw);
    title("Image after Applying Imbinarize with Threshold from Adaptthresh");
    
    %% Clearing small and unwanted pixels using imopen
    % Initializing a structural element of size 4
    se_4 = strel("disk", 4);
    im_open = imopen(im_bw, se_4);
    
    % Comparison of the current image and the initial image
    im_overlay = labeloverlay(im, im_open);
    
    % Displaying the comparison of current progress of extraction with
    % original image
    figure('Name', 'Comparison of Progress of Cell Nuclei Extraction'),
    subplot(2, 1, 1), imshow(im_open);title("Image after Clearing Small and Unwanted Pixels");
    subplot(2, 1, 2), imshow(im_overlay);title("Overlay of Images from Above and Original Image");
    
    %% Implementing Watershed
    % Measuring bwdist
    im_bwdist = bwdist(~im_open);
   
    % Inverting values of im_bwdist
    im_bwdist = -im_bwdist;
    
    % Watershed Transformation
    im_watershed = watershed(im_bwdist, 8);
    im_watershed(~im_open) = 0;
    
    % Converting im_watershed to black and white
    im_watershed = logical(im_watershed);
    figure('Name', 'Display of Image Undergoing Watershed Transformation in Black and White'),
    imshow(im_watershed);
    title("Image after Applying Watershed Transformation");
    
    % Opening to remove small unwanted pixels and to enhance the borders of
    % the detected nuclei
    im_open = imopen(im_watershed, se_4);
    figure('Name', 'Display of Image after being Morphological Opened'),
    imshow(im_open);
    title("Image after Applying Morphological Opening with Structure Element of 4 (Final Output)");
    
    %% Counting of nucleus detected using bwconncomp
    cc = bwconncomp(im_open, 4);
    numNucleus = cc.NumObjects;
    
    % Labelling nucleus with different colour
    im_labeled = labelmatrix(cc);
    im_watershed_rgb = label2rgb(im_labeled, 'spring', 'k', 'shuffle');
    
    %% Observing the performance of this current stage of extraction process
    im_overlay = 0.5 * im_watershed_rgb + im;

    %% Output image
    im_output = im_open;
    
    %% Marking of nucleus detected
    [cells, im_marking] = bwboundaries(im_output, 4, 'noholes');
    
    figure('Name', 'Display of Output of Extraction of Cell Nuclei'),
    subplot(2, 2, 1),imshow(im_watershed_rgb); title("Colour Labelling of Image After Watershed Transformation");
    subplot(2, 2, 2),imshow(im_overlay); title("Overlay of Images After Watershed and the Original Image");
    subplot(2, 2, 3),imshow(im); title("Marking of Outlines of all the Detected Nuclei");
    hold on
    % Performing the marking process onto the image
    for k = 1: length(cells)
        boundary = cells{k};
        plot(boundary(:, 2), boundary(:, 1), 'y', 'LineWidth',1);
    end
    subplot(2, 2, 4), imshow(im_output);title("Final Binary Image Marking Regions Corresponding to Nuclei");
    
    
    %% Analysis
    % Area - Representing the number of pixels in the nucleus
    % PixelList - Representing the list of pixel coordinates
    % Eccentricity - Representing the likelihood the nucleus is of the
    % shape of circle or ellipse, where nucleus is circle when the value
    % generated is close or equal to 0, and nucleus is ellipse  when the
    % value generated is close or equal to 1
    nucleus = regionprops(im_output, 'Area', 'PixelList', 'Eccentricity');
    
    % Initializing the variable nucleusSize, nucluesShape and
    % nucleusCoordinate
    nucleusSize = zeros(numel(nucleus), 1);
    nucleusShape = zeros(numel(nucleus), 1);
    nucleusCoordinate = struct('Coordinates', {});
    
    %% Analysis of size of nucleus using Area from regionprops
    % Assigning all the values retrieved from regionprops to variable
    % nucleusSize
    for i = 1 : numel(nucleus)
        nucleusSize(i) = getfield(nucleus, {i}, 'Area');
    end
    
    %% Analysis of shape of nucleus using Eccentricity from regionprops
    % Assigning all the values retrieved from regionprops to variable
    % nucleusShape
    for i = 1 : numel(nucleus)
        nucleusShape(i) = getfield(nucleus, {i}, 'Eccentricity');
    end
    
    %% Analysis of brightness of nucleus
    % HSV Channel 3 is representing the brightness
    im_v = im_hsv(:, :, 3);
    
    % Assigning all the pixel coordinates of detected nuclei from
    % regionprops to struct type nucleusCoordinate
    for i= 1 : numel(nucleus)
        nucleusCoordinate{i} = num2cell(getfield(nucleus, {i}, 'PixelList'));
    end
    
    % Initializing the meanBrightness array
    meanBrightness = zeros(1, length(nucleusCoordinate));
    
    % Calculate the mean brightness in each cell then assign it into the
    % array of meanBrightness
    for i = 1 : numel(nucleusCoordinate)
        sum = 0;
        cell_Coordinate = cell2mat(nucleusCoordinate{i});
        for k = 1 : length(nucleusCoordinate{i})
            sum = sum + im_v(cell_Coordinate(k, 2), cell_Coordinate(k, 1));
        end
        meanBrightness(i) = sum/ length(nucleusCoordinate{i});
    end
    
    %% Displaying of all distribution histograms for analysis
    % Displaying the distribution of the nucleus size
    figure('Name', 'Display of All Analysis Distribution being Done'),
    subplot(2, 2, 1),
    histogram(nucleusSize, 10);
    xlabel("Size in Pixels");
    ylabel("Count");
    title("Distribution of Sizes of Detected Nucleus");
    
    % Displaying the distribution of the nucleus shape
    subplot(2, 2, 2),
    histogram(nucleusShape, 10);
    xlabel("Eccentricity");
    ylabel("Count");
    title("Distribution of Shapes of Detected Nucleus");
    
    % Displaying the distribution of the average brightness of the nucleus
    subplot(2, 2, 3),
    histogram(meanBrightness);
    xlabel("Mean Brightness");
    ylabel("Count");
    title("Distribution of Average Brightness of Detected Nucleus");
    
end