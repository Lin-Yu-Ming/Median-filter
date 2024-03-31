Introduce to image filter


• Noise and Images


➔Principal sources of noise in digital images: during image acquisition, during image transmission.


➔Image acquisition: image sensor might produce noise because of environmental conditions or quality of 


• sensing elements.


➔Image transmission: interference in the channel



• Different types of image noise


➔Most common noise found in image processing: Gaussian noise, Rayleigh noise, Gamma noise, Exponential noise, Uniform noise, Impulse noise.


![1](https://github.com/Lin-Yu-Ming/Median-filter/assets/71814265/492856d1-4b67-44a2-a563-b839ace98eec)


Introduce to image filter


• Median filter


➔Find the median of all pixel values within a fixed range and replace the original central pixel value with this median value.


➔Excellent at noise removal, without the smoothing effects that can occur with other smoothing filters .


➔Particularly good when salt and pepper noise is present


![1](https://github.com/Lin-Yu-Ming/Median-filter/assets/71814265/23a0e8b8-e613-43dc-bc5a-e6948eb786c3)


 Introduce to image filter

 
 • The effects of different spatial filters


![1](https://github.com/Lin-Yu-Ming/Median-filter/assets/71814265/bc89fc40-0b23-4a33-9638-17529fa34907)


Hardware description


 • Block diagram


 ![1](https://github.com/Lin-Yu-Ming/Median-filter/assets/71814265/a0f2683a-2c02-450e-9b92-6124c3741eb6)


  • I/O Information


  ![1](https://github.com/Lin-Yu-Ming/Median-filter/assets/71814265/da4bdd90-e195-40cc-a72e-56966b8a2a6c)



• FSM


![image](https://github.com/Lin-Yu-Ming/Median-filter/assets/71814265/53d49873-4e14-4613-a484-0c91e211a703)

