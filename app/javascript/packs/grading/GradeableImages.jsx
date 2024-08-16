import React, { useState } from 'react'

import { ImageThumbnail } from './ImageThumbnail'

export const GradeableImages = ({
  gradingSetImage
}) => {

  const [zoomedIndex, setZoomedIndex] = useState();

  return (
    <div className="GradeableImages row">
      {gradingSetImage.images_for_grading.map((image) => (
        <div className="col-lg-6" key={image.id}>
          <ImageThumbnail image={image} />
        </div>
      ))}
    </div>
  )
}