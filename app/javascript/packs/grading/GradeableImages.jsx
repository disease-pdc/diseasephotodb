import React, { useEffect, useState } from 'react'

import { ImageThumbnail } from './ImageThumbnail'

export const GradeableImages = ({
  gradingSetImage
}) => {

  const [zoomedIndex, setZoomedIndex] = useState();


  const escFunction = () => setZoomedIndex();

  const getZoomedImage = () => {
    return gradingSetImage.images_for_grading[zoomedIndex]
  }

  const hasPrev = (index) => {
    return index - 1 >= 0;
  }

  const hasNext = (index) => {
    return index + 1 < gradingSetImage.images_for_grading.length;
  }

  let els = [];
  for (let i = 0; i < gradingSetImage.images_for_grading.length; i++) {
    const image = gradingSetImage.images_for_grading[i];
    els.push(
      <div className="col-lg-6" key={image.id}
        onClick={() => setZoomedIndex(i)}
      >
        <ImageThumbnail image={image} />
      </div>
    );
  }

  useEffect(() => {
    document.addEventListener("keydown", escFunction, false);
    return () => {
      document.removeEventListener("keydown", escFunction, false);
    };
  }, [escFunction]);


  return (
    <div className="GradeableImages">
      {typeof zoomedIndex != 'undefined' && 
        <div className="modal show" style={{display: 'block'}}>
          <div className="modal-dialog modal-fullscreen">
            <div className="modal-content">
              <div className="modal-header">
                <h1 className="modal-title fs-4">
                  {getZoomedImage().filename}
                </h1>
                <button type="button" className="btn-close"
                  onClick={() => setZoomedIndex()}
                />
              </div>
              <div className="modal-body">
                <img src={getZoomedImage().image_url_main} 
                  className="ImageFullscreen"
                />
              </div>
              <div className="modal-footer">
                <div className="row" style={{flex: '1'}}>
                  <div className="col-6">
                    <div className="d-grid gap-2">
                      <button className="btn btn-lg btn-primary" type="button"
                        disabled={!hasPrev(zoomedIndex)}
                        onClick={() => {if (hasPrev(zoomedIndex)) setZoomedIndex(zoomedIndex - 1)}}
                      >
                        Previous
                      </button>
                    </div>
                  </div>
                  <div className="col-6">
                    <div className="d-grid gap-2">
                      <button className="btn btn-lg btn-primary" type="button"
                        disabled={!hasNext(zoomedIndex)}
                        onClick={() => {if (hasNext(zoomedIndex))  setZoomedIndex(zoomedIndex + 1)}}
                      >
                        Next
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      }
      <div className="row">
        {els}
      </div>
    </div>
  )
}