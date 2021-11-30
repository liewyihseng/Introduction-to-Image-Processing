Name			: Liew Yih Seng
Student ID		: 20090325
Module			: COMP2032 - Introduction to Image Processing
Module Convenor		: Dr. Amr Ahmed


To run the Matlab Code:
1) Unzip and extract the folder into your desired location.
2) Make sure the directory in Matlab has been path into COMP2032-LIEW-20090325 folder.
3) There are two ways to run the code:
	a) You can call the function extract_analyse_nucleus_hsv() with image name along with its 
	   file extension being the input argument in the Command Window. For instance:
		
			[im_output, numNucleus] = extract_analyse_nucleus_hsv("StackNinja1.bmp");
			
	   where it will generate two variables in the workspace, im_output representing the
	   Final Binary Image Marking Regions Corresponding to Nuclei and numNucleus representing
	   the total count of nuclei detected within the input image.
		
	b) Or you can run the script file I have prepared for you, run_extract_analyse_nucleus_hsv.m 
	   for your convenience, where it contains extract_analyse_nucleus_hsv function calls
	   for all three images provided. So you only have to comment the lines that you do not
	   want to run. All the outputs of this script file will be stored 
	   in the workspace with proper naming. For instance:
	   
			[im_output1, number_of_nucleus_hsv_1] = extract_analyse_nucleus_hsv("StackNinja1.bmp");
	   
	   The line above is supplied with input argument of image "StackNinja1.bmp", hence resulting 
	   in variables being tagged with "1" behind every output of this function call within the
	   workspace. This concept applies to other images and their outputs also.
	   
4) Both the methods stated above will return a total of two outputs per function call. To
   view the output of binary image after the extraction process, you can use imshow() to 
   have them displayed. Whereas, the other output in the form 
   of scalar value represents the total number of nucleus detected by the algorithm that I have created.
   However, I have shown all the step-by-step figures that leads the algorithm to the solution once the function 
   has been executed. So there might be chances to not needing to once again use imshow to display the output image.


Files included in the zip folder:
1) COMP2032-LIEW-20090325-REPORT.pdf
2) COMP2032-LIEW-20090325-VIDEO.mp4
3) extract_analyse_nucleus_hsv.m
4) run_extract_analyse_nucleus_hsv.m
5) README.txt
6) StackNinja1.bmp
7) StackNinja2.bmp
8) StackNinja3.bmp

Files that serves as input argument in function extract_analyse_nucleus_hsv():
1) "StackNinja1.bmp"
2) "StackNinja2.bmp"
3) "StackNinja3.bmp"