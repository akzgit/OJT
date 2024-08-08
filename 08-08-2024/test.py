import cv2
import numpy as np

#read the image with the particular library which we have imported
image=cv2.imread("Traffic_Signal.jpg")

if image is None:
    print("Could not read the image")
    exit()

#original image    
# cv2.imshow("original image",image)
# cv2.waitKey(0)    
# cv2.destroyAllWindows()

#convert to greyscale
grey_image=cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
# -- To grey scale---
# cv2.imshow("greyscale image:",grey_image)
# cv2.waitKey(0)    
# cv2.destroyAllWindows()

# -- we apply gaussian blur to the above image--
blurred_image=cv2.GaussianBlur(grey_image,(5,5),0)
# cv2.imshow("blurred image:",grey_image)
# cv2.waitKey(0)    
# cv2.destroyAllWindows()

#edge detection by using canny in cv2
edges =cv2.Canny(blurred_image,50,150)

#original image
cv2.imshow("original image",image)
cv2.waitKey(0)    

#greyscale
cv2.imshow("greyscale image",grey_image)
cv2.waitKey(0) 

#blurred image
cv2.imshow("blurred image",blurred_image)
cv2.waitKey(0) 

#edges
cv2.imshow("edges",edges)
cv2.waitKey(0) 

cv2.destroyAllWindows()