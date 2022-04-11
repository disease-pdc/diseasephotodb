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

const ImagesUpload = ({authenticityToken}) => {

  const [selectLoading, setSelectLoading] = useState(false)
  const [selectOptions, setSelectOptions] = useState([])
  const [imageSource, setImageSource] = useState(null)

  const [images, setImages] = useState(null)
  const [uploading, setUploading] = useState(false)

  const [current, setCurrent] = useState(1)
  const [results, setResults] = useState([])
  const [finished, setFinished] = useState(false)


  useEffect(() => {
    const doEffect = async () => {
      if (uploading) {
        for (let i = 0; i < images.length; i++) {
          setCurrent(i)
          const result = await doUpload({
            authenticityToken,
            imageSourceId: imageSource.value,
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
        <>
          <label htmlFor="metadataFile" className="form-label">
            Select Image Source
          </label>
          <AsyncTypeahead
            id="image-source-select"
            className="mb-3"
            minLength={3}
            filterBy={() => true}
            isLoading={selectLoading}
            options={selectOptions}
            placeholder="Search for an Image Source..."
            onSearch={async (query) => {
              setSelectLoading(true)
              setSelectOptions(
                (await get('/image_sources.json', {params: {text: query}}))
                  .data.image_sources.map((is) => (
                    {label: is.name, value: is.id}
                  ))
              )
              setSelectLoading(false) 
            }}
            onChange={(value) => setImageSource(value[0])}
            renderMenuItemChildren={(option, props) => option.label}
          />
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
            <button disabled={!images || !imageSource}
              className="btn btn-primary" 
              type="button"
              onClick={() => setUploading(true)}
            >
              Upload images
            </button>
          </div>
        </>
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
  const token = el.getAttribute('data-authenticity-token')
  ReactDOM.render(
    <ImagesUpload authenticityToken={token} />,
    el.appendChild(document.createElement('div'))
  )
})
