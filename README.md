# TF Imagery Database

## Image Upload Process

### Workbook Format:

Required columns:

* `filename` - Name of the image (without path)

Optional columns:

* ``

1. Client validates list of images to upload and xlsx workbook images match up.
2. Upload batch is created in the system and workbook is uploaded.
3. Each image is created 1 by 1 in the DB and the image is uploaded with metadata.  If the image already exists, the metadata is updated.
4. Each image is processed into CloudFlare images 1 by 1.
