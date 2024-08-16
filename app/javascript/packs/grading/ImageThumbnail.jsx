import React, { useEffect, useState } from 'react'

export const ImageThumbnail = ({
  image
}) => {

  const [zoomed, setZoomed] = useState(false);

  const escFunction = () => setZoomed(false);

  useEffect(() => {
    document.addEventListener("keydown", escFunction, false);
    return () => {
      document.removeEventListener("keydown", escFunction, false);
    };
  }, [escFunction]);

  return (
    <div className="ImageThumbnail">
      {zoomed && 
        <div className="modal show" style={{display: 'block'}}>
          <div className="modal-dialog modal-fullscreen">
            <div className="modal-content">
              <div className="modal-header">
                <h1 className="modal-title fs-4">
                  {image.filename}
                </h1>
                <button type="button" className="btn-close"
                  onClick={() => setZoomed(false)}
                />
              </div>
              <div className="modal-body">
                <img src={image.image_url_main} 
                  className="ImageFullscreen"
                />
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary"
                  onClick={() => setZoomed(false)}
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      }
      <img src={image.image_url_preview} 
        onClick={() => setZoomed(true)}
        className="img-thumbnail"
      />
    </div>
  )
}