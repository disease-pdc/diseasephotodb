import React, { useEffect, useState } from 'react'

export const ImageThumbnail = ({
  image
}) => {

  return (
    <div className="ImageThumbnail">
      <img src={image.image_url_preview}
        className="img-thumbnail"
      />
    </div>
  )
}