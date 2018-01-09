# Edeme-segmentation

There are 19 OCT images for each eyeball. First, we segment the edemas of each OCT image. Sencond, we combined all images for 
edema fitting. Finally, we display the edemas.

The project mainly achieved the following two parts: image preprocessing;edema segmentation and display.

Directly running the main.m is ok.

A few result images:

1.Split the upper and lower borders of the retina, the upper boundary is ILM layer, the lower boundary is RPE layer.

![image](https://github.com/meteor518/Edema-segmentation/blob/master/%E5%88%86%E5%89%B2%E8%BE%B9%E7%95%8C.png)

2.Blisters in the edema region are divided into Sub-retinal fluid (SRF) and intra-retinal fluid (IRF). The red part indicates SRF, and the blue part indicates IRF. 

![image](https://github.com/meteor518/Edema-segmentation/blob/master/%E5%88%86%E5%89%B2%E6%B0%B4%E8%82%BF.png)

3.The final result:

![image](https://github.com/meteor518/Edema-segmentation/blob/master/%E6%9C%80%E7%BB%88%E6%98%BE%E7%A4%BA%E5%9B%BE.png)
