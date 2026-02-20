# Disease Photo Database

Web application for managing imagery and routing it through structured grading workflows. Designed to support two primary use cases:

1. **Grader training** — presenting images to human graders and collecting structured assessments
2. **ML dataset compilation** — aggregating grading data for training machine learning models

---

## Table of Contents

- [Overview](#overview)
- [Key Concepts](#key-concepts)
- [Tech Stack](#tech-stack)
- [User Roles](#user-roles)
- [Application Workflow](#application-workflow)
- [Grading Forms](#grading-forms)
- [Data Export](#data-export)
- [Background Jobs](#background-jobs)
- [Configuration](#configuration)
- [Setup](#setup)
- [Flipped Images Logic](#flipped-images-logic)

---

## Overview

The Disease Photo Database allows administrators to:

- Ingest images from named **Image Sources** (e.g. a clinical study site)
- Organise images into **Image Sets** (e.g. per-participant collections)
- Assign individual images or entire image sets to **Grading Sets**
- Assign graders (users) to grading sets
- Present each grader with a structured, step-by-step questionnaire for every image/image set
- Export grading results as CSV for downstream analysis or ML training

---

## Key Concepts

### Image Source
A named origin for images (e.g. a clinical site or study). Images and image sets belong to a source. Sources can be marked active/inactive. A source can optionally auto-create image sets from a metadata field on upload.

### Image
A single uploaded image file. On creation, EXIF data is extracted and image variants (list thumbnail 150×150, preview 300×300, main 1000×1000) are generated asynchronously. Images carry a flexible JSON `metadata` blob and a separate `exif_data` blob.

### Image Set
A named collection of images from a single source (e.g. all images for one study participant). Image sets carry their own JSON `metadata` blob. Image sets can be auto-created from image metadata on upload.

### Grading Set
A named set of **gradeables** (individual images or image sets) that is assigned to one or more graders. Each grading set has:
- A configurable **flipped image percentage** (see [Flipped Images Logic](#flipped-images-logic))
- A list of assigned users
- Progress tracking per user

### User Grading Set
The join between a user and a grading set. Tracks per-user progress through the grading queue.

### User Grading Set Image
A single grading response — one user's answers for one gradeable. Stores the full `grading_data` JSON blob submitted from the grading form.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 6.1, Ruby 3.2 |
| Database | PostgreSQL (JSON columns for metadata) |
| File Storage | Active Storage — local disk or AWS S3 |
| Background Jobs | Sidekiq + Redis |
| Frontend | Bootstrap 5, React (via Webpacker) |
| Image Processing | `image_processing` gem (libvips/ImageMagick), `exifr` for EXIF |
| Auth | Passwordless magic-link email login (BCrypt token hash) |

---

## User Roles

Roles are boolean flags on the `User` model. A user may hold multiple roles.

| Role | Access |
|---|---|
| `admin` | Full access — manages grading sets, users, image sources, image admin functions |
| `image_admin` | Upload images, update metadata, manage image sources |
| `image_viewer` | Browse images and image sets (read-only) |
| `grader` | Access the grading dashboard and submit grades |

Authentication uses a passwordless flow: the user enters their email, receives a time-limited magic link, and the resulting token is verified server-side.

---

## Application Workflow

```
Image Source
    └── Images (uploaded individually or synced via ParticipantSyncJob)
            └── Image Sets (auto-created from metadata field, or managed manually)
                    └── Grading Set  ←── assigned images / image sets
                            └── User Grading Set  ←── assigned graders
                                    └── User Grading Set Image  ←── one grading response per gradeable
```

1. An **Image Admin** creates an Image Source and uploads images (via the web UI or the metadata upload tool).
2. Images are optionally grouped into **Image Sets** automatically based on a configured metadata field.
3. An **Admin** creates a **Grading Set**, adds images or image sets to it, and assigns graders.
4. Each assigned **Grader** sees their grading sets on the dashboard and works through them one gradeable at a time.
5. For each gradeable the grader completes a structured questionnaire (see [Grading Forms](#grading-forms)). Progress is saved automatically after each submission.
6. Once all gradeables (including any flipped images) are complete, the grader marks the set as done.
7. Admins can download grading results as CSV at any time.

---

## Grading Forms

The grading UI is a React application (`app/javascript/packs/grading/`) that renders a step-by-step questionnaire alongside the image(s) being graded.

### Question types

| Type | Behaviour |
|---|---|
| `select_one` | Dropdown — auto-advances on selection |
| `select_multiple` | Checkbox group — requires explicit Next |
| `text` | Free-text input — advances on Enter or Next |

### Question features

- **`relevant`** — a predicate function; the question is skipped if it returns false (supports both question-level and group-level relevance)
- **`constraint`** — a validation function run on submit; displays `constraint_message` on failure
- **`required`** — blocks advancement if the answer is blank
- **Groups** — questions are organised into named sections (e.g. *Image Quality*, *Exam Findings*, *Results*); entire groups can be conditionally shown


---

## Data Export

All exports are streamed as CSV.

| Export | Route | Scope |
|---|---|---|
| Image metadata | `POST /images/metadata` | Filtered image selection |
| Image EXIF data | `POST /images/exif_data` | Filtered image selection |
| Image grading data | `POST /images/gradingdata` | Filtered image selection |
| Image set metadata | `POST /image_sets/metadata` | Filtered image set selection |
| Image set grading data | `POST /image_sets/gradingdata` | Filtered image set selection |
| Grading set results | `GET /grading_sets/:id/data.csv` | All responses for a grading set |

Grading data CSVs include fixed columns (`id`, `grading_set`, `name`, `source`, `user_id`, `user_email`) followed by one column per grading form field. Multi-select fields are expanded to one binary column per option.

---

## Background Jobs

Jobs run via Sidekiq. The Sidekiq web UI is mounted at `/sidekiq` (admin only).

| Job | Trigger | Purpose |
|---|---|---|
| `ExifJob` | After image create | Extracts EXIF metadata from JPEG/TIFF files and stores it on the image |
| `ImageVariantJob` | After image create | Pre-generates list/preview/main image variants |

---

## Configuration

Copy `.env.example` to `.env` and populate:

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string (Sidekiq) |
| `HOST` | Application hostname (used in mailer links) |
| `MAILER_FROM` | From address for magic-link emails |
| `SMTP_USERNAME` / `SMTP_PASSWORD` / `SMTP_HOST` / `SMTP_PORT` | SMTP credentials |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_BUCKET` / `AWS_REGION` | S3 storage (leave blank to use local disk) |
| `LOCKED_METADATA_KEYS` | Comma-separated metadata keys that cannot be overwritten via the metadata upload tool |

---

## Setup

```bash
# Install Ruby dependencies
bundle install

# Install JS dependencies
yarn install

# Create and migrate the database
bundle exec rails db:create db:migrate

# Start the web server and Sidekiq worker
foreman start
```

The app runs on port 3000 by default (`PORT` env var overrides this).

---

## Flipped Images Logic

A **flipped image** is a repeat presentation of an already-graded image, used to measure grader consistency (intra-rater reliability).

Each grading set has a `flipped_percent` (0% by default). When non-zero, after a grader completes all primary images they are presented with a random subset of previously graded images to grade again — without being told they are repeats.

```
flipped_image_count = ceil(image_count × flipped_percent / 100)
total_to_grade      = image_count + flipped_image_count
```

**Grading queue logic:**

1. Present all primary images in order (`flipped = false`).
2. Once primary images are complete, if `flipped_image_count > 0`, begin the flipped phase:
   - Pick a random already-graded image that has not yet been presented as a flip.
   - Present it for grading (stored with `flipped = true`).
3. The grading set is considered complete when `complete_image_count_total >= total_image_count`.

The `flipped_percent` is stored on the grading set at creation time so that changing the percentage later does not retroactively alter in-progress grading sets.
