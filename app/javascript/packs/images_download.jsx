import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'

import { get } from 'axios'
import JsZip from 'jszip'
import FileSaver from 'file-saver'

const getImageData = async ({
  imageSourceId,
  limit,
  offset
}) => {
  const result = await get(`/image_sources/${imageSourceId}/image_urls.json`, {
    params: {
      limit,
      offset
    }
  })
  return result.data.images
}

const getSignedUrl = async ({
  imageSourceId,
  imageId
}) => {
  const result = await get(`/image_sources/${imageSourceId}/image_url/${imageId}.json`)
  return result.data.url
}

const getImageCount = async ({
  imageSourceId
}) => {
  const result = await get(`/image_sources/${imageSourceId}/image_urls_count.json`)
  return result.data.count
}

const ImagesDownload = ({
  authenticityToken,
  imageSources,
  imageSourceId
}) => {

  const batchSize = 200;

  const [sourceId, setSourceId] = useState(imageSourceId)
  const [imageData, setImageData] = useState(null)
  const [imageCount, setImageCount] = useState(null)

  const [loadingImageData, setLoadingImageData] = useState(false)
  const [downloading, setDownloading] = useState(false)
  const [downloadingPercent, setDownloadingPercent] = useState(0.0)
  const [downloadingFile, setDownloadingFile] = useState(null)


  useEffect(() => {
    if (sourceId) {
      async function fetchData() {
        setLoadingImageData(true)
        setImageCount(await getImageCount({ imageSourceId: sourceId }))
        setLoadingImageData(false)
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

    // Fetch image list for this batch (no signed URLs)
    const imageData = await getImageData({
      imageSourceId: sourceId,
      limit: batchSize,
      offset: batchIndex * batchSize
    })

    const zip = JsZip()

    // Download one at a time, fetching a fresh signed URL for each
    for (let i = 0; i < imageData.length; i++) {
      setDownloadingPercent(((i / imageData.length) * 100).toFixed(2))
      setDownloadingFile(`Downloading image ${i + 1} of ${imageData.length}...`)

      const url = await getSignedUrl({
        imageSourceId: sourceId,
        imageId: imageData[i].id
      })
      const resp = await fetch(url)
      const blob = await resp.blob()
      zip.file(imageData[i].save_filename, blob)
    }

    setDownloadingPercent(0)
    setDownloadingFile('Generating zip file...')

    const zipFile = await zip.generateAsync(
      {
        type: 'blob',
        streamFiles: true
      },
      (metadata) => {
        setDownloadingPercent(metadata.percent.toFixed(2))
        setDownloadingFile(metadata.currentFile)
      }
    )

    const sourceName = getSourceName(sourceId) || 'images_sources'
    const fileName = `${sourceName}.${batchIndex + 1}.zip`
    setDownloading(false)
    return FileSaver.saveAs(zipFile, fileName)
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
        {loadingImageData &&
          <>
            <hr/>
            <div className="progress">
              <div className="progress-bar progress-bar-striped progress-bar-animated" 
                role="progressbar" 
                aria-valuenow="100" 
                aria-valuemin="0" 
                aria-valuemax="100"
                style={{width: `100%`}}
              >
              </div>
            </div>
            <p>Loading image folder data...</p>
          </>
        }
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
            {downloadingPercent < 100.0 &&
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
        {imageCount &&
          <>
            <hr/>
            <h5>Image Count: {imageCount}</h5>
            {Array.from({length: Math.ceil(imageCount / batchSize)}, (x, i) => (
              <div className="row mb-3 align-items-center" key={i}>
                <div className="col-auto text-right">
                  <label className="col-form-label">
                    Download images {i * batchSize + 1} through {(i + 1) * batchSize > imageCount ? imageCount : (i + 1) * batchSize }:
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