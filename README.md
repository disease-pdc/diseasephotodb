# Disease Photo Database

## Flipped Images Logic

Upon creation of a grading set, a percentage flipped images is assigned (10% by default) - store this number so changing it in the future doesn't un-finish grading sets.

Derived # for grading set: 

```
flipped_image_count = Math.ceil(image_count * flipped_percent) 
```

Total number to grade is # of images + (# of images * flipped percentage)

Create a second phase of grading - flipped grading:

1. Do the number of flipped `user_grading_set_images` equal or exceed `flipped_image_count` for the grading_set?  If not, continue.
2. Pick a grading_set_image at random.  If already a flipped image, pick another.
3. Present that image for grading.

