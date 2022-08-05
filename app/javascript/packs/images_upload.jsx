import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { AsyncTypeahead } from 'react-bootstrap-typeahead'
import { get, post } from 'axios'

const doUpload = async ({
  authenticityToken,
  imageSourceId,
  file
}) => {
  const formData = new FormData()
  formData.append("authenticity_token", authenticityToken)
  formData.append("[image][image_source_id]", imageSourceId)
  formData.append("[image][image_file]", file)
  const result = await post('/images.json', formData, {
    headers: {
      "Content-Type": "multipart/form-data",
    }
  })
  return result.data
}


const Result = ({filename, success, errors}) => (
  <>
    {success && 
      <>
        <span className="badge bg-success">Success</span>
        &nbsp;
        <strong>{filename}</strong>
      </>
    }
    {!success &&
      <>
        <span className="badge bg-danger">Error</span>
        &nbsp;
        <strong>{filename}</strong>
        &nbsp;
        <span>{errors.map((e) => <span>{e}&nbsp;</span>)}</span>
      </>
    }
  </>
)

const ImagesUpload = ({
  authenticityToken,
  imageSources,
  imageSourceId
}) => {
  
  const [sourceId, setSourceId] = useState(imageSourceId || -1)

  const [images, setImages] = useState(null)
  const [uploading, setUploading] = useState(false)

  const [current, setCurrent] = useState(1)
  const [results, setResults] = useState([])
  const [finished, setFinished] = useState(false)


  useEffect(() => {
    const doEffect = async () => {
      if (uploading) {
        for (let i = 0; i < images.length; i++) {
          setCurrent(i+1)
          const result = await doUpload({
            authenticityToken,
            imageSourceId: sourceId,
            file: images[i]
          })
          results.push(result)
          setResults(results)
        }
        setFinished(true)
      }
    }
    doEffect().catch(console.error)
  }, [uploading])

  return (
    <>
      {!uploading && 
        <div className="row">
          <div className="col-lg-4">
            <label htmlFor="metadataFile" className="form-label">
              Select Image Source
            </label>
            <select className="form-select mb-3"
              value={imageSourceId}
              onChange={e => setSourceId(e.target.value)}
            >
              <option value="-1"></option>
              {imageSources.map(({id,name}) => (
                <option key={id} value={id}>{name}</option>
              ))}
            </select>
          </div>
          <div className="col-lg-8">
            <label htmlFor="metadataFile" className="form-label">
              Select images to upload to this source 
            </label>
            <div className="input-group mb-3">
              <input className="form-control" 
                type="file" 
                id="metadataFile" 
                accept="image/png,image/gif,image/jpeg"
                multiple
                onChange={(e) => {
                  setImages(e.target.files)
                }}
              />
              <button disabled={!images || !sourceId || sourceId === "-1"}
                className="btn btn-primary" 
                type="button"
                onClick={() => setUploading(true)}
              >
                Upload images
              </button>
            </div>
          </div>
        </div>
      }
      {uploading &&
        <>
          {!finished &&
            <strong>
              Uploading {current} / {images.length}
            </strong>
          }
          {finished && 
            <div className="alert alert-success" role="alert">
              Upload Complete - {current} processed
            </div>
          }
          <ul>
            {results.map((result, i) => (
              <li key={i}><Result {...result} /></li>
            ))}
          </ul>
        </>
      }
    </>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('react-app-container')
  ReactDOM.render(
    <ImagesUpload 
      authenticityToken={el.getAttribute('data-authenticity-token')}
      imageSources={JSON.parse(el.getAttribute('data-image-sources'))}
      imageSourceId={el.getAttribute('data-image-source-id')}
    />,
    el.appendChild(document.createElement('div'))
  )
})
