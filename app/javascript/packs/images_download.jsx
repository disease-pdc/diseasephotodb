import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { get } from 'axios'
import JsZip from 'jszip'
import FileSaver from 'file-saver'

const getImageData = async ({
  imageSourceId
}) => {
  const result = await get(`/image_sources/${imageSourceId}/image_urls.json`)
  return result.data.images
}

const ImagesDownload = ({
  authenticityToken,
  imageSources,
  imageSourceId
}) => {

  const [sourceId, setSourceId] = useState(imageSourceId)
  const [imageData, setImageData] = useState([]) 

  const [downloading, setDownloading] = useState(false)
  const [downloadingPercent, setDownloadingPercent] = useState(0.0)

  const getSourceName = (sourceId) => {
    for (let i = 0; i < imageSources.length; i++) {
      if (imageSources[i].id == sourceId) {
        return imageSources[i].name
      }
    }
  }

  const doDownload = async () => {
    setDownloading(true)
    setDownloadingPercent(0)
    const images = await getImageData({ imageSourceId: sourceId })

    let imageBlobs = []
    for (let i = 0; i < images.length; i++) {
      imageBlobs.push({
        filename: images[i].filename,
        blob: fetch(images[i].url).then(resp => resp.blob())
      })
    }

    const zip = JsZip()
    imageBlobs.forEach((imageBlob, i) => {
      setDownloadingPercent((i+1) / imageBlobs.length * 100.0)
      zip.file(imageBlob.filename, imageBlob.blob)
    })
    zip.generateAsync({type: 'blob'}).then(zipFile => {
      const currentDate = new Date().getTime()
      const sourceName = getSourceName(sourceId) || 'images_sources'
      const fileName = `${sourceName}.zip`
      return FileSaver.saveAs(zipFile, fileName);
    })
  }

  return (
    <>
      {!downloading && 
        <>
          <div className="row">
            <div className="col-lg-6">
              <label htmlFor="metadataFile" className="form-label">
                Select Image Folder
              </label>
              <select className="form-select mb-3"
                value={sourceId}
                onChange={e => setSourceId(e.target.value)}
              >
                <option value="-1"></option>
                {imageSources.map(({id,name}) => (
                  <option key={id} value={id}>{name}</option>
                ))}
              </select>
            </div>
            <div className="col-lg-6">
              <label className="form-label">
                &nbsp;
              </label>
              <button disabled={!sourceId || sourceId === "" || sourceId === "-1"}
                className="btn btn-primary d-block" 
                type="button"
                onClick={doDownload}
              >
                Download images
              </button>
            </div>
          </div>
        </>
      }
      {downloading &&
        <>
          <div className="progress">
            <div className="progress-bar" 
              role="progressbar" 
              aria-valuenow={downloadingPercent} 
              aria-valuemin="0" 
              aria-valuemax="100"
              style={{width: `${downloadingPercent}%`}}
            >
            </div>
          </div>
          {downloadingPercent == 100 &&
            <p>Image downloading complete, your file should be saved shortly.</p>
          }
        </>
      }
    </>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('react-app-container')
  ReactDOM.render(
    <ImagesDownload 
      authenticityToken={el.getAttribute('data-authenticity-token')}
      imageSources={JSON.parse(el.getAttribute('data-image-sources'))}
      imageSourceId={el.getAttribute('data-image-source-id')}
    />,
    el.appendChild(document.createElement('div'))
  )
})