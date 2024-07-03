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

  const batchSize = 200;

  const [sourceId, setSourceId] = useState(imageSourceId)
  const [imageData, setImageData] = useState(null) 

  const [downloading, setDownloading] = useState(false)
  const [downloadingPercent, setDownloadingPercent] = useState(0.0)
  const [downloadingFile, setDownloadingFile] = useState(null)


  useEffect(() => {
    if (sourceId) {
      async function fetchData() {
        setImageData(await getImageData({ imageSourceId: sourceId }))
      }
      fetchData();
    }
  }, [sourceId])

  const getSourceName = (sourceId) => {
    for (let i = 0; i < imageSources.length; i++) {
      if (imageSources[i].id == sourceId) {
        return imageSources[i].name
      }
    }
  }

  const doDownload = async (batchIndex) => {
    setDownloading(true)
    setDownloadingPercent(0)
    const images = imageData.slice(batchIndex * batchSize, (batchIndex + 1) * batchSize);

    let imageBlobs = []
    for (let i = 0; i < images.length; i++) {
      imageBlobs.push({
        filename: images[i].filename,
        blob: fetch(images[i].url).then(resp => resp.blob())
      })
    }

    const zip = JsZip()
    imageBlobs.forEach((imageBlob, i) => {
      zip.file(imageBlob.filename, imageBlob.blob)
    })
    zip.generateAsync(
      {
        type: 'blob',
        streamFiles: true
      }, 
      (metadata) => {
        setDownloadingPercent(metadata.percent.toFixed(2))
        setDownloadingFile(metadata.currentFile)
      }
    ).then(zipFile => {
      const currentDate = new Date().getTime()
      const sourceName = getSourceName(sourceId) || 'images_sources'
      const fileName = `${sourceName}.${batchIndex + 1}.zip`
      setDownloading(false)
      setDownloading(false)
      return FileSaver.saveAs(zipFile, fileName);
    })
  }

  return (
    <>
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
        </div>
        {downloading &&
          <>
            <hr/>
            <div className="progress">
              <div className="progress-bar progress-bar-striped progress-bar-animated" 
                role="progressbar" 
                aria-valuenow={downloadingPercent} 
                aria-valuemin="0" 
                aria-valuemax="100"
                style={{width: `${downloadingPercent}%`}}
              >
              </div>
            </div>
            {downloadingPercent <= 0.0 &&
              <p>Fetching image list from database.</p>
            }
            {downloadingPercent > 0.0 && downloadingPercent < 100.0 &&
              <>
                <p>Downloading and zipping images.</p>
                {downloadingFile &&
                    <pre>{downloadingFile}</pre>
                }
              </>
            }
          </>
        }
        {downloadingPercent >= 100.0 &&
          <>
            <hr/>
            <p>Image downloading complete, your file should be saved shortly.</p>
          </>
        }
        {imageData &&
          <>
            <hr/>
            <h5>Image Count: {imageData.length}</h5>
            {Array.from({length: Math.ceil(imageData.length / batchSize)}, (x, i) => (
              <div className="row mb-3 align-items-center" key={i}>
                <div className="col-auto text-right">
                  <label className="col-form-label">
                    Download images {i * batchSize + 1} through {(i + 1) * batchSize > imageData.length ? imageData.length : (i + 1) * batchSize }:
                  </label>
                </div>
                <div className="col-auto">
                  <button disabled={downloading}
                    className="btn btn-primary btn-sm d-block" 
                    type="button"
                    onClick={() => doDownload(i)}
                  >
                    Download
                  </button>
                </div>
              </div>
            ))}
          </>
        }
      </>
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